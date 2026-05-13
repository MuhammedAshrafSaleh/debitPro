// lib/main.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/l10n/app_localizations.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'core/di/injection.dart';
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

class DebtProApp extends StatelessWidget {
  const DebtProApp({super.key});

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
          );
        },
      ),
    );
  }
}
