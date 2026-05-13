# Firestore Schema — DebtFlow

**Version:** 1.0  
**Backend:** Firebase Firestore (NoSQL)  
**Auth:** Firebase Authentication

---

## Design Decisions

1. **Per-user data isolation:** All data lives under `users/{userId}/` — no cross-user data leakage.
2. **Flat payments collection:** Installment payments stored as a flat collection under the user (not nested under each installment), enabling efficient date-range queries across all clients.
3. **Pre-aggregated dashboard stats:** `aggregates/` documents are updated atomically on every transaction — no expensive full-collection reads on dashboard load.
4. **Profit recognized incrementally:** `profitPerPayment` stored at installment creation; `recognizedProfit` incremented per paid payment.
5. **Transactions are immutable:** Reversals mark status = 'reversed', never delete.
6. **Status is always computed + stored:** Status fields (overdue, paid, etc.) are stored on documents AND re-evaluated by a scheduled Cloud Function nightly for drift correction.

---

## Collection Structure Overview

```
users/
  {userId}/
    ├── clients/
    │     {clientId}
    ├── installments/
    │     {installmentId}
    ├── payments/              ← all installment monthly payments (flat)
    │     {paymentId}
    ├── gracePeriods/
    │     {gracePeriodId}
    ├── transactions/          ← audit log of all financial events
    │     {transactionId}
    └── aggregates/
          monthly/
            {yearMonth}        ← e.g. "2024-01"
          allTime              ← single document
```

---

## 1. `users/{userId}`

User profile document. Created on registration.

```typescript
{
  displayName: string,          // Full name
  email: string,
  photoURL: string | null,
  language: 'ar' | 'en',       // Default: 'ar'
  darkMode: boolean,            // Default: true
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

---

## 2. `users/{userId}/clients/{clientId}`

One document per client. Denormalized totals updated on every payment.

```typescript
{
  // Identity
  fullName: string,
  phone: string,
  gender: 'male' | 'female',
  documentationType: 'electronic' | 'paper',
  clientType: 'office' | 'private',
  notes: string | null,

  // Computed totals (updated atomically on every payment/reversal)
  totalPaid: number,            // Sum of all payments made (all time, all debts)
  totalRemaining: number,       // Sum of all unpaid amounts across active debts
  activeDebtsCount: number,     // Count of active installments + unpaid grace periods

  // Payment quality (updated on every payment)
  paymentQualityScore: number,  // 0–100 percentage
  onTimePaymentsCount: number,  // Payments made on time
  totalDuePaymentsCount: number,// Total payments that have passed due date

  // Metadata
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Quality score badge thresholds (UI only, not stored):**
- 90–100 → "موثوق" (green)
- 70–89  → "جيد" (yellow)
- < 70   → "ضعيف" (red)

**Client list status (UI only, not stored):**
- "تم السداد" = all payments due this month for this client are paid
- "لم يتم السداد" = at least one payment due this month is not paid

---

## 3. `users/{userId}/installments/{installmentId}`

One document per installment record. Payment schedule documents created separately in `payments/`.

```typescript
{
  // Reference
  clientId: string,

  // Details
  itemName: string,             // e.g. "هاتف ذكي"
  capital: number,              // رأس المال (base price)
  profitAmount: number,         // نسبتي (fixed profit, not a percentage)
  profitPerPayment: number,     // = profitAmount / durationMonths (stored at creation)
  monthlyAmount: number,        // = (capital + profitAmount) / durationMonths
  totalDebt: number,            // = capital + profitAmount

  // Schedule
  durationMonths: number,       // 3 | 6 | 9 | 12 | 24
  startDate: Timestamp,         // Date entered by admin (first payment = day 10 of NEXT month)
  firstPaymentDueDate: Timestamp,// Day 10 of month after startDate

  // Office commission (only relevant for office clients)
  officeCommissionAmount: number,  // = capital * 0.10 (0 for private clients)
  officeCommissionPaid: boolean,   // Default: false
  officeCommissionPaidAt: Timestamp | null,

  // Progress (updated atomically on each payment)
  paidPaymentsCount: number,    // How many monthly payments made
  totalPaymentsCount: number,   // = durationMonths
  totalPaidAmount: number,      // Running sum of payments received
  recognizedProfit: number,     // Running sum of profitPerPayment × paid count

  // State
  status: 'active' | 'completed',
  editLocked: boolean,          // true after first payment is made

  // Metadata
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Status logic:**
- `active` → paidPaymentsCount < totalPaymentsCount
- `completed` → paidPaymentsCount == totalPaymentsCount

---

## 4. `users/{userId}/payments/{paymentId}`

One document per monthly installment payment. All installment payments are flat here for efficient cross-client queries.

```typescript
{
  // References
  clientId: string,
  installmentId: string,

  // Schedule
  monthIndex: number,           // 1-based (month 1, 2, ..., N)
  dueDate: Timestamp,           // Always day 10 of the due month
  dueMonth: string,             // "YYYY-MM" — for range queries (e.g. "2024-03")

  // Amount
  amount: number,               // = installment.monthlyAmount
  profitPortion: number,        // = installment.profitPerPayment

  // Status
  status: 'upcoming' | 'current' | 'overdue' | 'paid' | 'reversed',
  paidDate: Timestamp | null,   // Set when admin marks as paid
  paidAt: Timestamp | null,     // Server timestamp of the write

  // Metadata
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Status transitions:**

```
upcoming → current   (when today.month == dueMonth AND today.day <= 10)
current  → overdue   (when today.day > 10 AND still not paid)
upcoming → overdue   (when dueDate is in a past month AND not paid)
any      → paid      (when admin marks payment)
paid     → reversed  (when admin reverses — status set to 'reversed', 
                      then recalculated: overdue or upcoming based on today)
```

> **Note:** Status is updated by the app on read (optimistic) AND corrected nightly by a Cloud Function to handle offline edge cases.

**Overdue display:** `daysOverdue = today - dueDate` (in days)

---

## 5. `users/{userId}/gracePeriods/{gracePeriodId}`

One document per grace period. Single payment — no sub-schedule needed.

```typescript
{
  // Reference
  clientId: string,

  // Details
  name: string,                 // اسم المهلة / الغرض
  capital: number,              // المبلغ الإجمالي (full amount to repay, = رأس المال)
  notes: string | null,

  // Due date (admin-set)
  dueDate: Timestamp,           // تاريخ الإصدار — the payment deadline
  gracePeriodEndDate: Timestamp,// = dueDate + 10 days (computed at creation, stored)

  // Office commission
  officeCommissionAmount: number,  // = capital * 0.10 (0 for private clients)
  officeCommissionPaid: boolean,
  officeCommissionPaidAt: Timestamp | null,

  // Payment
  status: 'upcoming' | 'grace_window' | 'overdue' | 'paid',
  paidDate: Timestamp | null,
  paidAt: Timestamp | null,

  // State
  editLocked: boolean,          // true once paid

  // Metadata
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

**Status logic:**
```
IF paidDate is set                          → 'paid'
ELSE IF today <= dueDate                    → 'upcoming'
ELSE IF dueDate < today <= gracePeriodEndDate → 'grace_window'
ELSE (today > gracePeriodEndDate)           → 'overdue'
```

**Overdue display:** `daysOverdue = today - gracePeriodEndDate`

**Quality score contribution:**
```
onTime = (paidDate != null) AND (paidDate <= gracePeriodEndDate)
```

---

## 6. `users/{userId}/transactions/{transactionId}`

Immutable audit log. Every financial event creates a transaction. Reversals update status — never delete.

```typescript
{
  // References
  clientId: string,
  relatedId: string,            // paymentId | gracePeriodId | installmentId (for commission)
  relatedType: 'installment_payment' | 'grace_period' | 'office_commission',

  // Helper references (for easier querying)
  installmentId: string | null, // Set when relatedType == 'installment_payment'
  gracePeriodId: string | null, // Set when relatedType == 'grace_period'

  // Financial
  amount: number,
  profitPortion: number | null, // Only for installment_payment type

  // Classification
  type: 'payment' | 'office_commission',
  status: 'completed' | 'reversed',

  // Time
  yearMonth: string,            // "YYYY-MM" — for monthly aggregation
  paidDate: Timestamp,          // The date of the original payment

  // Reversal (populated only if reversed)
  reversedAt: Timestamp | null,
  reversalNote: string | null,

  // Metadata
  createdAt: Timestamp
}
```

**Rules:**
- Never deleted
- `status = 'reversed'` transactions excluded from all financial totals
- Visible in audit history / كشف الحساب with "محول" badge

---

## 7. `users/{userId}/aggregates/monthly/{yearMonth}`

Pre-computed per-month stats. Updated atomically (Firestore transaction) on every payment or reversal.

Document ID = `"YYYY-MM"` (e.g. `"2024-03"`)

```typescript
{
  yearMonth: string,            // "YYYY-MM"

  // Actual collection (updated on each payment/reversal atomically)
  monthlyCollection: number,    // Sum of completed transactions this month

  // Target is computed on load from payments + gracePeriods collections
  // Not stored here — too many writes if installments added mid-month

  updatedAt: Timestamp
}
```

> **Monthly Target** is computed on dashboard load:
> ```
> target = SUM(payments WHERE dueMonth == currentYearMonth)
>        + SUM(gracePeriods WHERE dueDate is in currentMonth)
> ```

---

## 8. `users/{userId}/aggregates/allTime`

Single document. Updated atomically on every transaction.

Document ID = `"allTime"`

```typescript
{
  totalCapital: number,         // Sum of capital from ALL installments + grace periods (ever added)
  totalRecognizedProfit: number,// Running sum of profitPortion from all paid installment payments
  totalOfficeCommission: number,// Sum of all paid office commission amounts
  totalClients: number,         // Count of client documents

  updatedAt: Timestamp
}
```

---

## Firestore Indexes Required

Composite indexes to create in `firestore.indexes.json`:

```json
[
  // Payments: by client + month (client payment history)
  { "collection": "payments", "fields": ["clientId", "dueMonth"] },

  // Payments: by month + status (dashboard target, accounts screen)
  { "collection": "payments", "fields": ["dueMonth", "status"] },

  // Payments: by installment + monthIndex (tracking screen order)
  { "collection": "payments", "fields": ["installmentId", "monthIndex"] },

  // Grace periods: by client + status (client detail screen)
  { "collection": "gracePeriods", "fields": ["clientId", "status"] },

  // Grace periods: by dueDate + status (overdue detection)
  { "collection": "gracePeriods", "fields": ["status", "dueDate"] },

  // Transactions: by month + status (accounts screen, report)
  { "collection": "transactions", "fields": ["yearMonth", "status"] },

  // Transactions: by client + createdAt (client transaction history)
  { "collection": "transactions", "fields": ["clientId", "createdAt"] },

  // Installments: by client + status (client detail screen)
  { "collection": "installments", "fields": ["clientId", "status"] }
]
```

> All collections above are under `users/{userId}/`. In Firestore rules and indexes, use the full path:
> `users/{userId}/payments`, etc.

---

## Atomic Operations (Firestore Transactions)

### On Payment Made (installment payment)

```
ATOMIC {
  payments/{paymentId}.status = 'paid'
  payments/{paymentId}.paidDate = today
  installments/{installmentId}.paidPaymentsCount += 1
  installments/{installmentId}.totalPaidAmount += amount
  installments/{installmentId}.recognizedProfit += profitPerPayment
  installments/{installmentId}.editLocked = true
  installments/{installmentId}.status = 'completed' IF paidPaymentsCount == totalPaymentsCount
  clients/{clientId}.totalPaid += amount
  clients/{clientId}.totalRemaining -= amount
  clients/{clientId}.totalDuePaymentsCount += 1
  clients/{clientId}.onTimePaymentsCount += 1 IF paidDate.day <= 10
  clients/{clientId}.paymentQualityScore = recalculate()
  transactions/ → CREATE new transaction doc
  aggregates/monthly/{yearMonth}.monthlyCollection += amount
  aggregates/allTime.totalRecognizedProfit += profitPerPayment
}
```

### On Grace Period Paid

```
ATOMIC {
  gracePeriods/{id}.status = 'paid'
  gracePeriods/{id}.paidDate = today
  gracePeriods/{id}.editLocked = true
  clients/{clientId}.totalPaid += amount
  clients/{clientId}.totalRemaining -= amount
  clients/{clientId}.totalDuePaymentsCount += 1
  clients/{clientId}.onTimePaymentsCount += 1 IF paidDate <= gracePeriodEndDate
  clients/{clientId}.paymentQualityScore = recalculate()
  transactions/ → CREATE new transaction doc
  aggregates/monthly/{yearMonth}.monthlyCollection += amount
}
```

### On Payment Reversed

```
ATOMIC {
  payments/{paymentId} OR gracePeriods/{id}: 
    → reset status (overdue if past due, upcoming if not)
    → paidDate = null
  installments/{id} (if applicable):
    .paidPaymentsCount -= 1
    .totalPaidAmount -= amount
    .recognizedProfit -= profitPerPayment
    .status = 'active'
  clients/{clientId}.totalPaid -= amount
  clients/{clientId}.totalRemaining += amount
  clients/{clientId}.onTimePaymentsCount -= 1 IF original payment was on-time
  clients/{clientId}.totalDuePaymentsCount -= 1
  clients/{clientId}.paymentQualityScore = recalculate()
  transactions/{id}.status = 'reversed'
  transactions/{id}.reversedAt = now()
  aggregates/monthly/{yearMonth}.monthlyCollection -= amount IF yearMonth == currentYearMonth
  aggregates/allTime.totalRecognizedProfit -= profitPerPayment (if applicable)
}
```

### On Office Commission Paid

```
ATOMIC {
  installments/{id} OR gracePeriods/{id}:
    .officeCommissionPaid = true
    .officeCommissionPaidAt = now()
  transactions/ → CREATE commission transaction doc
  aggregates/allTime.totalOfficeCommission += officeCommissionAmount
}
```

### On Installment Created

```
ATOMIC {
  installments/{id} → CREATE
  payments/{id_1..N} → CREATE N payment docs (one per month)
  clients/{clientId}.totalRemaining += totalDebt
  clients/{clientId}.activeDebtsCount += 1
  aggregates/allTime.totalCapital += capital
  IF officeCommissionPaid == true at creation:
    → also run On Office Commission Paid atomically
}
```

### On Grace Period Created

```
ATOMIC {
  gracePeriods/{id} → CREATE
  clients/{clientId}.totalRemaining += capital
  clients/{clientId}.activeDebtsCount += 1
  aggregates/allTime.totalCapital += capital
  IF officeCommissionPaid == true at creation:
    → also run On Office Commission Paid atomically
}
```

---

## Cloud Function: Nightly Status Updater

**Trigger:** Scheduled — runs daily at 00:05 AM (server time)

**Purpose:** Correct any status drift (e.g. phone was offline when midnight passed)

```
FOR each user:
  FOR each payment WHERE status IN ('upcoming', 'current'):
    recalculate status based on dueDate vs today
    IF changed → update status field

  FOR each gracePeriod WHERE status IN ('upcoming', 'grace_window'):
    recalculate status based on dueDate, gracePeriodEndDate vs today
    IF changed → update status field
```

---

## Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can only read/write their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null 
                         && request.auth.uid == userId;
    }

    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## Data Constraints & Validation (App-level)

| Field | Constraint |
|-------|-----------|
| `capital` | > 0 |
| `profitAmount` | >= 0 |
| `durationMonths` | in [3, 6, 9, 12, 24] |
| `officeCommissionAmount` | = capital × 0.10 (computed, not user-input) |
| `paymentQualityScore` | 0–100 |
| `monthIndex` | 1 to durationMonths |
| `dueDate` (payment) | Always day 10 of month |
| `gracePeriodEndDate` | Always = dueDate + 10 days |
| `yearMonth` (string) | Format: "YYYY-MM" |

---

*End of Firestore Schema v1.0*
