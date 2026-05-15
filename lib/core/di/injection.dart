// lib/core/di/injection.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/network_info.dart';
import '../../features/clients/data/datasources/firestore_client_datasource.dart';
import '../../features/clients/data/repositories/client_repository_impl.dart';
import '../../features/clients/domain/repositories/client_repository.dart';
import '../../features/clients/domain/usecases/watch_clients_use_case.dart';
import '../../features/clients/domain/usecases/get_client_detail_use_case.dart';
import '../../features/clients/domain/usecases/add_client_use_case.dart';
import '../../features/clients/domain/usecases/edit_client_use_case.dart';
import '../../features/clients/domain/usecases/delete_client_use_case.dart';
import '../../features/clients/presentation/cubit/client_list_cubit.dart';
import '../../features/clients/presentation/cubit/client_detail_cubit.dart';
import '../../features/clients/presentation/cubit/add_client_cubit.dart';
import '../../features/clients/presentation/cubit/edit_client_cubit.dart';
import '../../features/settings/data/datasources/firebase_user_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/change_language_use_case.dart';
import '../../features/settings/domain/usecases/load_preferences_use_case.dart';
import '../../features/settings/domain/usecases/toggle_theme_use_case.dart';
import '../../features/settings/domain/usecases/update_display_name_use_case.dart';
import '../../features/settings/domain/usecases/update_email_use_case.dart';
import '../../features/settings/domain/usecases/update_password_use_case.dart';
import '../../features/settings/presentation/cubit/edit_account_cubit.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_email_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/auth/domain/usecases/send_password_reset_email_use_case.dart';
import '../../features/auth/domain/usecases/send_verification_email_use_case.dart';
import '../../features/auth/domain/usecases/reload_user_use_case.dart';
import '../../features/auth/domain/usecases/sign_out_use_case.dart';
import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubit/verify_email_cubit.dart';
import '../../features/installments/data/datasources/firestore_installment_datasource.dart';
import '../../features/installments/data/repositories/installment_repository_impl.dart';
import '../../features/installments/domain/repositories/installment_repository.dart';
import '../../features/installments/domain/usecases/add_installment_use_case.dart';
import '../../features/installments/domain/usecases/delete_installment_use_case.dart';
import '../../features/installments/domain/usecases/edit_installment_use_case.dart';
import '../../features/installments/domain/usecases/get_installment_with_payments_use_case.dart';
import '../../features/installments/domain/usecases/pay_office_commission_use_case.dart';
import '../../features/installments/domain/usecases/watch_installments_for_client_use_case.dart';
import '../../features/installments/presentation/cubit/add_installment_cubit.dart';
import '../../features/installments/presentation/cubit/client_installments_cubit.dart';
import '../../features/installments/presentation/cubit/edit_installment_cubit.dart';
import '../../features/installments/presentation/cubit/installment_tracking_cubit.dart';
import '../../features/grace_periods/data/datasources/firestore_grace_period_datasource.dart';
import '../../features/grace_periods/data/repositories/grace_period_repository_impl.dart';
import '../../features/grace_periods/domain/repositories/grace_period_repository.dart';
import '../../features/grace_periods/domain/usecases/add_grace_period_use_case.dart';
import '../../features/grace_periods/domain/usecases/edit_grace_period_use_case.dart';
import '../../features/grace_periods/domain/usecases/get_grace_period_use_case.dart';
import '../../features/grace_periods/domain/usecases/pay_grace_period_office_commission_use_case.dart';
import '../../features/grace_periods/domain/usecases/watch_grace_periods_for_client_use_case.dart';
import '../../features/grace_periods/presentation/cubit/add_grace_period_cubit.dart';
import '../../features/grace_periods/presentation/cubit/client_grace_periods_cubit.dart';
import '../../features/grace_periods/presentation/cubit/edit_grace_period_cubit.dart';
import '../../features/payments/data/datasources/firestore_payment_datasource.dart';
import '../../features/payments/data/datasources/status_refresh_datasource.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/domain/usecases/get_transactions_use_case.dart';
import '../../features/payments/domain/usecases/pay_grace_period_use_case.dart' as pay_use;
import '../../features/payments/domain/usecases/pay_installment_payment_use_case.dart' as pay_use_inst;
import '../../features/payments/domain/usecases/refresh_payment_statuses_use_case.dart';
import '../../features/payments/domain/usecases/reverse_payment_use_case.dart';
import '../../features/payments/domain/usecases/watch_transactions_for_client_use_case.dart';
import '../../features/payments/presentation/bloc/payment_bloc.dart';
import '../../features/accounts/data/datasources/firestore_accounts_datasource.dart';
import '../../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../../features/accounts/domain/repositories/accounts_repository.dart';
import '../../features/accounts/domain/usecases/get_accounts_list_use_case.dart';
import '../../features/accounts/domain/usecases/get_transactions_pdf_use_case.dart';
import '../../features/accounts/presentation/cubit/accounts_cubit.dart';
import '../../features/dashboard/data/datasources/firestore_dashboard_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_data_use_case.dart';
import '../../features/dashboard/domain/usecases/get_recent_transactions_use_case.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core singletons ────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ── Features ───────────────────────────────────────────────────────────────
  initSettings();
  initAuth();
  initClients();
  initInstallments();
  initGracePeriods();
  initPayments();
  initAccounts();
  initDashboard();
}

// Each phase fills in its own initializer.

void initSettings() {
  // Data source
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => LoadPreferencesUseCase(sl()));
  sl.registerFactory(() => ToggleThemeUseCase(sl()));
  sl.registerFactory(() => ChangeLanguageUseCase(sl()));
  sl.registerFactory(() => UpdateDisplayNameUseCase(sl()));
  sl.registerFactory(() => UpdateEmailUseCase(sl()));
  sl.registerFactory(() => UpdatePasswordUseCase(sl()));

  // Cubits
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<EditAccountCubit>(
    () => EditAccountCubit(sl(), sl(), sl()),
  );
}

void initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => SignInWithEmailUseCase(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => SendPasswordResetEmailUseCase(sl()));
  sl.registerFactory(() => SendVerificationEmailUseCase(sl()));
  sl.registerFactory(() => ReloadUserUseCase(sl()));
  sl.registerFactory(() => SignOutUseCase(sl()));
  sl.registerFactory(() => GetCurrentUserUseCase(sl()));

  // Cubits
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(() => RegisterCubit(sl()));
  sl.registerFactory(() => ForgotPasswordCubit(sl()));
  sl.registerFactory(
    () => VerifyEmailCubit(sl(), sl(), sl(), sl()),
  );
}

void initClients() {
  // Data source
  sl.registerLazySingleton<ClientRemoteDataSource>(
    () => ClientRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => WatchClientsUseCase(sl()));
  sl.registerFactory(() => GetClientDetailUseCase(sl()));
  sl.registerFactory(() => AddClientUseCase(sl()));
  sl.registerFactory(() => EditClientUseCase(sl()));
  sl.registerFactory(() => DeleteClientUseCase(sl()));

  // Cubits
  sl.registerFactory(() => ClientListCubit(sl()));
  sl.registerFactory(() => ClientDetailCubit(sl()));
  sl.registerFactory(() => AddClientCubit(sl()));
  sl.registerFactory(() => EditClientCubit(sl(), sl()));
}

void initInstallments() {
  // Data source
  sl.registerLazySingleton<InstallmentRemoteDataSource>(
    () => InstallmentRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<InstallmentRepository>(
    () => InstallmentRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => AddInstallmentUseCase(sl()));
  sl.registerFactory(() => EditInstallmentUseCase(sl()));
  sl.registerFactory(() => GetInstallmentWithPaymentsUseCase(sl()));
  sl.registerFactory(() => PayOfficeCommissionUseCase(sl()));
  sl.registerFactory(() => WatchInstallmentsForClientUseCase(sl()));
  sl.registerFactory(() => DeleteInstallmentUseCase(sl()));

  // Cubits
  sl.registerFactory(() => AddInstallmentCubit(sl()));
  sl.registerFactory(() => EditInstallmentCubit(sl(), sl()));
  sl.registerFactory(() => InstallmentTrackingCubit(sl(), sl(), sl()));
  sl.registerFactory(() => ClientInstallmentsCubit(sl()));
}

void initGracePeriods() {
  // Data source
  sl.registerLazySingleton<GracePeriodRemoteDataSource>(
    () => GracePeriodRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<GracePeriodRepository>(
    () => GracePeriodRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => AddGracePeriodUseCase(sl()));
  sl.registerFactory(() => EditGracePeriodUseCase(sl()));
  sl.registerFactory(() => GetGracePeriodUseCase(sl()));
  sl.registerFactory(() => PayGracePeriodOfficeCommissionUseCase(sl()));
  sl.registerFactory(() => WatchGracePeriodsForClientUseCase(sl()));

  // Cubits
  sl.registerFactory(() => AddGracePeriodCubit(sl()));
  sl.registerFactory(() => EditGracePeriodCubit(sl(), sl()));
  sl.registerFactory(() => ClientGracePeriodsCubit(sl(), sl()));
}

void initPayments() {
  // Data sources
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<StatusRefreshDataSource>(
    () => StatusRefreshDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => pay_use_inst.PayInstallmentPaymentUseCase(sl()));
  sl.registerFactory(() => pay_use.PayGracePeriodUseCase(sl()));
  sl.registerFactory(() => ReversePaymentUseCase(sl()));
  sl.registerFactory(() => GetTransactionsUseCase(sl()));
  sl.registerFactory(() => WatchTransactionsForClientUseCase(sl()));
  sl.registerFactory(() => RefreshPaymentStatusesUseCase(sl(), sl()));

  // Bloc
  sl.registerFactory(() => PaymentBloc(sl(), sl(), sl(), sl()));
}

void initAccounts() {
  // Data source
  sl.registerLazySingleton<AccountsRemoteDataSource>(
    () => AccountsRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => GetAccountsListUseCase(sl()));
  sl.registerFactory(() => GetTransactionsPdfUseCase(sl()));

  // Cubit
  sl.registerFactory(() => AccountsCubit(sl()));
}

void initDashboard() {
  // Data source
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(sl(), sl()),
  );

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl(), sl()),
  );

  // Use cases
  sl.registerFactory(() => GetDashboardDataUseCase(sl()));
  sl.registerFactory(() => GetRecentTransactionsUseCase(sl()));

  // Cubit
  sl.registerFactory(() => DashboardCubit(sl()));
}
