# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## App Overview

**DebtPro** (package: `debit_pro`) is a Flutter debt/installment management app. It tracks clients, installments, grace periods, and payments. The app targets Arabic-speaking users first (RTL/Cairo font) with English as a secondary locale.

- **Platform:** iOS + Android (Flutter)
- **Backend:** Firebase (Auth + Firestore)
- **State Management:** BLoC/Cubit (`flutter_bloc`)
- **Architecture:** Clean Architecture
- **Routing:** GoRouter
- **DI:** get_it + injectable

---

## Common Commands

```bash
# Run app (debug)
flutter run

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run all tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Code generation (freezed, json_serializable, injectable)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Regenerate localization files
flutter gen-l10n
```

---

## Architecture

Clean Architecture with feature-driven folder structure:

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/        # firestore_paths.dart (all Firestore paths), app_constants.dart
│   ├── errors/           # failures.dart + exceptions.dart
│   ├── usecases/         # abstract UseCase<Type, Params>
│   ├── utils/            # date_utils, avatar_utils, currency_utils, status_utils
│   └── di/               # injection.dart + injection.config.dart (generated)
├── config/
│   ├── themes/           # app_theme.dart, dark_colors.dart, light_colors.dart, app_typography.dart
│   ├── routes/           # app_router.dart (GoRouter)
│   └── l10n/             # app_ar.arb, app_en.arb
└── features/
    ├── auth/
    ├── clients/
    ├── installments/
    ├── grace_periods/
    ├── payments/         # Uses Bloc (not Cubit) — multiple events
    ├── dashboard/
    ├── accounts/
    └── settings/
```

**Planned features (in order):** auth → settings → clients → installments → grace_periods → payments → accounts → dashboard.

Each feature follows the same internal structure:

```
feature/
├── data/
│   ├── datasources/      # Firebase calls only
│   ├── models/           # JSON-serializable (freezed + json_annotation)
│   └── repositories/     # implements domain repository interface
├── domain/
│   ├── entities/         # Pure Dart (no Firebase deps)
│   ├── repositories/     # Abstract interfaces
│   └── usecases/         # One class per use case, returns Either<Failure, T>
└── presentation/
    ├── cubit/            # XxxCubit + XxxState (use Bloc only for payments)
    ├── pages/
    └── widgets/
```

---

## State Management

- **Cubit** — all standard screens: simple CRUD, single-direction state (Auth, Clients, Installments, Grace Periods, Settings, Dashboard)
- **Bloc** — `payments` feature only: multiple events (pay, reverse, filter), real-time state with debouncing

State classes use either a single `freezed` sealed class or four explicit classes: `Initial`, `Loading`, `Success`, `Failure`.

---

## Key Patterns

### UseCase Template

```dart
// lib/features/clients/domain/usecases/add_client_use_case.dart
class AddClientUseCase {
  final ClientRepository _repository;
  AddClientUseCase(this._repository);

  Future<Either<Failure, ClientEntity>> call(AddClientParams params) async {
    try {
      return await _repository.addClient(params);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
    }
  }
}
```

### Cubit Calls UseCase — Never Repository or Firebase Directly

```dart
final result = await _addClientUseCase(params);
result.fold(
  (failure) => emit(ClientState.failure(failure.message)),
  (client)  => emit(ClientState.success(client)),
);
```

### DI Registration

```dart
// core/di/injection.dart
sl.registerLazySingleton<ClientRepository>(() => ClientRepositoryImpl(sl()));
sl.registerFactory(() => AddClientUseCase(sl()));
sl.registerFactory(() => ClientCubit(sl()));
```

### Network Check — Required in Every Repository Method That Hits Firebase

```dart
// Constructor
final NetworkInfo _networkInfo;

// Helper — copy into every repository
Future<Either<Failure, T>?> _checkNetwork<T>() async {
  if (!await _networkInfo.isConnected) {
    return Left(NetworkFailure('لا يوجد اتصال بالإنترنت'));
  }
  return null;
}

// Usage at the top of every async repository method
final offline = await _checkNetwork<ReturnType>();
if (offline != null) return offline;
```

> Streams (`watchClients`, etc.) do **not** need a connectivity pre-check — Firebase handles reconnection automatically.

### Atomic Writes — Required for All Multi-Document Operations

All multi-document Firestore writes **must** use `runTransaction` or `WriteBatch`. Never loop over individual `set()`/`update()` calls. See `docs/firestore-schema.md` for the full atomic operation spec per action (pay installment, reverse payment, create installment, etc.).

### Computed Values — Never in UI Layer

Formulas (monthly amount, profit per payment, office commission, payment status) are computed in use cases or `core/utils/status_utils.dart`, never in widgets or Cubits.

### Payment Status Computation

```dart
// Installment payments — due day is always the 10th of the month
PaymentStatus computeInstallmentPaymentStatus(DateTime dueDate)

// Grace periods — grace window = dueDate + 10 days
GracePeriodStatus computeGracePeriodStatus(DateTime dueDate)
```

### Status Refresh on App Start

On authenticated app open, run `RefreshPaymentStatusesUseCase` once to batch-update stale `upcoming/current` → `overdue` statuses. Batch writes are chunked at 499 (Firestore limit is 500).

---

## Firestore Structure

All data is isolated under `users/{userId}/`:

| Collection | Notes |
|---|---|
| `clients/{clientId}` | Denormalized totals: `totalPaid`, `totalRemaining`, `paymentQualityScore` |
| `installments/{installmentId}` | Locked for edit after first payment (`editLocked: true`) |
| `payments/{paymentId}` | Flat collection of all monthly installment payments. `dueDate` is always day 10. `dueMonth` is `"YYYY-MM"` string for range queries |
| `gracePeriods/{gracePeriodId}` | Single-payment debts. `gracePeriodEndDate = dueDate + 10 days` |
| `transactions/{transactionId}` | Immutable audit log. Reversals set `status = 'reversed'` — never delete |
| `aggregates/monthly/{yearMonth}` | Pre-computed monthly collection totals |
| `aggregates/allTime` | Pre-computed all-time totals |

**Firestore field naming:** `camelCase` — `fullName`, `createdAt`, `totalAmount`.
**Collection naming:** `camelCase` plural — `clients`, `installments`, `gracePeriods`.
**Route naming:** `kebab-case` path segments — `/client-detail/:id`, `/add-installment`.

---

## Theming & Localization

- Two themes: **dark** (default) and **light**. Persisted in `SharedPreferences` key: `app_theme`.
- Two locales: **ar** (default, RTL, Cairo font) and **en** (LTR, Inter font). Persisted under key: `app_language`.
- Use `AppTheme.dark(languageCode:)` / `AppTheme.light(languageCode:)` — already implemented.
- Typography: `AppTypography.forLocale(languageCode)` — returns Cairo for Arabic, Inter for English.
- All user-facing strings must be added to **both** `app_ar.arb` and `app_en.arb`. Keep keys in the same order in both files.
- Localization key format: `camelCase`, prefixed with feature name — `clientsTitle`, `authLoginButton`, `installmentsDueDate`.

---

## UX Requirements

Every async Firebase operation must:
1. Show a **loading indicator** — full-page spinner for page loads; disable button + show spinner during actions
2. Show a **SnackBar** on success (green, 3s) or error (red, 4s)

Confirmation required via `AlertDialog` or `BottomSheet` before: paying installment, paying grace period, paying office commission, reversing payment, deleting client, logout.

Every list screen must handle **empty state** with an icon, localized message, and action button where applicable.

---

## GoRouter Auth Guard

Root `/` redirects to `/login` if `FirebaseAuth.instance.currentUser == null`, otherwise to `/dashboard`. Main screens (`/dashboard`, `/clients`, `/accounts`, `/settings`) are wrapped in a `ShellRoute` for persistent bottom navigation.

---

## Error Handling

- Every UseCase wraps its body in `try/catch` and returns `Left(Failure)` on error.
- Failure subclasses: `ServerFailure`, `NetworkFailure`, `AuthFailure`, `PermissionFailure`, `ValidationFailure`, `EditLockedFailure`, `AlreadyPaidFailure`.
- Failure types must be **specific** — never catch a generic `Exception`.
- User-facing errors must be mapped to **localized Arabic strings** — never show raw exceptions.
- Log all errors with `Logger('<FeatureName>')` — e.g. `Logger('ClientsRepo')`.

---

## Tech Stack

| Package | Purpose |
|---|---|
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Backend |
| `flutter_bloc` | Cubit/BLoC state management |
| `get_it` + `injectable` | Dependency injection (`sl`) |
| `dartz` | `Either<Failure, T>` functional returns |
| `equatable` | Value equality for entities and states |
| `freezed` + `freezed_annotation` | Sealed state classes and immutable models |
| `json_serializable` + `json_annotation` | Firestore DTO serialization |
| `go_router` | Navigation with auth guard |
| `logger` | Logging — tag with feature name |
| `intl` | Date/currency formatting |
| `shared_preferences` | Persisting theme/language settings |
| `connectivity_plus` | Network connectivity detection |

> Do not add packages without asking first.

---

## Naming Conventions

### Files

| Type | Pattern | Example |
|---|---|---|
| All Dart files | `snake_case.dart` | `client_repository_impl.dart` |
| Test files | `<subject>_test.dart` | `add_client_use_case_test.dart` |

### Classes

| Type | Pattern | Example |
|---|---|---|
| Entity | `<Name>Entity` | `ClientEntity`, `InstallmentEntity` |
| DTO / Model | `<Name>Model` | `ClientModel`, `InstallmentModel` |
| Abstract repository | `<Name>Repository` | `ClientRepository` |
| Repository impl | `<Name>RepositoryImpl` | `ClientRepositoryImpl` |
| Abstract data source | `<Name>RemoteDataSource` | `ClientRemoteDataSource` |
| Data source impl | `<Name>RemoteDataSourceImpl` | `ClientRemoteDataSourceImpl` |
| UseCase | `<Verb><Name>UseCase` | `AddClientUseCase`, `GetClientUseCase` |
| UseCase params | `<Verb><Name>Params` | `AddClientParams` |
| Cubit | `<Name>Cubit` | `ClientCubit` |
| Bloc | `<Name>Bloc` | `PaymentBloc` |
| State (freezed) | `<Name>State` | `ClientState` |
| Event (Bloc) | `<Name>Event` | `PaymentEvent` |
| Page / Screen | `<Name>Page` | `ClientListPage`, `ClientDetailPage` |
| Reusable widget | Descriptive noun | `InstallmentCard`, `AmountSummaryRow` |
| Exception | `<Name>Exception` | `ServerException`, `NetworkException` |
| Failure | `<Name>Failure` | `NetworkFailure`, `AuthFailure` |

### Variables & Methods

- `camelCase` for all local variables, parameters, and method names.
- `_camelCase` (leading underscore) for private fields and methods.
- `lowerCamelCase` for named constructors: `ClientEntity.fromModel(...)`.
- Boolean variables/getters start with `is`, `has`, or `can`: `isLoading`, `hasError`, `canEdit`.

---

## Do

- Add a **file path comment** at the top of every code block.
- Use `const` constructors wherever possible.
- Register every dependency in `core/di/injection.dart`.
- Always go through a UseCase from a Cubit/Bloc — never call a repository or Firebase directly.
- Return `Either<Failure, T>` from every repository method.
- Use Arabic strings in `app_ar.arb` as the primary language.
- Handle all financial calculations in the Domain layer (UseCases/Entities).
- Use `equatable` for all entities and state classes.
- Close Firestore `snapshots()` listeners in the Cubit's `close()` method.
- Use `ListView.builder` for all lists — never `Column` + `.map()` for variable-length data.
- Use pagination (`startAfterDocument`) for any Firestore collection that can grow.
- Always show a loading indicator for async operations that block the UI.
- Always use SnackBar to provide feedback on success or failure of every operation.
- Use `context.read<Cubit>()` to dispatch actions; `BlocBuilder`/`BlocSelector` only for rebuilding.
- Always check `mounted` before using `BuildContext` after any `await` in a widget.
- Use `sl<T>()` to resolve dependencies in widgets — never instantiate services or Cubits manually.
- Format all currency values with `intl` `NumberFormat` — never build currency strings manually.
- Keep all entity fields `final` and use `copyWith` (from `freezed`) for updates.
- Write a **unit test** for every UseCase covering the success path and every failure path.
- Use named parameters for any constructor with more than two parameters.
- Extract magic numbers and repeated string keys into named constants.
- Use `BlocSelector` instead of `BlocBuilder` when only one field of the state is needed.
- Run JSON parsing, financial aggregations, and sorting inside `compute()`.
- Debounce search input (300 ms minimum) in Bloc `on<SearchEvent>` before firing a Firestore query.
- Always attach a `limit()` to every Firestore collection query — never fetch an unbounded collection.
- Use `WriteBatch` when updating more than one document — never loop over `set()`/`update()` calls.
- Update Firestore Security Rules whenever a new collection or field is added.
- Use `AppSpacing` constants for all padding and spacing — never raw pixel values inline.
- Use `EdgeInsetsDirectional` and `AlignmentDirectional` instead of left/right variants.
- Wrap every form page in `SingleChildScrollView` with `resizeToAvoidBottomInset: true`.
---

## Don't

- Don't use `print()` — use `Logger`.
- Don't use `setState` — BLoC/Cubit only.
- Don't catch a generic `Exception` — catch specific types (`ServerException`, `NetworkException`, etc.).
- Don't use `dynamic` — always specify types.
- Don't call Firebase directly from Presentation or Cubit/Bloc layers.
- Don't put business logic inside Cubits or the UI — keep it in UseCases.
- Don't hardcode strings or colors — use localization keys and `Theme.of(context)`.
- Don't wrap large widget trees in `BlocBuilder` — wrap only the widget that changes.
- Don't run heavy operations (Firestore queries, JSON parsing, calculations) on the UI thread — use `compute()`.
- Don't ignore an `Either` return value — always call `.fold()` on it.
- Don't use `DateTime.now()` inside domain entities or use cases — inject current time as a parameter for testability.
- Don't use `as` casts blindly — prefer `is` checks or safe casting patterns.
- Don't store sensitive data (tokens, credentials) in `SharedPreferences` — use `flutter_secure_storage` if needed.
- Don't navigate or show dialogs inside a Cubit/Bloc — emit a state and react to it in the UI layer.
- Don't create a new `TextEditingController` or `ScrollController` inside `build()` — declare in state and dispose in `dispose()`.
- Don't use `shrinkWrap: true` inside a `SingleChildScrollView` — it forces measuring all children at once.
- Don't ignore `StreamSubscription` — cancel them in `Cubit.close()` / `Bloc.close()`.
- Don't hold a reference to `BuildContext` in a Cubit or any long-lived object.
- Don't add packages without asking first.
- Don't hardcode `fontSize` values — use `textTheme` styles only.
- Don't use `EdgeInsets.only(left/right)` or `Alignment.centerLeft/Right` — breaks RTL.
- Don't hardcode pixel widths or heights — use fractional sizing or `LayoutBuilder`.

---

## Performance Rules

### Widget Rebuilds
- Use `BlocSelector` instead of `BlocBuilder` when only one field of the state is needed — rebuilds only when that field changes.
- Split large pages into smaller `StatelessWidget`s so Flutter can skip unchanged subtrees.
- Prefer `const` widgets at every level — a `const` subtree is never re-evaluated.
- Use `RepaintBoundary` around widgets that animate or update frequently (charts, counters).

### Lists & Scrolling
- Always use `ListView.builder` / `SliverList` with `itemCount`.
- Use `const` item widgets wherever possible so unchanged tiles are never rebuilt.
- Implement cursor-based Firestore pagination (`startAfterDocument`) for every growing collection.
- Avoid `shrinkWrap: true` inside `SingleChildScrollView`.

### Firestore Queries
- Always attach `limit()` to every collection query.
- Use compound queries with composite indexes — filter in Firestore, not in Dart.
- Cache the last `DocumentSnapshot` for pagination instead of re-querying from start.
- Use `select()` projections when only a subset of fields is needed (e.g. list views).
- Batch writes with `WriteBatch` for multi-document operations.

### Async & Compute
- Run JSON parsing, financial aggregations, and sorting inside `compute()`.
- Avoid `await` inside `build()` — trigger async work in Cubit/Bloc and react to emitted states.
- Debounce search input (300 ms minimum) before firing a Firestore query.

### Memory
- Cancel `StreamSubscription`s in `Cubit.close()` / `Bloc.close()`.
- Dispose `AnimationController`, `TextEditingController`, and `ScrollController` in `State.dispose()`.
- Don't hold a reference to `BuildContext` in a Cubit or long-lived object.

## Responsive Rules

### Layout
- Never hardcode widths or heights — use `MediaQuery.sizeOf(context)`,
  `LayoutBuilder`, or fractional sizing (`double screenWidth = MediaQuery.sizeOf(context).width`).
- Use `Flexible` and `Expanded` inside `Row`/`Column` instead of fixed pixel widths.
- Minimum tappable area is 48×48 dp — wrap small icons in `SizedBox` or use `IconButton`.
- Use `SafeArea` on every top-level page widget — never assume screen insets are zero.

### Text & Fonts
- Never hardcode `fontSize` — use `Theme.of(context).textTheme` styles only
  (`titleLarge`, `bodyMedium`, etc.).
- Set `textScaler: TextScaler.noScaling` only on decorative/icon text —
  all body and label text must respect system font scale.

### Keyboard & Scroll
- Wrap every form page in `SingleChildScrollView` + `resizeToAvoidBottomInset: true`
  so fields are never hidden behind the keyboard.
- Add `SizedBox(height: MediaQuery.viewInsetsOf(context).bottom)` at the bottom
  of scrollable forms as a keyboard-aware spacer.

### Spacing & Padding
- Define all spacing as named constants in `core/constants/app_spacing.dart`
  (e.g. `AppSpacing.sm = 8`, `AppSpacing.md = 16`, `AppSpacing.lg = 24`).
- Never write raw `EdgeInsets.all(16)` inline — always use `AppSpacing` constants.

### RTL / LTR
- Never use `Alignment.centerLeft` / `centerRight` or `EdgeInsets.only(left/right)` —
  use `Alignment.centerStart` / `centerEnd` and `EdgeInsetsDirectional` instead.
- All icons that imply direction (arrows, chevrons) must be flipped for RTL —
  use `Directionality.of(context)` or `Transform.flip` when needed.
- Test every new screen in both `ar` and `en` locales before marking it done.