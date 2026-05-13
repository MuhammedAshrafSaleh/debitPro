# Business Requirements Document (BRD)
## DebtFlow — نظام إدارة الأقساط والمهل

**Version:** 1.0  
**Status:** Draft  
**App Name:** DebtFlow  
**Platform:** Mobile (Flutter / React Native)  
**Backend:** Firebase (Auth + Firestore)

---

## Table of Contents

1. [Overview](#1-overview)
2. [User Roles & Access](#2-user-roles--access)
3. [Authentication Module](#3-authentication-module)
4. [Client Management Module](#4-client-management-module)
5. [Installments Module (أقساط)](#5-installments-module-أقساط)
6. [Grace Periods Module (مهل)](#6-grace-periods-module-مهل)
7. [Payments & Tracking Module](#7-payments--tracking-module)
8. [Dashboard Module](#8-dashboard-module)
9. [Accounts & Reports Module](#9-accounts--reports-module)
10. [Settings Module](#10-settings-module)
11. [Business Rules & Calculations](#11-business-rules--calculations)
12. [Payment Reversal Rules](#12-payment-reversal-rules)
13. [Navigation Structure](#13-navigation-structure)

---

## 1. Overview

DebtFlow is a mobile application for a single admin user to manage clients' installments (أقساط) and grace periods (مهل). The admin tracks payments, calculates profit, monitors overdue clients, and generates financial reports.

**Key Concepts:**
- **Installment (قسط):** A debt split into monthly payments with a profit margin. Each month has a payment due on day 10.
- **Grace Period (مهلة):** A one-time lump-sum payment with no profit margin. Has a single due date set by the admin.
- **Office Client (عميل مكتب):** Subject to a 10% office commission on capital.
- **Private Client (عميل خاص):** No office commission.

---

## 2. User Roles & Access

| Role | Description |
|------|-------------|
| Admin (Owner) | Single user. Full access to all features. |

> **Note:** This is a single-user application. Each Firebase user account manages their own isolated dataset. No multi-tenancy or role sharing is required.

---

## 3. Authentication Module

### 3.1 Screens
- Login
- Register (Create New Account)
- Forgot Password
- Password Reset Email Sent (confirmation screen)
- Edit Account (within Settings)

### 3.2 Login
**Fields:**
- Email (required)
- Password (required, hidden with toggle)

**Actions:**
- "تسجيل الدخول" → validates and signs in via Firebase Auth
- "المتابعة بـ Google" → Google OAuth sign-in
- "نسيت كلمة المرور؟" → navigates to Forgot Password
- "ليس لديك حساب؟ سجل الآن" → navigates to Register

**Error States:**
- Show inline error: "البريد الإلكتروني أو كلمة المرور غير صحيحة"

### 3.3 Register
**Fields:**
- Full Name (required)
- Email (required, valid format)
- Password (required, min 8 characters)
- Confirm Password (required, must match)
- Terms & Privacy checkbox (required to enable submit)

**Validation:**
- Password < 8 chars → show: "يجب أن تكون 8 أحرف على الأقل"
- Passwords mismatch → show error on confirm field

### 3.4 Forgot Password
**Step 1 — Enter Email:**
- Email field
- "إرسال رابط الاستعادة" → sends Firebase password reset email
- "العودة لتسجيل الدخول" link

**Step 2 — Confirmation Screen:**
- Show the email it was sent to
- Countdown timer for "إعادة الإرسال" (e.g. 60 seconds)
- "لم أستلم البريد الإلكتروني" option to resend
- "العودة إلى تسجيل الدخول" button

### 3.5 Edit Account (in Settings)
**Profile Section:**
- Display Name (editable inline)
- Email (editable inline, requires re-authentication)
- Profile Photo (optional, camera icon overlay)
- Member since date (read-only, shown under name)

**Security Section:**
- Current Password
- New Password
- Confirm New Password
- "حفظ التغييرات" button → saves all changes

---

## 4. Client Management Module

### 4.1 Screens
- Client List
- Add New Client
- Client Detail (with tabs: Monthly Installments / Grace Periods)
- Client Grace Periods View

### 4.2 Client List Screen

**Header:**
- Notification bell icon (top left)
- Search bar: "ابحث عن عميل..." with search icon
- Avatar/profile icon (top right) → navigates to Settings

**Filter Tabs (horizontal scroll):**
- الكل (All) — default
- إلكتروني (Electronic documentation)
- وقي (Paper documentation)
- عميل مكتب (Office client)

**Client Card (per client):**
- Avatar (initials if no photo)
- Full Name
- Phone number
- Tags: documentation type badge + client type badge
- Status indicator (dot): "تم السداد" (green) / "لم يتم السداد" (red) — based on whether ALL active debts have been paid this month
- Debt count: "عدد الديون: X"
- Arrow icon → navigates to Client Detail

**FAB (Floating Action Button):** "+" → navigates to Add New Client

### 4.3 Add New Client Screen

**Fields:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| الاسم الكامل | Text input | Yes | Full name |
| رقم الهاتف | Phone input | Yes | Format: 0XX XXX XXXX |
| الجنس | Toggle: ذكر / أنثى | Yes | Default: ذكر |
| نوع التوثيق المفضل | Toggle: إلكتروني / وقي | Yes | Default: إلكتروني |
| تصنيف العميل | Toggle: عميل مكتب / عميل خاص | Yes | Default: عميل مكتب |
| ملاحظات إضافية | Textarea | No | Free text |

**Actions:**
- "حفظ العميل +" → creates client and navigates back to client list
- "إلغاء" → discards and navigates back

### 4.4 Client Detail Screen

**Client Header Card:**
- Avatar + Full Name + Phone
- Tags: client type + documentation type + payment quality badge (e.g. "موثوق")
- Stats row (4 items):
  - **المدفوع:** Total amount paid across all debts
  - **المتبقي:** Total remaining across all debts
  - **عدد الديون:** Count of active installments + grace periods
  - **جودة السداد:** Payment quality score as percentage (e.g. 95%)

**Tab Navigation:**
- "الأقساط الشهرية" tab
- "المهل" tab

**Installments Tab — Installment Cards:**
Each card shows:
- Item/Service name with icon (car, phone, etc.)
- Duration: "X شهر متبقي"
- Monthly amount
- Status badge: جاري / مكتمل / متأخر X يوم
- Progress bar (paid percentage)

**Grace Periods Tab — Grace Period Cards:**
Each card shows:
- Grace period name/purpose with icon
- Due date
- Total amount (القيمة المستحقة)
- Status badge: جاري / مكتمل / متأخر X يوم
- "دفع المهلة" button

**FAB:** "إضافة +" → opens bottom sheet to choose: قسط شهري / قرض-سماح

**3-dot menu (top right):** Options: Edit Client / Delete Client

### 4.5 Add Record Bottom Sheet

When tapping "+" on client detail, show a bottom sheet with two options:
- **قسط شهري** (icon: document with list) — "إضافة صنف بدفعات شهرية"
- **قرض / سماح** (icon: bank building) — "إضافة قرض أو مبلغ مؤجل"

---

## 5. Installments Module (أقساط)

### 5.1 Add Installment Screen

**Client Info Banner (read-only at top):**
- Client name, tags (type + documentation), avatar

**Form Fields:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| تم سداد نسبة المكتب | Toggle: نعم / لا | Yes | Default: لا. Only shown for office clients. |
| اسم السلعة / الخدمة | Text input | Yes | e.g. "هاتف ذكي، أثاث..." |
| السعر الأساسي للسلعة (رأس المال) | Number input | Yes | Currency: SAR/EGP based on user locale |
| نسبتي (مبلغ الربح) | Number input | Yes | Fixed profit amount in currency (not %) |
| المدة (بالأشهر) | Button selector | Yes | Options: 3 / 6 / 9 / 12 / 24 |
| تاريخ البدء | Date picker | Yes | First installment month starts from this date |

**Live Summary Card (updates as user fills the form):**
- القسط الشهري: calculated automatically
- المدة الإجمالية: X شهر
- إجمالي المديونية: (capital + profit)

**Actions:**
- "حفظ القسط ✓" → validates, saves, generates payment schedule, navigates back
- Back arrow → discards

**Business Rule — Office Commission on Add:**
- If client is "عميل مكتب" AND admin sets "تم سداد نسبة المكتب" = نعم → record office commission as paid at creation time.
- If "لا" → office commission remains unpaid, button appears in installment detail for admin to mark later.

### 5.2 Installment Tracking Screen (تتبع الأقساط)

**Installment Header Card (blue/gradient):**
- Item/Service name + icon
- Client name + tags + documentation type
- القسط الشهري | مدة السداد | المدفوع/الإجمالي (e.g. 6/24)
- المدفوع: amount | المتبقي: amount
- Progress bar with percentage

**Payment Schedule Table (جدول الدفعات):**
One row per month, from month 1 to total months.

| Row | Label | Amount | Status Icon |
|-----|-------|--------|-------------|
| Month 1 | دفعة يناير + date | 2,500 | ✓ Green (paid) |
| Month 2 | دفعة فبراير + date | 2,500 | ⚠ Red (overdue) |
| Month 3 | دفعة مارس + date | 2,500 | ⏳ Yellow (current month) |
| Month 4+ | دفعة أبريل... | 2,500 | 📅 Gray (upcoming) |

**Status Colors:**
- Green ✓ = مدفوع
- Red ⚠ = متأخر
- Yellow ⏳ = الشهر الحالي (جاري)
- Gray 📅 = لم يحن موعده

**Edit icon (pencil, top right):** Visible only if no payments have been made yet.

### 5.3 Edit Installment

Allowed **only before the first payment is made**. Once any payment is recorded, editing is disabled.

Fields editable: same as Add Installment form (all fields).

---

## 6. Grace Periods Module (مهل)

### 6.1 Add Grace Period Screen

**Client Info Banner (read-only at top):**
- Client name, tags, avatar

**Form Fields:**
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| تم سداد نسبة المكتب | Toggle: نعم / لا | Yes | Default: لا. Only for office clients. |
| اسم المهلة / الغرض | Text input | Yes | e.g. "مهلة سيارة، سلفة شخصية" |
| المبلغ الإجمالي (رأس المال) | Number input | Yes | Total amount to be repaid |
| تاريخ الإصدار | Date picker | Yes | The due date for payment (set by admin) |
| ملاحظات إضافية | Textarea | No | Free text |

**Actions:**
- "حفظ المهلة" → saves and navigates back
- "إلغاء" → discards

### 6.2 Grace Period View (within Client Detail)

Lists all grace periods for a client. Each card shows:
- Grace period name
- Due date (تاريخ الإصدار)
- القيمة المستحقة (full amount)
- Status: جاري / مدفوع / متأخر X يوم
- "دفع المهلة" button

**FAB:** "إضافة مهلة +" → navigates to Add Grace Period

### 6.3 Edit Grace Period

Allowed **only before payment is made**. Once the grace period is paid, editing is disabled.

---

## 7. Payments & Tracking Module

### 7.1 Accounts Screen (الحسابات)

This is the main payment processing screen — a unified list of all due/upcoming payments.

**Top Filters:**
- **Type tabs:** الكل | الأقساط | المهل
- **Date range:** من شهر / إلى شهر (month pickers)
- **Client type:** الكل | عميل مكتب | عميل خاص

**Status Summary Chips (counts):**
- متأخر: X (red)
- جاري: X (yellow/gold)
- مدفوع: X (green)

**Payment Card (per due payment):**
- Client name + avatar
- Item/service name + type badge (قسط / مهل)
- Amount due
- Due date OR "Paid on [date]" for paid ones
- Status badge: متأخر ▲ / جاري ⏳ / مدفوع ✓
- Action button:
  - "دفع القسط" (for installments)
  - "دفع المهلة" (for grace periods)
  - Button is **disabled / hidden** if already paid

**Search icon (top right):** Filter by client name

### 7.2 Pay Installment Flow

When admin taps "دفع القسط":
1. Show confirmation dialog:
   - "هل تريد تأكيد دفع قسط [Item Name] لـ [Client Name]؟"
   - Amount shown
   - Confirm / Cancel buttons
2. On confirm:
   - Mark that month's installment payment as `paid`
   - Record `paidDate` = today
   - Update `client.totalPaid` += amount
   - Update `client.totalRemaining` -= amount
   - Create a transaction record
   - Update dashboard aggregates

### 7.3 Pay Grace Period Flow

When admin taps "دفع المهلة":
1. Show confirmation dialog: "هل تريد تأكيد سداد مهلة [Name]؟"
2. On confirm:
   - Mark grace period as `paid`
   - Record `paidDate` = today
   - Update client totals
   - Create transaction record
   - Update dashboard aggregates

### 7.4 Office Commission Flow

For office clients, on each installment or grace period detail:
- Show "نسبة المكتب" section with amount (10% of capital)
- If not yet paid → show "دفع نسبة المكتب" button
- On tap → show confirmation dialog: "هل تريد تأكيد دفع نسبة المكتب؟ المبلغ: [X]"
- On confirm → mark `officeCommissionPaid = true`, record timestamp

**Commission Calculation:**
```
officeCommission = capital × 10%
```
- Applies to both installments and grace periods
- Only for office clients
- Paid **once per installment/grace period**
- Can be reversed (treated as a transaction)

### 7.5 Payment Statuses

**Installment Payment Statuses:**

| Status | Condition |
|--------|-----------|
| `upcoming` | Due date is in the future AND today is not yet past day 10 of due month |
| `current` | Current month's payment, day ≤ 10 |
| `paid` | Payment has been recorded |
| `overdue` | Day 10 of due month has passed and payment not made |
| `reversed` | Payment was made then reversed (audit only) |

**Grace Period Statuses:**

| Status | Condition |
|--------|-----------|
| `upcoming` | Due date is in the future |
| `grace_window` | Due date passed, within 10-day grace window |
| `overdue` | 10 days after due date passed, not paid |
| `paid` | Has been paid |
| `reversed` | Payment reversed (audit only) |

**Overdue Display:**
- Show: "متأخر X يوم" where X = (today - due date) in days

---

## 8. Dashboard Module

**Screen:** لوحة التحكم

### 8.1 Header
- Greeting: "صباح الخير / مساء الخير، [User Name]"
- Profile avatar icon (top left)
- Sun/moon icon (top right) based on time of day

### 8.2 Main Collection Card (large hero card)
- Title: "المحصل هذا الشهر"
- Large amount display: actual total collected this calendar month
- Progress bar: (collected / target) %
- Progress percentage label (e.g. "67%")
- "الهدف: [amount]" label

### 8.3 Stats Grid (2×2)

| Metric | Calculation |
|--------|-------------|
| **إجمالي الأرباح** | Sum of profit amounts from all **installments** that have at least one paid payment (only profit portion, not capital). Accumulates over all time. |
| **إجمالي رأس المال** | Sum of `capital` field from ALL installments and grace periods ever added |
| **نسبة المكتب** | Sum of all office commission amounts that have been paid (across all time) |
| **إجمالي العملاء** | Count of active clients |

### 8.4 Recent Transactions (آخر المعاملات)

- Last 5–10 transactions (newest first)
- Each row: client avatar + name | transaction type + relative time | amount (green with +)
- Transaction types: "قسط شهري", "دفعة مقدمة", "تسفية حساب", etc.
- Tapping a row → navigates to the relevant client detail

### 8.5 Dashboard Calculations Detail

**Monthly Collection (المحصل):**
```
= Sum of all payments (installment + grace period) 
  where paidDate is within current calendar month
  AND transaction status ≠ 'reversed'
```

**Monthly Target (الهدف):**
```
= Sum of all expected payments due in current calendar month
  (each active installment has one payment due per month on day 10)
  + Sum of all grace periods with due date in current month
```

**Total Profits (إجمالي الأرباح):**
```
profitPerPayment = profitAmount / durationMonths   ← stored on installment at creation

Each time a monthly installment payment is marked as paid:
  recognizedProfit += profitPerPayment

totalProfits = sum of recognizedProfit across all installments
```
Profit is recognized incrementally — one slice per paid monthly payment.

**Total Capital (إجمالي رأس المال):**
```
= Sum of capital field across ALL installments + ALL grace periods
  (regardless of payment status — represents total money deployed)
```

---

## 9. Accounts & Reports Module

**Screen:** الحسابات (with date range filter active)

### 9.1 Date Range Filter
- "من شهر" date picker (month + year)
- "إلى شهر" date picker (month + year)
- Applies to the transactions table and overdue clients table

### 9.2 Transactions Table

Shows all financial activity within the selected date range:

| Column | Description |
|--------|-------------|
| العميل | Client name |
| النوع | Payment type (قسط / مهلة / نسبة مكتب) |
| المبلغ | Amount |
| التاريخ | Payment date |
| الحالة | مكتمل / محول (reversed) |

- Reversed transactions appear with strikethrough or "محول" badge — never hidden
- Filter by: الكل / الأقساط / المهل

### 9.3 Overdue Clients Table (separate section below)

Appears only if there are overdue clients within the selected period.

Title: "العملاء المتأخرون"

| Column | Description |
|--------|-------------|
| العميل | Client name |
| المبلغ المتأخر | Amount overdue |
| منذ | Days overdue |
| النوع | قسط / مهلة |

- Sorted by most days overdue (descending)

### 9.4 Summary Totals (at top of report)

- إجمالي المحصل في الفترة
- إجمالي الأرباح في الفترة
- عدد العمليات

---

## 10. Settings Module

### 10.1 Settings Screen

**Profile Header:**
- User avatar + name + email
- PRO badge (if applicable)

**Preferences Section:**
- اللغة: Arabic (العربية) — with chevron to change
- الوضع الليلي: Toggle (dark/light mode)

**Account Section:**
- إعدادات الحساب → navigates to Edit Account screen
- تغيير كلمة المرور → navigates to password change within Edit Account

**Logout:**
- "تسجيل الخروج" button (red/destructive style)
- Show confirmation dialog before logging out

### 10.2 Bottom Navigation Bar (Persistent)

4 tabs visible across all main screens:

| Icon | Label | Screen |
|------|-------|--------|
| Grid/Dashboard | لوحة التحكم | Dashboard |
| Person group | العملاء | Client List |
| Card/Wallet | الحسابات | Accounts |
| Gear | الإعدادات | Settings |

---

## 11. Business Rules & Calculations

### 11.1 Installment Formula

```
monthlyInstallment = (capital + profitAmount) / durationMonths

totalDebt = capital + profitAmount
```

- `capital`: The base price of the item/service (رأس المال / السعر الأساسي)
- `profitAmount`: Fixed profit amount entered by admin (نسبتي) — NOT a percentage
- `durationMonths`: Selected from [3, 6, 9, 12, 24]

**Example:**
```
capital = 25,000 SAR
profitAmount = 5,000 SAR
durationMonths = 12

monthlyInstallment = (25,000 + 5,000) / 12 = 2,500 SAR
totalDebt = 30,000 SAR
```

### 11.2 Payment Due Date (Installments)

- Each installment has monthly payments due on **day 10** of each month
- First payment: day 10 of the month AFTER the start date
  - Example: start date = 01 Nov 2023 → first payment due = 10 Dec 2023
- Payment schedule is generated at creation: [due date month 1, month 2, ..., month N]

### 11.3 Installment Payment Status Logic

```
For each monthly payment:

IF paidDate is set → status = 'paid'

ELSE IF today.day > 10 AND today.month == dueMonth AND today.year == dueYear:
  → status = 'overdue'

ELSE IF today.month == dueMonth AND today.year == dueYear AND today.day <= 10:
  → status = 'current'

ELSE IF dueDate > today:
  → status = 'upcoming'

ELSE (due date in past month, not paid):
  → status = 'overdue'
```

### 11.4 Grace Period Status Logic

```
gracePeriodDueDate = admin-set date (تاريخ الإصدار)
gracePeriodEndDate = gracePeriodDueDate + 10 days

IF paidDate is set → status = 'paid'

ELSE IF today <= gracePeriodDueDate → status = 'upcoming'

ELSE IF today > gracePeriodDueDate AND today <= gracePeriodEndDate:
  → status = 'grace_window' (display as 'جاري', not yet overdue)

ELSE IF today > gracePeriodEndDate → status = 'overdue'
  daysOverdue = today - gracePeriodEndDate
  display: "متأخر X يوم"
```

### 11.5 Client Payment Quality Score

```
qualityScore (%) = (onTimePayments / totalDuePayments) × 100

For INSTALLMENTS:
  onTimePayment = paidDate.day <= 10 of the due month

For GRACE PERIODS:
  onTimePayment = paidDate <= (gracePeriodDueDate + 10 days)
  — i.e., the 10-day grace window also serves as the on-time quality window

totalDuePayments = count of all payments that have passed their due date
  (paid or overdue — NOT upcoming)
```

**Display thresholds (optional badges):**
- 90–100% → "موثوق" (trusted, green)
- 70–89% → "جيد" (good, yellow)
- < 70% → "ضعيف" (weak, red)

### 11.6 Office Commission Rule

```
officeCommission = capital × 10%

Applies when:
  - client.type == 'office'
  - Per each installment OR grace period (calculated on capital only)
  - Collected ONCE per debt record (not monthly)
  - Triggered by admin pressing "دفع نسبة المكتب" button
  - Before pressing: system shows confirmation dialog
  - After pressing: officeCommissionPaid = true, amount recorded in transactions
```

**Private clients:** No office commission. The "تم سداد نسبة المكتب" field is hidden on the add form.

### 11.7 Edit Restriction Rule

```
canEdit(record) = (record.paidPaymentsCount == 0)

For installments: paidPaymentsCount = count of months where status == 'paid'
For grace periods: paidPaymentsCount = 1 if status == 'paid', else 0
```

Once any payment is recorded → the record is locked for editing.

### 11.8 Installment Completion

```
installment.status = 'completed' when:
  ALL monthly payments have status == 'paid'
```

---

## 12. Payment Reversal Rules

### 12.1 Who Can Reverse

Only the admin (owner) can reverse a payment. Available via a "عكس الدفع" or "تراجع" option in the transaction detail or installment tracking screen.

### 12.2 Reversal Constraints

- Only the **most recent payment** per installment or grace period can be reversed.
- A reversed transaction can **never** be deleted — it remains in audit history with status `'reversed'`.

### 12.3 Reversal Atomic Operation

When a payment is reversed, ALL of the following must happen atomically (Firestore transaction):

1. **Reset payment status:**
   - Installment monthly payment: set back to `'overdue'` if past day 10, else `'upcoming'`
   - Grace period: set back to `'overdue'` if past grace window, else `'upcoming'`

2. **Update client totals:**
   - `client.totalPaid` -= reversedAmount
   - `client.totalRemaining` += reversedAmount

3. **Mark transaction as reversed:**
   - `transaction.status = 'reversed'`
   - `transaction.reversedAt = now()`
   - Never delete the transaction document

4. **Update dashboard aggregates:**
   - If `transaction.yearMonth == currentYearMonth`:
     - `dashboard_aggregates.monthlyCollection` -= reversedAmount

### 12.4 Reversed Transaction Display

- Visible in Accounts/Reports screen with "محول" (reversed) badge
- Excluded from all financial calculations (profits, totals, monthly collection)
- Included in audit history with original amount + reversal timestamp

### 12.5 Office Commission Reversal

Office commission can also be reversed using the same rules:
- `officeCommissionPaid` resets to `false`
- Transaction marked as `'reversed'`
- Dashboard office commission total updated

---

## 13. Navigation Structure

```
App
├── Auth Flow (not authenticated)
│   ├── Login Screen
│   ├── Register Screen
│   ├── Forgot Password Screen
│   └── Email Sent Confirmation Screen
│
└── Main App (authenticated) — Bottom Nav: 4 tabs
    ├── [Tab 1] Dashboard (لوحة التحكم)
    │
    ├── [Tab 2] Clients (العملاء)
    │   ├── Client List
    │   │   └── Add New Client
    │   └── Client Detail
    │       ├── [Tab A] Monthly Installments
    │       │   ├── Add Installment
    │       │   ├── Installment Tracking (تتبع)
    │       │   └── Edit Installment (if no payments)
    │       └── [Tab B] Grace Periods
    │           ├── Add Grace Period
    │           └── Edit Grace Period (if not paid)
    │
    ├── [Tab 3] Accounts (الحسابات)
    │   ├── Payment List (All / Installments / Grace Periods)
    │   │   ├── Pay Installment (confirmation dialog)
    │   │   └── Pay Grace Period (confirmation dialog)
    │   └── Date-filtered Report View
    │
    └── [Tab 4] Settings (الإعدادات)
        ├── Edit Account
        └── Change Password
```

---

## 14. Data Entities Summary (for Schema Reference)

| Entity | Key Fields |
|--------|-----------|
| **User** | uid, displayName, email, photoURL, createdAt |
| **Client** | id, userId, fullName, phone, gender, documentationType, clientType, notes, totalPaid, totalRemaining, activeDebtsCount, paymentQualityScore, createdAt |
| **Installment** | id, clientId, userId, itemName, capital, profitAmount, monthlyAmount, totalDebt, durationMonths, startDate, officeCommissionPaid, officeCommissionAmount, editLocked, status, createdAt |
| **InstallmentPayment** | id, installmentId, clientId, userId, dueDate, dueMonth, dueYear, status, paidDate, amount |
| **GracePeriod** | id, clientId, userId, name, capital, dueDate, officeCommissionPaid, officeCommissionAmount, status, paidDate, notes, editLocked, createdAt |
| **Transaction** | id, userId, clientId, relatedId, relatedType (installment/grace/commission), amount, type, status, paidDate, yearMonth, reversedAt, createdAt |
| **DashboardAggregates** | userId, yearMonth, monthlyCollection, monthlyTarget, totalProfits, totalCapital, totalOfficeCommission, totalClients |

---

*End of Business Requirements Document v1.0*
