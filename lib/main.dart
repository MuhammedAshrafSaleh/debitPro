// lib/main.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'config/l10n/app_localizations.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'core/di/injection.dart';
import 'core/presentation/widgets/offline_banner.dart';
import 'features/payments/domain/usecases/refresh_payment_statuses_use_case.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/settings/presentation/cubit/settings_state.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await configureDependencies();

  runApp(const DebtProApp());
}

class DebtProApp extends StatefulWidget {
  const DebtProApp({super.key});

  @override
  State<DebtProApp> createState() => _DebtProAppState();
}
  
class _DebtProAppState extends State<DebtProApp> {
  StreamSubscription<User?>? _authSub;
  String? _lastRefreshedUid;
  bool _isRefreshing = false;
  final _log = Logger();

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null || !user.emailVerified) {
      _lastRefreshedUid = null;
      return;
    }
    if (_lastRefreshedUid == user.uid) return;
    _lastRefreshedUid = user.uid;

    if (mounted) setState(() => _isRefreshing = true);

    final result = await sl<RefreshPaymentStatusesUseCase>().call();

    if (mounted) setState(() => _isRefreshing = false);

    result.fold(
      (failure) => _log.w('Status refresh failed: ${failure.message}'),
      (res) => _log.i(
        'Status refresh: ${res.paymentsUpdated} payments, '
        '${res.gracePeriodsUpdated} grace periods updated',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'DebtPro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(languageCode: settings.languageCode),
            darkTheme: AppTheme.dark(languageCode: settings.languageCode),
            themeMode: settings.themeMode,
            locale: Locale(settings.languageCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: buildRouter(),
            builder: (context, child) => OfflineBanner(
              child: Stack(
                children: [
                  child!,
                  if (_isRefreshing)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
