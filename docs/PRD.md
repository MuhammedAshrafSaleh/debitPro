# Product Requirements Document (PRD)
## DebtPro — نظام إدارة الأقساط والمهل

**Version:** 1.0  
**App Name:** DebtPro  
**Platform:** Flutter (iOS + Android)  
**Architecture:** Clean Architecture  
**State Management:** Cubit / Bloc  
**Backend:** Firebase (Auth + Firestore)  
**Languages:** Arabic (AR) + English (EN)  
**Themes:** Dark + Light

---

## 1. Tech Stack & Architecture

### 1.1 Flutter Clean Architecture Layers

```
lib/
├── core/
│   ├── constants/
│   ├── errors/           # Failures + Exceptions
│   ├── usecases/         # Base UseCase class
│   ├── utils/
│   └── di/               # Dependency Injection (get_it + injectable)
│
├── config/
│   ├── themes/           # AppTheme, DarkColors, LightColors, AppTypography
│   ├── routes/           # GoRouter setup
│   └── l10n/             # ARB files (ar, en)
│
└── features/
    ├── auth/
    ├── clients/
    ├── installments/
    ├── grace_periods/
    ├── payments/
    ├── dashboard/
    ├── accounts/
    └── settings/
```

**Each feature follows:**
```
feature/
├── data/
│   ├── datasources/      # Firebase calls
│   ├── models/           # JSON serializable models
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Pure Dart classes
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # One class per use case
└── presentation/
    ├── cubit/            # XxxCubit + XxxState
    ├── pages/
    └── widgets/
```

### 1.2 Key Packages

```yaml
dependencies:
  # Firebase
  firebase_core:
  firebase_auth:
  cloud_firestore:
  google_sign_in:

  # State Management
  flutter_bloc:

  # DI
  get_it:
  injectable:

  # Navigation
  go_router:

  # Localization
  flutter_localizations:
  intl:

  # Utils
  dartz:              # Either<Failure, Success>
  equatable:          # State comparison
  uuid:               # ID generation
  shared_preferences: # Theme + language persistence

dev_dependencies:
  injectable_generator:
  build_runner:
  flutter_gen:        # Assets generation
```

### 1.3 State Management Rules

- **Cubit** → all standard screens (simple state: loading / loaded / error)
- **Bloc** → complex flows with multiple events (e.g. payment flow with confirmation + reversal)
- Every Cubit/Bloc emits states that extend `Equatable`

---

## 2. Theming

### 2.1 Theme System

The app supports **Dark** and **Light** themes, language-aware typography.

```dart
// Already implemented — use as-is:
AppTheme.dark(languageCode: 'ar')
AppTheme.light(languageCode: 'ar')
```

Theme preference persisted in `SharedPreferences` key: `app_theme` (`dark` | `light`)

### 2.2 Dark Theme Colors (`DarkColors`)

| Token | Usage | Hex |
|-------|-------|-----|
| `primary` | Buttons, active tabs, progress | `#3B82F6` (blue) |
| `surface` | Cards, bottom sheets | `#1E1E2E` |
| `base` (scaffold) | Page background | `#12121A` |
| `error` | Overdue badges, destructive actions | `#EF4444` |
| `tertiary` | "جاري" / current month badge | `#F59E0B` (amber) |
| `secondary` | "مدفوع" / paid badge | `#10B981` (green) |

### 2.3 Light Theme Colors (`LightColors`)

| Token | Usage | Hex |
|-------|-------|-----|
| `primary` | Deep navy | `#1E3A5F` |
| `surface` | Cards | `#FFFFFF` |
| `base` (scaffold) | Page background | `#F1F5F9` |
| `error` | Overdue | `#DC2626` |

### 2.4 Typography (`AppTypography`)

```dart
AppTypography.forLocale(languageCode)
// 'ar' → Cairo or Tajawal font
// 'en' → Inter or Poppins font
```

---

## 3. Localization

### 3.1 Setup

- Flutter ARB files: `lib/config/l10n/app_ar.arb` + `lib/config/l10n/app_en.arb`
- Language preference persisted in `SharedPreferences` key: `app_language` (`ar` | `en`)
- Default language: `ar`
- RTL automatically applied when language = `ar`

### 3.2 Language Switch

Available in Settings screen. Changing language:
1. Updates `SharedPreferences`
2. Calls `context.setLocale()` (or equivalent)
3. Rebuilds the entire widget tree with new locale + typography

### 3.3 Number & Date Formatting

- Numbers: locale-aware (`intl` package) — Arabic uses Western numerals (0-9) not Hindi
- Dates: displayed as `dd MMM yyyy` in both locales
- Currency: displayed based on user's input (SAR / EGP / etc.) — stored as plain number in Firestore

---

## 4. UX Standards

### 4.1 Loading States — REQUIRED on every async operation

Every operation that hits Firebase must show a loading indicator.

| Operation Type | Loading UI |
|----------------|-----------|
| Full page load | `CircularProgressIndicator` centered on page |
| Button action (save, pay) | Replace button text with `CircularProgressIndicator` + disable button |
| List refresh | `RefreshIndicator` (pull-to-refresh) |
| Background sync | Subtle linear progress bar at top of screen |

**Rule:** Never let the user tap a button twice during an async operation. Disable all interactive elements while loading.

### 4.2 Feedback States — REQUIRED after every operation

Every operation result (success or failure) must surface to the user.

| Result | UI | Duration |
|--------|-----|---------|
| ✅ Success | `SnackBar` (green, bottom) | 3 seconds |
| ❌ Error | `SnackBar` (red, bottom) with error message | 4 seconds |
| ⚠️ Confirmation required | `AlertDialog` (modal) with Confirm + Cancel | Until dismissed |
| 💬 Destructive action | `BottomSheet` confirmation | Until dismissed |

**Confirmation dialogs required for:**
- Pay installment / grace period
- Pay office commission
- Reverse a payment
- Delete a client
- Logout

**SnackBar examples:**
```
✅ "تم تسجيل دفعة يناير بنجاح"
✅ "تم حفظ العميل بنجاح"
❌ "حدث خطأ، يرجى المحاولة مجدداً"
❌ "لا يمكن التعديل بعد إتمام الدفعة الأولى"
```

### 4.3 Empty States

Every list screen must handle empty state with:
- Illustrative icon
- Arabic + English message
- Action button if applicable (e.g. "أضف أول عميل")

### 4.4 Avatar Generation

No image uploads. Avatars are generated from client/user name initials.

```dart
// Logic:
String initials = name.split(' ').take(2).map((w) => w[0]).join();
// "أحمد محمود" → "أم"
// "سارة عبدالله" → "سع"

Color avatarColor = _colorFromString(clientId); // deterministic from ID
```

Color palette for avatars: 8 preset colors cycled by hash of the ID.

---

## 5. Navigation (GoRouter)

### 5.1 Route Structure

```dart
/                         → redirect → /login OR /dashboard
/login                    → LoginPage
/register                 → RegisterPage
/forgot-password          → ForgotPasswordPage
/forgot-password/sent     → EmailSentPage

/dashboard                → DashboardPage        [auth required]
/clients                  → ClientListPage       [auth required]
/clients/add              → AddClientPage        [auth required]
/clients/:clientId        → ClientDetailPage     [auth required]
/clients/:clientId/edit   → EditClientPage       [auth required]

/installments/add/:clientId         → AddInstallmentPage
/installments/:installmentId        → InstallmentTrackingPage
/installments/:installmentId/edit   → EditInstallmentPage

/grace-periods/add/:clientId        → AddGracePeriodPage
/grace-periods/:gracePeriodId/edit  → EditGracePeriodPage

/accounts                 → AccountsPage         [auth required]
/settings                 → SettingsPage         [auth required]
/settings/edit-account    → EditAccountPage      [auth required]
```

### 5.2 Auth Guard

GoRouter `redirect` checks `FirebaseAuth.instance.currentUser`:
- null → redirect to `/login`
- authenticated → allow through

### 5.3 Bottom Navigation

Persistent bottom nav on all main screens (after auth):

```
[لوحة التحكم] [العملاء] [الحسابات] [الإعدادات]
```

Managed by a `ShellRoute` in GoRouter.

---

## 6. Feature Specifications

### 6.1 Auth Feature

**Cubits:**
- `LoginCubit` → states: `LoginInitial` | `LoginLoading` | `LoginSuccess` | `LoginError(message)`
- `RegisterCubit` → states: same pattern
- `ForgotPasswordCubit` → states: `Initial` | `Loading` | `EmailSent` | `Error`

**Use Cases:**
- `SignInWithEmailUseCase`
- `SignInWithGoogleUseCase`
- `RegisterUseCase`
- `SendPasswordResetEmailUseCase`
- `SignOutUseCase`

**Firebase:**
- Email/Password auth
- Google OAuth
- Password reset via email

---

### 6.2 Clients Feature

**Cubits:**
- `ClientListCubit` → states: `Loading` | `Loaded(clients, filter)` | `Error`
- `ClientDetailCubit` → states: `Loading` | `Loaded(client, installments, gracePeriods)` | `Error`
- `AddClientCubit` → states: `Initial` | `Saving` | `Saved` | `Error`

**Use Cases:**
- `GetClientsUseCase` (with optional filter)
- `GetClientDetailUseCase`
- `AddClientUseCase`
- `EditClientUseCase`
- `DeleteClientUseCase`

**Client List Filters:**
```dart
enum ClientFilter { all, electronic, paper, office }
```

**Client Status (computed, not stored):**
```dart
// Shown on list card
bool isCurrentMonthSettled(Client client, List<Payment> paymentsThisMonth) {
  return paymentsThisMonth
    .where((p) => p.clientId == client.id)
    .every((p) => p.status == PaymentStatus.paid);
}
```

---

### 6.3 Installments Feature

**Cubits:**
- `AddInstallmentCubit` → states: `Initial` | `Saving` | `Saved` | `Error`
- `InstallmentTrackingCubit` → states: `Loading` | `Loaded(installment, payments)` | `Error`

**Use Cases:**
- `AddInstallmentUseCase`
- `EditInstallmentUseCase`
- `GetInstallmentWithPaymentsUseCase`
- `PayOfficeCommissionUseCase`

**Formula (computed in UseCase, never in UI):**
```dart
double monthlyAmount = (capital + profitAmount) / durationMonths;
double totalDebt = capital + profitAmount;
double profitPerPayment = profitAmount / durationMonths;
double officeCommission = clientType == 'office' ? capital * 0.10 : 0;
```

**Payment Schedule Generation:**
On `AddInstallmentUseCase`, generate N payment documents atomically:
```dart
// First payment due = day 10 of month AFTER startDate
DateTime firstDue = DateTime(startDate.year, startDate.month + 1, 10);

for (int i = 0; i < durationMonths; i++) {
  payments.add(Payment(
    dueDate: DateTime(firstDue.year, firstDue.month + i, 10),
    dueMonth: '${firstDue.year}-${(firstDue.month + i).toString().padLeft(2, '0')}',
    monthIndex: i + 1,
    amount: monthlyAmount,
    profitPortion: profitPerPayment,
    status: PaymentStatus.upcoming,
  ));
}
```

---

### 6.4 Grace Periods Feature

**Cubits:**
- `AddGracePeriodCubit`
- `GracePeriodListCubit`

**Use Cases:**
- `AddGracePeriodUseCase`
- `EditGracePeriodUseCase`
- `PayGracePeriodUseCase`

**Grace Period End Date:**
```dart
DateTime gracePeriodEndDate = dueDate.add(const Duration(days: 10));
```

---

### 6.5 Payments Feature

**Bloc (not Cubit — multiple events):**
- `PaymentBloc`

**Events:**
```dart
class LoadPaymentsEvent extends PaymentEvent {
  final PaymentFilter filter; // type, dateRange, clientType
}
class PayInstallmentPaymentEvent extends PaymentEvent {
  final String paymentId;
  final String installmentId;
  final String clientId;
}
class PayGracePeriodEvent extends PaymentEvent {
  final String gracePeriodId;
  final String clientId;
}
class ReversePaymentEvent extends PaymentEvent {
  final String transactionId;
  final String relatedId;
  final PaymentType relatedType;
}
```

**States:**
```dart
PaymentInitial | PaymentLoading | PaymentLoaded(payments, gracePeriods, summary)
| PaymentActionLoading | PaymentActionSuccess(message) | PaymentActionError(message)
```

**Status Refresh on App Open:**
```dart
// Run on app start — no Cloud Functions needed
class RefreshPaymentStatusesUseCase {
  // Query all payments where status IN [upcoming, current]
  // AND dueDate < now()
  // Update to 'overdue' in batch writes
  
  // Query all gracePeriods where status IN [upcoming, grace_window]
  // Recompute status based on dueDate + 10 days vs today
  // Update in batch writes
}
```

**Payment Status Computation:**
```dart
PaymentStatus computeInstallmentPaymentStatus(DateTime dueDate) {
  final now = DateTime.now();
  if (now.year == dueDate.year && now.month == dueDate.month) {
    return now.day <= 10 ? PaymentStatus.current : PaymentStatus.overdue;
  }
  return now.isAfter(dueDate) ? PaymentStatus.overdue : PaymentStatus.upcoming;
}

GracePeriodStatus computeGracePeriodStatus(DateTime dueDate) {
  final now = DateTime.now();
  final endDate = dueDate.add(const Duration(days: 10));
  if (now.isBefore(dueDate) || now.isAtSameMomentAs(dueDate)) return GracePeriodStatus.upcoming;
  if (now.isBefore(endDate) || now.isAtSameMomentAs(endDate)) return GracePeriodStatus.graceWindow;
  return GracePeriodStatus.overdue;
}
```

---

### 6.6 Dashboard Feature

**Cubit:**
- `DashboardCubit` → states: `Loading` | `Loaded(DashboardData)` | `Error`

**DashboardData entity:**
```dart
class DashboardData {
  final double monthlyCollection;   // from aggregates/monthly/{currentYearMonth}
  final double monthlyTarget;       // computed on load from payments + grace periods
  final double collectionProgress;  // monthlyCollection / monthlyTarget (0.0–1.0)
  final double totalProfits;        // from aggregates/allTime
  final double totalCapital;        // from aggregates/allTime
  final double totalOfficeCommission; // from aggregates/allTime
  final int totalClients;           // from aggregates/allTime
  final List<Transaction> recentTransactions; // last 10
}
```

**Monthly Target computation:**
```dart
// On dashboard load, run TWO queries in parallel:
final paymentsThisMonth = firestore
  .collection('users/$uid/payments')
  .where('dueMonth', isEqualTo: currentYearMonth)
  .get();

final gracePeriodsThisMonth = firestore
  .collection('users/$uid/gracePeriods')
  .where('dueDate', isGreaterThanOrEqualTo: firstDayOfMonth)
  .where('dueDate', isLessThanOrEqualTo: lastDayOfMonth)
  .get();

monthlyTarget = sumAmounts(paymentsThisMonth) + sumCapital(gracePeriodsThisMonth);
```

---

### 6.7 Accounts Feature

**Cubit:**
- `AccountsCubit` → states: `Loading` | `Loaded(AccountsData)` | `Error`

**AccountsData:**
```dart
class AccountsData {
  final List<Transaction> transactions;
  final List<OverdueClient> overdueClients;
  final double totalCollected;
  final double totalProfits;
  final int operationsCount;
}
```

**Filters:**
```dart
class AccountsFilter {
  final String? fromMonth;    // "YYYY-MM"
  final String? toMonth;      // "YYYY-MM"
  final String? clientType;   // 'office' | 'private' | null
  final String? paymentType;  // 'installment' | 'grace_period' | null
}
```

**Overdue Clients query:**
```dart
// Clients with any overdue payment in the selected period
final overduePayments = firestore
  .collection('users/$uid/payments')
  .where('status', isEqualTo: 'overdue')
  .where('dueMonth', isGreaterThanOrEqualTo: fromMonth)
  .where('dueMonth', isLessThanOrEqualTo: toMonth)
  .get();
```

---

### 6.8 Settings Feature

**Cubits:**
- `SettingsCubit` → manages theme + language state
- `EditAccountCubit` → states for profile update + password change

**Use Cases:**
- `UpdateDisplayNameUseCase`
- `UpdateEmailUseCase`
- `UpdatePasswordUseCase`
- `ToggleThemeUseCase`
- `ChangeLanguageUseCase`
- `SignOutUseCase`

---

## 7. Error Handling

### 7.1 Failure Classes

```dart
abstract class Failure extends Equatable {}

class ServerFailure extends Failure { final String message; }
class NetworkFailure extends Failure {}
class AuthFailure extends Failure { final String code; }
class PermissionFailure extends Failure {}
class ValidationFailure extends Failure { final String field; final String message; }
class EditLockedFailure extends Failure {}     // Tried to edit after first payment
class AlreadyPaidFailure extends Failure {}   // Tried to pay already-paid item
```

### 7.2 Repository Pattern

All repository methods return `Either<Failure, T>` (dartz):

```dart
Future<Either<Failure, void>> payInstallment(PayInstallmentParams params);
Future<Either<Failure, List<Client>>> getClients(ClientFilter filter);
```

### 7.3 Firebase Error Mapping

```dart
// In datasource catch blocks:
on FirebaseAuthException catch (e) {
  throw AuthException(e.code);  // mapped to AuthFailure in repository
}
on FirebaseException catch (e) {
  throw ServerException(e.message ?? 'Unknown error');
}
on SocketException {
  throw NetworkException();
}
```

---

## 8. Offline Behavior

- Firestore offline persistence enabled by default in Flutter SDK
- App works read-only when offline
- Writes queue automatically and sync when back online
- Show offline banner (non-blocking) when `Connectivity` detects no network

```dart
// Enable persistence (call once at app startup)
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

---

## 9. Atomic Operations (Implementation)

All multi-document writes MUST use `WriteBatch` or `runTransaction`:

```dart
// Example: Pay installment payment
Future<void> payInstallmentPayment(...) async {
  await firestore.runTransaction((transaction) async {
    // 1. Update payment status
    transaction.update(paymentRef, { 'status': 'paid', 'paidDate': now });
    // 2. Update installment progress
    transaction.update(installmentRef, {
      'paidPaymentsCount': FieldValue.increment(1),
      'totalPaidAmount': FieldValue.increment(amount),
      'recognizedProfit': FieldValue.increment(profitPortion),
      'editLocked': true,
    });
    // 3. Update client totals
    transaction.update(clientRef, {
      'totalPaid': FieldValue.increment(amount),
      'totalRemaining': FieldValue.increment(-amount),
      'totalDuePaymentsCount': FieldValue.increment(1),
      'onTimePaymentsCount': FieldValue.increment(isOnTime ? 1 : 0),
    });
    // 4. Create transaction record
    transaction.set(transactionRef, transactionDoc);
    // 5. Update monthly aggregate
    transaction.set(monthlyAggRef, {
      'monthlyCollection': FieldValue.increment(amount),
      'updatedAt': now,
    }, SetOptions(merge: true));
    // 6. Update all-time aggregate
    transaction.update(allTimeAggRef, {
      'totalRecognizedProfit': FieldValue.increment(profitPortion),
    });
  });
}
```

---

## 10. Status Refresh on App Start

Run once when authenticated user opens the app (not on every navigation):

```dart
class RefreshPaymentStatusesUseCase {
  Future<void> call() async {
    final now = DateTime.now();
    final batch = firestore.batch();
    int writeCount = 0;

    // --- Installment payments ---
    final stalePayments = await firestore
      .collection('users/$uid/payments')
      .where('status', whereIn: ['upcoming', 'current'])
      .get();

    for (final doc in stalePayments.docs) {
      final dueDate = (doc['dueDate'] as Timestamp).toDate();
      final newStatus = computeInstallmentPaymentStatus(dueDate);
      if (newStatus.name != doc['status']) {
        batch.update(doc.reference, {'status': newStatus.name});
        writeCount++;
        if (writeCount == 499) { await batch.commit(); writeCount = 0; }
      }
    }

    // --- Grace periods ---
    final staleGrace = await firestore
      .collection('users/$uid/gracePeriods')
      .where('status', whereIn: ['upcoming', 'grace_window'])
      .get();

    for (final doc in staleGrace.docs) {
      final dueDate = (doc['dueDate'] as Timestamp).toDate();
      final newStatus = computeGracePeriodStatus(dueDate);
      if (newStatus.name != doc['status']) {
        batch.update(doc.reference, {'status': newStatus.name});
        writeCount++;
      }
    }

    await batch.commit();
  }
}
```

> Batch limit = 500 writes. The loop above handles chunking automatically.

---

## 11. Project Folder Structure (Full)

```
lib/
├── main.dart
├── firebase_options.dart
│
├── core/
│   ├── constants/
│   │   ├── firestore_paths.dart    // all collection paths as constants
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── usecases/
│   │   └── usecase.dart            // abstract UseCase<Type, Params>
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── avatar_utils.dart       // initials + color generation
│   │   ├── currency_utils.dart
│   │   └── status_utils.dart       // payment status computation
│   └── di/
│       ├── injection.dart
│       └── injection.config.dart   // generated
│
├── config/
│   ├── themes/
│   │   ├── app_theme.dart          // provided code (dark + light)
│   │   ├── dark_colors.dart
│   │   ├── light_colors.dart
│   │   └── app_typography.dart
│   ├── routes/
│   │   └── app_router.dart         // GoRouter config
│   └── l10n/
│       ├── app_ar.arb
│       └── app_en.arb
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/firebase_auth_datasource.dart
    │   │   ├── models/user_model.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/app_user.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/
    │   │       ├── sign_in_with_email_usecase.dart
    │   │       ├── sign_in_with_google_usecase.dart
    │   │       ├── register_usecase.dart
    │   │       ├── send_password_reset_usecase.dart
    │   │       └── sign_out_usecase.dart
    │   └── presentation/
    │       ├── cubit/
    │       │   ├── login_cubit.dart
    │       │   ├── login_state.dart
    │       │   ├── register_cubit.dart
    │       │   └── forgot_password_cubit.dart
    │       └── pages/
    │           ├── login_page.dart
    │           ├── register_page.dart
    │           ├── forgot_password_page.dart
    │           └── email_sent_page.dart
    │
    ├── clients/         // same structure
    ├── installments/    // same structure
    ├── grace_periods/   // same structure
    ├── payments/        // same structure (uses Bloc)
    ├── dashboard/       // same structure
    ├── accounts/        // same structure
    └── settings/        // same structure
```

---

## 12. Localization Keys (Sample — app_ar.arb)

```json
{
  "@@locale": "ar",
  "appName": "DebtPro",
  "login": "تسجيل الدخول",
  "register": "إنشاء حساب",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "confirmPassword": "تأكيد كلمة المرور",
  "forgotPassword": "نسيت كلمة المرور؟",
  "continueWithGoogle": "المتابعة بـ Google",
  "dashboard": "لوحة التحكم",
  "clients": "العملاء",
  "accounts": "الحسابات",
  "settings": "الإعدادات",
  "addClient": "إضافة عميل",
  "clientName": "الاسم الكامل",
  "phone": "رقم الهاتف",
  "officeClient": "عميل مكتب",
  "privateClient": "عميل خاص",
  "addInstallment": "إضافة قسط",
  "capital": "رأس المال",
  "profit": "نسبتي",
  "duration": "المدة (بالأشهر)",
  "startDate": "تاريخ البدء",
  "monthlyAmount": "القسط الشهري",
  "totalDebt": "إجمالي المديونية",
  "payInstallment": "دفع القسط",
  "payGracePeriod": "دفع المهلة",
  "payOfficeCommission": "دفع نسبة المكتب",
  "confirmPayment": "تأكيد الدفع",
  "reversePayment": "عكس الدفع",
  "statusPaid": "مدفوع",
  "statusOverdue": "متأخر",
  "statusCurrent": "الشهر الحالي",
  "statusUpcoming": "لم يحن موعده",
  "daysOverdue": "{count} يوم متأخر",
  "@daysOverdue": { "placeholders": { "count": { "type": "int" } } },
  "monthlyCollection": "المحصل هذا الشهر",
  "target": "الهدف",
  "totalProfits": "إجمالي الأرباح",
  "totalCapital": "إجمالي رأس المال",
  "officeCommission": "نسبة المكتب",
  "totalClients": "إجمالي العملاء",
  "recentTransactions": "آخر المعاملات",
  "successPayment": "تم تسجيل الدفعة بنجاح",
  "successSave": "تم الحفظ بنجاح",
  "errorGeneral": "حدث خطأ، يرجى المحاولة مجدداً",
  "errorEditLocked": "لا يمكن التعديل بعد إتمام الدفعة الأولى",
  "errorAlreadyPaid": "هذه الدفعة مسددة بالفعل",
  "noClients": "لا يوجد عملاء بعد",
  "addFirstClient": "أضف أول عميل",
  "darkMode": "الوضع الليلي",
  "language": "اللغة",
  "logout": "تسجيل الخروج",
  "logoutConfirm": "هل تريد تسجيل الخروج؟",
  "cancel": "إلغاء",
  "confirm": "تأكيد",
  "save": "حفظ",
  "edit": "تعديل",
  "delete": "حذف",
  "deleteClientConfirm": "هل تريد حذف هذا العميل نهائياً؟"
}
```

---

## 13. Firebase Console Checklist

Before starting development:

- [ ] Create Firebase project (no Analytics needed)
- [ ] Enable **Authentication**: Email/Password + Google Sign-in
- [ ] Create **Firestore Database** in Production Mode, region: `europe-west1`
- [ ] Add Firestore **Security Rules** (from firestore-schema.md)
- [ ] Add **Composite Indexes** (from firestore-schema.md) — or deploy via `firestore.indexes.json`
- [ ] Add Flutter app (Android + iOS) and download config files
- [ ] Enable **Firestore offline persistence** in app code (no console step)
- [ ] ~~Cloud Functions~~ — NOT needed
- [ ] ~~Firebase Storage~~ — NOT needed
- [ ] ~~Blaze Plan~~ — NOT needed (Free Tier sufficient)

---

## 14. Definition of Done (Per Feature)

A feature is considered complete when:

- [ ] Clean Architecture layers implemented (data / domain / presentation)
- [ ] All use cases covered
- [ ] Cubit/Bloc states handle: loading + success + error
- [ ] Loading indicator shown during every async operation
- [ ] SnackBar/dialog shown on every operation result
- [ ] Empty state handled
- [ ] Arabic + English strings added to both ARB files
- [ ] Works in both Dark + Light theme
- [ ] Works in both RTL (AR) + LTR (EN) layouts
- [ ] Atomic Firestore writes used for multi-document operations

---

*End of PRD v1.0 — DebtPro*
