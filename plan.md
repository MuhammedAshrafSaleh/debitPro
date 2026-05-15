# DebtPro Build Plan

## Context

DebtPro is a Flutter/Firebase debt-management app for a single admin user to track clients, monthly installments (أقساط), grace periods (مهل), payments, and office commissions. Source of truth: `docs/PRD.md`, `docs/business-requirements.md`, `docs/firestore-schema.md`, and the screen mockups in `docs/screens/`.

The repo is essentially green-field: `lib/` only contains the default `main.dart` counter and a `firebase_options.dart`. Everything else needs to be built. This plan orders the work by dependency so each phase can be verified before the next begins.

### Firestore index rule (applies to every phase that adds a new query)

Any new Firestore query that combines `where()` + `orderBy()`, or multiple `where()` clauses on different fields, **requires a composite index**. Without it the query throws `[cloud_firestore/failed-precondition]` at runtime.

After finishing each phase:
1. Check every new datasource for composite query patterns.
2. Add the required entries to `firestore.indexes.json` (match the exact `collectionGroup`, `queryScope: "COLLECTION"`, and field order).
3. Deploy: `firebase deploy --only firestore:indexes --project debitpro-101`
4. Indexes build asynchronously (usually 1–5 min); verify in the Firebase console under Firestore → Indexes.

**All known indexes are already written to `firestore.indexes.json` and deployed** (covers Phases 7–12). The only reason to touch this file again is if a new query pattern is introduced that isn't covered.

---

### Localization rule (applies to every phase)

Any new user-facing string **must** follow this order:
1. Add to `lib/config/l10n/app_ar.arb` (Arabic value)
2. Add to `lib/config/l10n/app_en.arb` (English value)
3. Run `flutter gen-l10n` — this regenerates the three `.dart` files automatically
4. **Never** edit `app_localizations.dart`, `app_localizations_ar.dart`, or `app_localizations_en.dart` by hand — they are generated output

Each phase ends with a mandatory **L10N sync step**: add all new keys to both ARB files → run `flutter gen-l10n` → run `flutter analyze`.

---

### Decisions confirmed for v1

- **Brand:** DebtPro (login mockup wording must be updated from "DebtFlow")
- **Auth:** Email/password only — Google Sign-In button hidden for v1 (no `google_sign_in` dep)
- **DI:** Manual `get_it` registration in `core/di/injection.dart` (no `injectable` codegen)
- **Currency:** Locale-derived single currency (SAR for `ar`, USD for `en`). Stored as plain numbers in Firestore.
- **Testing:** Unit tests for use cases + `core/utils/*` only. Manual QA per screen for everything UI-related.

---

## Phase 0 — Project Bootstrap & Tooling

Goal: leave the repo in a clean, runnable state with the right deps, lint config, and Firebase wiring before any code is written.

- [x] **0.1** Verify `pubspec.yaml` deps match the v1 plan; remove anything unused, add what's missing
  - Keep: `firebase_core`, `firebase_auth`, `cloud_firestore`, `flutter_bloc`, `get_it`, `dartz`, `equatable`, `freezed_annotation`, `json_annotation`, `go_router`, `intl`, `logger`, `shared_preferences`, `connectivity_plus`, `freezed`, `json_serializable`, `build_runner`, `flutter_launcher_icons`, `flutter_lints`, `flutter_localizations` (add this — currently missing for ARB workflow)
  - Skip: `google_sign_in`, `injectable`, `injectable_generator`, `uuid` (Firestore `.doc().id` is enough)
- [x] **0.2** Add `l10n.yaml` at project root (`arb-dir: lib/config/l10n`, `template-arb-file: app_ar.arb`, `output-localization-file: app_localizations.dart`)
- [x] **0.3** Enable `flutter_lints` strict rules in `analysis_options.yaml` (already on `package:flutter_lints/flutter.yaml`); add `prefer_single_quotes`, `require_trailing_commas`
- [x] **0.4** Delete the placeholder code in `lib/main.dart` — leave a stub that will be filled in Phase 3
- [x] **0.5** Confirm Firebase project is wired (already have `firebase_options.dart`, `android/app/google-services.json`, `firebase.json`). Run `flutter run` once to confirm a clean boot before writing code.
- [x] **0.6** Configure `flutter_launcher_icons` against `assets/icon/` and run once

**Verification:** `flutter pub get` clean, `flutter analyze` clean, `flutter run` shows a blank scaffold without crashing.

---

## Phase 1 — Core Layer (No Flutter Dependencies)

Goal: build the pure-Dart foundation that every feature will depend on. No Firebase, no widgets — just types and utilities.

- [ ] **1.1** `core/errors/exceptions.dart` — `ServerException`, `NetworkException`, `AuthException(code)`, `PermissionException`, `CacheException`
- [ ] **1.2** `core/errors/failures.dart` — abstract `Failure extends Equatable`; subclasses: `ServerFailure`, `NetworkFailure`, `AuthFailure`, `PermissionFailure`, `ValidationFailure`, `EditLockedFailure`, `AlreadyPaidFailure`
- [ ] **1.3** `core/usecases/usecase.dart` — abstract `UseCase<Type, Params>` returning `Future<Either<Failure, Type>>`; `NoParams` sentinel
- [ ] **1.4** `core/constants/firestore_paths.dart` — `users(uid)`, `clients(uid)`, `installments(uid)`, `payments(uid)`, `gracePeriods(uid)`, `transactions(uid)`, `monthlyAgg(uid, yearMonth)`, `allTimeAgg(uid)` — all as static helpers
- [ ] **1.5** `core/constants/app_constants.dart` — `kPaymentDueDay = 10`, `kGraceWindowDays = 10`, `kOfficeCommissionRate = 0.10`, `kAllowedDurationMonths = [3, 6, 9, 12, 24]`, `kBatchLimit = 499`, locale + theme `SharedPreferences` keys
- [ ] **1.6** `core/utils/date_utils.dart` — `yearMonthKey(DateTime)` → `"YYYY-MM"`, `firstDayOfMonth`, `lastDayOfMonth`, `addMonths`, `daysBetween`
- [ ] **1.7** `core/utils/currency_utils.dart` — `currencyForLocale(String code)` (`'ar'` → SAR, `'en'` → USD), `formatCurrency(num, locale)`
- [ ] **1.8** `core/utils/avatar_utils.dart` — `initialsFromName(String)` (first letter of first two words), `colorForId(String)` from an 8-color palette
- [ ] **1.9** `core/utils/status_utils.dart` — `computeInstallmentPaymentStatus(DateTime due, DateTime now)`, `computeGracePeriodStatus(DateTime due, DateTime now)`, `qualityScore(int onTime, int totalDue)`, `qualityBadge(double score)`
- [ ] **1.10** `core/network/network_info.dart` — abstract `NetworkInfo { Future<bool> get isConnected; }` + `NetworkInfoImpl(Connectivity)`

**Verification:** unit tests for `status_utils.dart`, `date_utils.dart`, `avatar_utils.dart`, `currency_utils.dart` under `test/core/utils/`. Run `flutter test`.

---

## Phase 2 — Config Layer (Themes, l10n, Routing Shell)

Goal: theme system, language support, and an empty router with auth guard ready for features to plug in.

- [ ] **2.1** `config/themes/dark_colors.dart` — primary `#3B82F6`, surface `#1E1E2E`, base `#12121A`, error `#EF4444`, tertiary `#F59E0B`, secondary `#10B981`, plus on-* tokens
- [ ] **2.2** `config/themes/light_colors.dart` — primary `#1E3A5F`, surface `#FFFFFF`, base `#F1F5F9`, error `#DC2626`, matching tokens
- [ ] **2.3** `config/themes/app_typography.dart` — `AppTypography.forLocale(String)` returns a `TextTheme` using Cairo for `ar`, Inter for `en`, with weight ramps already declared in `pubspec.yaml`
- [ ] **2.4** `config/themes/app_theme.dart` — `AppTheme.dark(languageCode:)` and `AppTheme.light(languageCode:)` returning fully wired `ThemeData` (color scheme, text theme, input decoration, snackbar, dialog, bottom nav, FAB, elevated/filled button)
- [ ] **2.5** `config/l10n/app_ar.arb` — start with the sample keys from PRD §12; add `@@locale: "ar"` header
- [ ] **2.6** `config/l10n/app_en.arb` — English equivalents of every key
- [ ] **2.7** Run `flutter gen-l10n` once and confirm `app_localizations.dart` generates
- [ ] **2.8** `config/routes/app_router.dart` — `GoRouter` with stub routes for everything in PRD §5.1: `/`, `/login`, `/register`, `/forgot-password`, `/forgot-password/sent`, `/dashboard`, `/clients`, `/clients/add`, `/clients/:clientId`, `/clients/:clientId/edit`, `/installments/add/:clientId`, `/installments/:installmentId`, `/installments/:installmentId/edit`, `/grace-periods/add/:clientId`, `/grace-periods/:gracePeriodId/edit`, `/accounts`, `/settings`, `/settings/edit-account`
- [ ] **2.9** Inside router, add `redirect:` based on `FirebaseAuth.instance.currentUser` (null → `/login`, else allow). Build `ShellRoute` for the 4 main tabs (`/dashboard`, `/clients`, `/accounts`, `/settings`) with bottom nav
- [ ] **2.10** Each routed page is a stub returning a `Scaffold` with a title — features will fill them in later phases

**Verification:** `flutter run`, navigate via debug URL to every stub route; bottom nav swaps tabs; locale toggle (temporary debug button) flips RTL/LTR + fonts.

---

## Phase 3 — DI + App Shell

Goal: a single source of truth for service location, a root widget that listens to theme + locale changes, and Firestore offline persistence enabled.

- [x] **3.1** `core/di/injection.dart` — `final sl = GetIt.instance;` plus `Future<void> configureDependencies()` that registers Firebase singletons, `Connectivity`, `NetworkInfoImpl`, `SharedPreferences` (await `getInstance()`)
- [x] **3.2** Pre-seed empty `init*` functions per feature (`initAuth`, `initSettings`, ...) — each phase will add registrations to its own initializer
- [x] **3.3** `lib/main.dart` — `WidgetsFlutterBinding.ensureInitialized()`, `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`, enable Firestore persistence (`Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)`), call `configureDependencies()`, then `runApp(const DebtProApp())`
- [x] **3.4** `DebtProApp` (root) — `MultiBlocProvider` for `SettingsCubit` (theme + locale state). `BlocBuilder<SettingsCubit, SettingsState>` returns `MaterialApp.router` with `theme`/`darkTheme`/`themeMode`, `locale`, `supportedLocales`, `localizationsDelegates`, `routerConfig`. Default locale = `ar`, default themeMode = dark.
- [x] **3.5** `SettingsCubit` skeleton (the feature-rich version comes in Phase 6, but the shell needs the cubit available now to read/persist theme + locale via `SharedPreferences`)

**Verification:** App boots into `/login` stub in Arabic dark mode. Hot restart preserves theme + locale.

---

## Phase 4 — Shared Presentation Widgets

Goal: extract repeatable UI primitives so features don't reinvent them. Every async-touching feature will pull from this layer.

- [ ] **4.1** `core/presentation/widgets/app_loading_indicator.dart` — `CircularProgressIndicator` centered for pages, `_ButtonLoading` swap-in for buttons
- [ ] **4.2** `core/presentation/widgets/app_snackbar.dart` — `AppSnackbar.success(context, message)` (green, 3s), `AppSnackbar.error(context, message)` (red, 4s) using the theme's snackbar color tokens
- [ ] **4.3** `core/presentation/widgets/confirm_dialog.dart` — `showConfirmDialog(context, title, message, confirmLabel)` returning `Future<bool>`
- [ ] **4.4** `core/presentation/widgets/destructive_bottom_sheet.dart` — for delete/reverse confirmations
- [ ] **4.5** `core/presentation/widgets/empty_state.dart` — icon + localized message + optional CTA
- [ ] **4.6** `core/presentation/widgets/avatar_widget.dart` — uses `avatar_utils` to render initials over a deterministic color circle
- [ ] **4.7** `core/presentation/widgets/status_badge.dart` — pill widget driven by an enum (`paid`, `overdue`, `current`, `upcoming`, `gracewindow`, `reversed`)
- [ ] **4.8** `core/presentation/widgets/quality_badge.dart` — wraps `qualityBadge()` from utils
- [ ] **4.9** `core/presentation/widgets/app_text_field.dart`, `app_button.dart` — themed wrappers so forms stay consistent
- [ ] **4.10** `core/presentation/widgets/main_shell.dart` — the `ShellRoute` body: persistent bottom nav with 4 tabs, switches via `GoRouterState.matchedLocation`

**Verification:** Build a temporary `/debug/widgets` page that renders every widget in light and dark, ar and en. Confirm visually, then drop the debug route.

---

## Phase 5 — Auth Feature

Goal: register, log in, password reset, email verification, and sign out — the gate to everything else. Reference: BRD §3, PRD §6.1, screens `تسجيل الدخول.png`, `إنشاء حساب جديد.png`, `نسيت كلمة المرور.png`, `تم الإرسال بنجاح.png`.

- [x] **5.1** `features/auth/domain/entities/app_user.dart` — `uid, displayName, email, photoURL, isEmailVerified`
- [x] **5.2** `features/auth/domain/repositories/auth_repository.dart` — `signInWithEmail`, `register`, `sendPasswordResetEmail`, `sendVerificationEmail`, `reloadUser`, `signOut`, `Stream<AppUser?> authStateChanges`, `AppUser? get currentUser`
- [x] **5.3** `features/auth/data/datasources/firebase_auth_datasource.dart` — wraps `FirebaseAuth` calls, maps `FirebaseAuthException` → `AuthException(code)`. After `createUserWithEmailAndPassword`, immediately call `sendEmailVerification()`.
- [x] **5.4** `features/auth/data/models/user_model.dart` — JSON serializable; `fromFirebaseUser(User)` (maps `emailVerified`) and `toFirestore()` for the `users/{uid}` profile doc
- [x] **5.5** `features/auth/data/repositories/auth_repository_impl.dart` — implements interface, returns `Either<Failure, T>`. On register, also creates the `users/{uid}` profile doc with `language: 'ar', darkMode: true`.
- [x] **5.6** Use cases: `SignInWithEmailUseCase`, `RegisterUseCase`, `SendPasswordResetEmailUseCase`, `SendVerificationEmailUseCase`, `ReloadUserUseCase`, `SignOutUseCase`, `GetCurrentUserUseCase`
- [x] **5.7** Cubits + states (one file per cubit, `Equatable`):
  - `LoginCubit` → `Initial | Loading | Success | Failure(message)`
  - `RegisterCubit` → same shape; on `Success` the user lands on `VerifyEmailPage` (not the dashboard)
  - `ForgotPasswordCubit` → `Initial | Loading | EmailSent | Failure(message)`
  - `VerifyEmailCubit` → `Initial | ResendLoading | ResendSuccess | ResendFailure(message) | Verified` — polls `reloadUser()` every 5 seconds while the screen is active to detect verification; cancels poll on `close()`
- [x] **5.8** Pages: `LoginPage`, `RegisterPage`, `ForgotPasswordPage`, `EmailSentPage`, **`VerifyEmailPage`**. Match mockup layout exactly — title, hero greeting, fields with leading icons + password-visibility toggle, inline error banner, primary button, "أو" divider, **Google button hidden for v1**, footer link to the opposite auth screen.
  - `VerifyEmailPage` shows the sent-to address, a countdown-gated "أعد الإرسال" button (60 s cooldown), a "تحقق الآن" button that triggers `ReloadUserUseCase` and transitions on `Verified`, and a sign-out link. No bottom nav.
- [x] **5.9** Add `initAuth()` to DI (datasource, repo, use cases, cubits)
- [x] **5.10** Wire router redirect to use the real `authStateChanges` stream — drop the temporary `FirebaseAuth.currentUser` check from Phase 2. Redirect logic: `currentUser == null` → `/login`; `currentUser != null && !emailVerified` → `/verify-email`; `currentUser != null && emailVerified` → `/dashboard`.
- [x] **5.11** Add `/verify-email` route to the router (no shell — standalone page, no bottom nav). The route is unreachable once `emailVerified == true`.

**Verification:** Register → lands on VerifyEmailPage (not dashboard). Open verification link in email → app detects it within one poll cycle and auto-navigates to `/dashboard`. Resend button disabled for 60 s. Sign in with unverified account → redirected to `/verify-email`. Sign in with verified account → lands on `/dashboard`. Test invalid credentials → red banner with localized message. Confirm `users/{uid}` doc in Firestore.

---

## Phase 6 — Settings Feature

Goal: theme + language toggles, profile edit, password change, logout. Reference: BRD §10, PRD §6.8, screens `الإعدادات.png`, `تعديل الحساب.png`.

- [x] **6.1** `features/settings/domain/repositories/settings_repository.dart` — read/write `language`, `darkMode` on `users/{uid}`; update display name, update email (requires re-auth), update password
- [x] **6.2** `features/settings/data/datasources/firebase_user_datasource.dart` + `data/repositories/settings_repository_impl.dart`
- [x] **6.3** Use cases: `ToggleThemeUseCase`, `ChangeLanguageUseCase`, `UpdateDisplayNameUseCase`, `UpdateEmailUseCase`, `UpdatePasswordUseCase` + `LoadPreferencesUseCase`
- [x] **6.4** Expand `SettingsCubit` from Phase 3 — load preferences on app start (try `SharedPreferences` first for instant boot, then reconcile with Firestore once authed), persist both on change
- [x] **6.5** `EditAccountCubit` for the profile edit screen
- [x] **6.6** Pages: `SettingsPage` (profile header card, Preferences section with language chevron + dark-mode switch, Account section, destructive logout button with confirm dialog), `EditAccountPage` (display name, email with re-auth modal, password change section)
- [x] **6.7** Logout confirm → `SignOutUseCase` from auth → router auto-redirects to `/login`
- [x] **6.8** Locale change must rebuild `MaterialApp` (already handled by Phase 3 `BlocBuilder<SettingsCubit>`)
- [x] **6.9** Add `initSettings()` to DI

**Verification:** Flip language and theme, hot restart — preferences survive. Edit display name → reflected in Settings header. Change password → log out and re-login with new password.

---

## Phase 7 — Clients Feature

Goal: CRUD for clients plus the filtered list. Reference: BRD §4, PRD §6.2, screens `قائمة العملاء - فلاتر وتصنيفات جديدة.png`, `إضافة عميل جديد.png`, `تفاصيل العميل - نسخة محدثة.png`, `مُهَل العميل - محدث.png`.

- [x] **7.1** `features/clients/domain/entities/client.dart` — every field from schema doc §2 (identity, totals, payment quality, metadata); `ClientFilter` enum (`all, electronic, paper, office`); `Gender`, `DocumentationType`, `ClientType` enums
- [x] **7.2** `features/clients/data/models/client_model.dart` — freezed + json_serializable, with `fromFirestore` / `toFirestore` (including `Timestamp` ↔ `DateTime` converters)
- [x] **7.3** `features/clients/domain/repositories/client_repository.dart` — `watchClients(ClientFilter)`, `getClient(id)`, `addClient(params)`, `editClient(params)`, `deleteClient(id)`
- [x] **7.4** `features/clients/data/datasources/firestore_client_datasource.dart` + `repositories/client_repository_impl.dart` — uses `NetworkInfo` for one-shot writes; streams skip the pre-check
- [x] **7.5** Use cases: `WatchClientsUseCase`, `GetClientDetailUseCase`, `AddClientUseCase`, `EditClientUseCase`, `DeleteClientUseCase`. Delete runs in a transaction that also decrements `aggregates/allTime.totalClients`.
- [x] **7.6** Cubits:
  - `ClientListCubit` (stream-driven, holds filter; `Loading | Loaded(clients, filter) | Failure`)
  - `ClientDetailCubit` (loads client; states `Loading | Loaded(...) | Failure`)
  - `AddClientCubit` + `EditClientCubit` (`Initial | Saving | Saved | Deleted | Failure`)
- [x] **7.7** Pages:
  - `ClientListPage` — header + search icon, filter tabs, scrollable client cards (avatar, name, phone, tags, debt count, chevron), FAB
  - `AddClientPage` — full form with segmented toggles and save/cancel buttons
  - `ClientDetailPage` — header card with stats row + quality badge, tab bar (Installments / Grace Periods), FAB opens Add Record bottom sheet
  - `EditClientPage` — reuses ClientForm pre-populated
- [x] **7.8** Empty states for: no clients, no installments, no grace periods
- [x] **7.9** Delete confirm via destructive bottom sheet
- [x] **7.10** Add `initClients()` to DI

**Verification:** Add a client → appears in list. Filter tabs filter correctly. Detail shows zero stats. Delete client → totalClients aggregate decrements (verify in Firestore console).

**L10N sync:** Add all new keys to `app_ar.arb` + `app_en.arb` → run `flutter gen-l10n` → `flutter analyze` clean. ✅ Done for Phase 7.

---

## Phase 8 — Installments Feature

Goal: create installments (which generates the payment schedule atomically), view the tracking screen, edit before first payment, mark office commission. Reference: BRD §5, PRD §6.3, screens `إضافة قسط شهري - محدث.png`, `تتبع الأقساط.png`.

- [x] **8.1** Entities: `Installment` (schema §3), `Payment` (schema §4); enums `InstallmentStatus { active, completed }`, `PaymentStatus { upcoming, current, overdue, paid, reversed }`
- [x] **8.2** Models + freezed conversions for both
- [x] **8.3** `InstallmentRepository` (abstract) — `addInstallment(params)`, `editInstallment(params)`, `getInstallmentWithPayments(installmentId)`, `payOfficeCommission(installmentId)`, `watchInstallmentsForClient(clientId)`
- [x] **8.4** `firestore_installment_datasource.dart` + repo impl — **`addInstallment` runs in a Firestore WriteBatch** that creates installment + N payment docs + increments client totals + allTime.totalCapital + optionally runs office-commission branch
- [x] **8.5** `editInstallment` checks `editLocked` field and returns `Left(EditLockedFailure())` if true
- [x] **8.6** `payOfficeCommission` transaction: set `officeCommissionPaid=true`, create transaction doc, increment `aggregates/allTime.totalOfficeCommission`
- [x] **8.7** Use cases: `AddInstallmentUseCase`, `EditInstallmentUseCase`, `GetInstallmentWithPaymentsUseCase`, `PayOfficeCommissionUseCase`, `WatchInstallmentsForClientUseCase`
- [x] **8.8** Cubits: `AddInstallmentCubit` (live summary), `InstallmentTrackingCubit`, `EditInstallmentCubit`, `ClientInstallmentsCubit`
- [x] **8.9** Pages: `AddInstallmentPage`, `InstallmentTrackingPage`, `EditInstallmentPage`
- [x] **8.10** Localized month names for payment row labels (static lookup, ar/en)
- [x] **8.11** Add `initInstallments()` to DI

**Verification:** Create a 12-month installment → confirm 12 `payments` docs created in one transaction. Edit before any payment → succeeds. (We'll verify edit-lock after Phase 10 when payments can be made.) Pay office commission → transaction doc + aggregate increment.

**L10N sync:** Add all new keys to both ARB files → `flutter gen-l10n` → `flutter analyze` clean. ✅ Done for Phase 8.

---

## Phase 9 — Grace Periods Feature

Goal: single-payment debts with the 10-day grace window. Reference: BRD §6, PRD §6.4, screens `إضافة مُهلة - محدث.png`, `مُهَل العميل - محدث.png`.

- [x] **9.1** `GracePeriod` entity (schema §5) + `GracePeriodStatus { upcoming, graceWindow, overdue, paid }`
- [x] **9.2** Model + freezed
- [x] **9.3** `GracePeriodRepository` — `addGracePeriod`, `editGracePeriod`, `watchGracePeriodsForClient`, `payOfficeCommission`
- [x] **9.4** Datasource + repo impl. **`addGracePeriod` transaction:** create doc with `gracePeriodEndDate = dueDate + 10 days`, increment `clients.totalRemaining` and `activeDebtsCount`, increment `aggregates/allTime.totalCapital`, optionally run office-commission branch
- [x] **9.5** `editGracePeriod` blocked once `editLocked == true`
- [x] **9.6** Use cases: `AddGracePeriodUseCase`, `EditGracePeriodUseCase`, `PayGracePeriodOfficeCommissionUseCase`
- [x] **9.7** `AddGracePeriodCubit`, `EditGracePeriodCubit`
- [x] **9.8** Pages: `AddGracePeriodPage` (client banner, optional office-commission toggle, name, capital, due date picker, notes, save/cancel), `EditGracePeriodPage`
- [x] **9.9** The grace-period cards inside `ClientDetailPage` (Phase 7) already display status + "دفع المهلة" button — wire them now to the actual payment flow (payment itself comes in Phase 10)
- [x] **9.10** Add `initGracePeriods()` to DI

**Verification:** Create a grace period dated 5 days ago → status renders `grace_window` (yellow). Dated 15 days ago → status renders `overdue` with day count. Edit before payment → succeeds.

**L10N sync:** Add all new keys to both ARB files → `flutter gen-l10n` → `flutter analyze` clean. ✅ Done for Phase 9.

---

## Phase 10 — Payments Feature (Bloc — Multiple Events)

Goal: the only feature that uses Bloc. Handles pay-installment, pay-grace-period, pay-office-commission (already in Phases 8/9 but now routable through Bloc), and reverse-payment. Reference: BRD §7, BRD §12, PRD §6.5, schema §6 + §7 + atomic ops section.

- [x] **10.1** `Transaction` entity (schema §6) + `TransactionStatus { completed, reversed }`, `TransactionType { payment, officeCommission }`, `RelatedType { installmentPayment, gracePeriod, officeCommission }`
- [x] **10.2** Model + freezed
- [x] **10.3** `PaymentRepository` — `payInstallmentPayment(params)`, `payGracePeriod(params)`, `reversePayment(transactionId, relatedId, relatedType)`, `watchTransactionsForClient(clientId)`, `watchTransactions(filter)`
- [x] **10.4** Datasource + repo impl. Every method runs the **full atomic transaction** specified in schema §"Atomic Operations":

  - **Pay installment payment:** update payment (`status=paid`, `paidDate`), increment installment counters (`paidPaymentsCount`, `totalPaidAmount`, `recognizedProfit`), flip `editLocked=true`, set installment `status=completed` if all paid; update client totals + on-time counter + recompute quality score; create transaction; bump monthly + all-time aggregates
  - **Pay grace period:** mirror operation for grace period
  - **Reverse payment:** reset payment/grace status (recompute via `status_utils`), decrement all counters atomically, flip transaction `status=reversed` (never delete), adjust aggregates only if reversing within the original `yearMonth`
- [x] **10.5** Use cases: `PayInstallmentPaymentUseCase`, `PayGracePeriodUseCase`, `ReversePaymentUseCase`, `GetTransactionsUseCase`. Validation: reject already-paid (`AlreadyPaidFailure`), reject if not the latest payment when reversing.
- [x] **10.6** `PaymentBloc` with events `LoadPayments(filter)`, `PayInstallmentPaymentEvent`, `PayGracePeriodEvent`, `ReversePaymentEvent` and states `Initial | Loading | Loaded(payments, gracePeriods, summary) | ActionLoading | ActionSuccess(message) | ActionFailure(message)`
- [x] **10.7** Hook "دفع القسط" and "دفع المهلة" buttons (in client detail, accounts, installment tracking) through the bloc with a confirm dialog beforehand
- [x] **10.8** `RefreshPaymentStatusesUseCase` (PRD §10) — batched (`kBatchLimit = 499`) update of stale `upcoming/current` statuses; called from `DebtProApp` on auth state transition to signed-in (Phase 3 hook)
- [x] **10.9** Add `initPayments()` to DI

**Verification:** Pay an installment payment → installment counters update, client totals update, transaction doc created, monthly aggregate increments. Reverse it → all decrements happen, transaction marked `reversed` (not deleted), aggregates adjust. Confirm `editLocked=true` blocks edit after first payment.

**L10N sync:** Add all new keys to both ARB files → `flutter gen-l10n` → `flutter analyze` clean. ✅ Done for Phase 10 — no new ARB keys required (existing keys reused; bloc messages stay localized at UI layer).

---

## Phase 11 — Accounts / Reports Feature

Goal: the unified payment-processing screen with filters and the overdue-clients report. Reference: BRD §9, PRD §6.7, screens `الحسابات - مع فلتر التاريخ.png`, `الأقساط - دفع القسط.png`, `المُهل - دفع المهلة.png`.

- [x] **11.1** `AccountsFilter` value object: `typeTab (all | installments | grace) `, `fromMonth`, `toMonth`, `clientType (all | office | private)`, `searchQuery`
- [x] **11.2** `AccountsRepository` (or extend `PaymentRepository`) — `queryPayments(filter)`, `queryGracePeriods(filter)`, `queryTransactions(filter)`, `queryOverdueClients(filter)`. Uses the composite indexes in schema §"Firestore Indexes Required" — schedule a Phase 13 task to deploy those.
- [x] **11.3** Use cases: `GetAccountsListUseCase` (returns combined list + summary counts), `GetOverdueClientsUseCase`, `GetTransactionsReportUseCase`
- [x] **11.4** `AccountsCubit` — loads list on filter change; states `Loading | Loaded(items, summaryChips, overdueClients) | Failure`
- [x] **11.5** `AccountsPage` — top filter bar (filter icon + search), three type tabs (الكل/الأقساط/المهل), month-range pickers, client-type chip row, status summary chips (متأخر / جاري / مدفوع counts), scrollable list of payment cards (client avatar + name + item + amount + due/paid date + status badge + action button). Tapping action → confirm dialog → dispatches `PayInstallmentPaymentEvent` / `PayGracePeriodEvent` through the Phase-10 bloc.
- [x] **11.6** Reversed transactions render with strikethrough + "محول" badge (BRD §9.2)
- [x] **11.7** Overdue Clients section under the list, only when count > 0; sorted by days-overdue descending
- [x] **11.8** Summary totals header (المحصل / الأرباح / عدد العمليات) shown when a date range is active
- [x] **11.9** Add `initAccounts()` to DI

**Verification:** Apply each filter and confirm Firestore queries fire correctly (composite indexes must be deployed — see Phase 13.3). Pay an unpaid item from this screen → status updates, summary chip recounts.

**L10N sync:** Add all new keys to both ARB files → `flutter gen-l10n` → `flutter analyze` clean. ✅ Done for Phase 11.

---

## Phase 12 — Dashboard Feature

Goal: the landing screen for authenticated users. Reference: BRD §8, PRD §6.6, screen `لوحة التحكم.png`.

- [x] **12.1** `DashboardData` entity (PRD §6.6): `monthlyCollection`, `monthlyTarget`, `collectionProgress`, `totalProfits`, `totalCapital`, `totalOfficeCommission`, `totalClients`, `recentTransactions`
- [x] **12.2** `DashboardRepository` — `getDashboardData()` which:
  - reads `aggregates/monthly/{currentYearMonth}` and `aggregates/allTime` in parallel
  - runs the two parallel queries from PRD §6.6 to compute `monthlyTarget` (payments due this month + grace periods due this month)
  - fetches the 10 most-recent non-reversed transactions
- [x] **12.3** Use cases: `GetDashboardDataUseCase`, `GetRecentTransactionsUseCase`
- [x] **12.4** `DashboardCubit` — `Loading | Loaded(DashboardData) | Failure`; refresh trigger on pull-to-refresh and on tab switch
- [x] **12.5** `DashboardPage` — header (greeting with first name + sun/moon icon based on time of day + profile chip), large hero collection card (title, large amount, progress bar with %, target label), 2×2 stats grid (إجمالي الأرباح / إجمالي رأس المال / نسبة المكتب / إجمالي العملاء), recent transactions list (avatar + name + type + relative time + green +amount). Tapping a transaction routes to that client's detail.
- [x] **12.6** `intl`-based relative-time formatter (`منذ 5 دقائق`, `منذ ساعة`, `أمس`)
- [x] **12.7** Add `initDashboard()` to DI

**Verification:** Dashboard loads instantly from aggregates (no full-collection scan). Make a payment → hero collection increments live (or after refresh). Reverse → decrements. Recent transactions list updates.

**L10N sync:** Add all new keys to both ARB files → `flutter gen-l10n` → `flutter analyze` clean.

---

## Phase 13 — Cross-Cutting Integrations

Goal: deploy backend artifacts and wire app-wide concerns that depend on features being in place.

- [x] **13.1** **Firestore security rules** — `firestore.rules` written from schema §"Security Rules" (users can only read/write their own `users/{userId}/**` subtree), wired into `firebase.json`, and deployed via `firebase deploy --only firestore:rules --project debitpro-101`.
- [x] **13.2** **Firestore indexes** — `firestore.indexes.json` written with all 13 composite indexes (clients, installments, payments, gracePeriods, transactions) and deployed via `firebase deploy --only firestore:indexes --project debitpro-101`. Indexes build asynchronously; check Firebase console to confirm they are all "Enabled".
- [x] **13.3** Verify no query in the app falls back to a missing index — all composite queries cross-checked against `firestore.indexes.json`: all single-field queries use auto-indexes; all multi-field queries (`clientId+createdAt`, `installmentId+monthIndex`, `relatedId+createdAt`) have matching composite indexes. Dashboard intentionally filters status client-side to avoid a redundant index.
- [x] **13.4** **Status refresh on auth** — `RefreshPaymentStatusesUseCase` already ran via `_onAuthStateChanged` with `_lastRefreshedUid` guard; added `_isRefreshing` bool + `setState` around the call; `MaterialApp.router`'s `builder` now overlays a 3 dp `LinearProgressIndicator` at the top while the refresh is in flight.
- [x] **13.5** **Offline banner** — `OfflineBanner` widget in `core/presentation/widgets/offline_banner.dart` listens to `Connectivity().onConnectivityChanged`, shows an animated error-color bar at the top with wifi_off icon + localized message. Mounted via `MaterialApp.router`'s `builder` in `main.dart`. `commonOfflineBanner` key added to both ARB files.
- [x] **13.6** **Firestore offline persistence** — confirmed `persistenceEnabled: true` + `cacheSizeBytes: CACHE_SIZE_UNLIMITED` set in `main()` before `configureDependencies()`. App will serve cached reads and queue writes when offline, syncing on reconnect.
- [x] **13.7** **Number formatting in Arabic** — fixed `CurrencyUtils.formatCurrency` to always use `en_US` locale (was `ar_SA` which produces Hindi/Arabic-Indic digits). Fixed `RelativeTimeUtils` absolute-date fallback similarly. All Dart string-interpolated numbers already produce Western digits.
- [x] **13.8** **App icon generation** — ran `dart run flutter_launcher_icons`; icons generated for Android and iOS from `assets/icon/icon.png`.
- [x] **13.9** `firebase.json` confirmed: `firestore` key present with `rules` + `indexes` pointers. Hosting skipped — no public landing page needed.

**Verification:** Pull airplane-mode test (kill internet → app still navigable, read-only). Try a query without its index deployed → confirm Firestore error surface. App icon shows on launcher.

---

## Phase 14 — Final Verification (Manual QA)

Run through the Definition-of-Done checklist from PRD §14 for each feature:

- [ ] Every feature has clean architecture layers, all use cases covered, cubit/bloc states cover loading + success + error
- [ ] Loading indicator visible during every async operation
- [ ] Success/error snackbar shown after every operation
- [ ] Empty state handled on every list screen
- [ ] All strings present in both `app_ar.arb` and `app_en.arb`
- [ ] Visually correct in both dark + light theme
- [ ] Layout correct in both RTL (ar) + LTR (en)
- [ ] Multi-document writes use `runTransaction` or `WriteBatch`
- [ ] Edit-lock enforced on installments + grace periods after first payment
- [ ] Reversed transactions never deleted; excluded from totals; visible with "محول" badge
- [ ] Dashboard aggregates match a sample-data spot check (manual sum vs displayed)
- [ ] `flutter analyze` clean
- [ ] `flutter test` passes (use cases + utils)

---

## Critical Files to Create

Foundation (all new):
- `lib/main.dart` (rewrite from default skeleton)
- `lib/core/{errors,usecases,constants,utils,network,di,presentation/widgets}/*`
- `lib/config/{themes,routes,l10n}/*`

Per feature (8 features × ~12 files):
- `lib/features/{auth,settings,clients,installments,grace_periods,payments,accounts,dashboard}/{data,domain,presentation}/...`

Backend:
- `firestore.rules`
- `firestore.indexes.json`
- update `firebase.json` to reference both

Tests:
- `test/core/utils/*_test.dart`
- `test/features/{feature}/domain/usecases/*_test.dart` for non-trivial use cases (formulas, status, quality score, schedule generation)

---

## Reused Utilities (Reference)

These are the bottlenecks of the system — anything that does math, status, or formatting routes through them, so they're built once in Phase 1 and never duplicated:

- `status_utils.computeInstallmentPaymentStatus` — referenced by Phases 8 (tracking), 10 (refresh + reverse), 11 (accounts)
- `status_utils.computeGracePeriodStatus` — referenced by Phases 9, 10, 11
- `status_utils.qualityScore` — referenced by Phase 10 atomic transactions (every payment write recomputes it)
- `date_utils.yearMonthKey` — referenced by Phases 8, 10, 11, 12 for the `dueMonth`/`yearMonth` Firestore fields
- `currency_utils.formatCurrency` — every page that displays an amount
- `avatar_utils.initialsFromName + colorForId` — every client/transaction list

---

## Notes / Watch-Outs

- The PRD mentions `injectable` + `google_sign_in` but `pubspec.yaml` excludes them and the user confirmed v1 skips both — keep this in mind so we don't pull them in from PRD copy-paste.
- The login mockup says "DebtFlow"; we display "DebtPro" everywhere per the user's decision.
- All denormalized counters (`totalPaid`, `totalRemaining`, `paidPaymentsCount`, etc.) are written exclusively inside `runTransaction` — never from a plain `set()` / `update()`. The repo layer is the only place these counters are mutated.
- The `payments` collection is **flat per user** (not nested under installments). Range queries by `dueMonth` depend on this.
- Firestore composite indexes (Phase 13.2) MUST be deployed before Phase 11 accounts filters work in production — the emulator/dev path can tolerate missing indexes with a console warning.
