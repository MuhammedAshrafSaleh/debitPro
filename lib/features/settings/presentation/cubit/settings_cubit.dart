// lib/features/settings/presentation/cubit/settings_cubit.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/change_language_use_case.dart';
import '../../domain/usecases/load_preferences_use_case.dart';
import '../../domain/usecases/toggle_theme_use_case.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._prefs,
    this._loadPreferences,
    this._toggleTheme,
    this._changeLanguage,
    this._auth,
  ) : super(const SettingsState(
          themeMode: ThemeMode.dark,
          languageCode: 'ar',
        )) {
    _loadLocalPreferences();
    _listenToAuth();
  }

  final SharedPreferences _prefs;
  final LoadPreferencesUseCase _loadPreferences;
  final ToggleThemeUseCase _toggleTheme;
  final ChangeLanguageUseCase _changeLanguage;
  final FirebaseAuth _auth;

  StreamSubscription<User?>? _authSub;
  String? _uid;

  void _loadLocalPreferences() {
    final isDark = _prefs.getBool(AppConstants.kThemeKey) ?? true;
    final locale = _prefs.getString(AppConstants.kLocaleKey) ?? 'ar';
    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      languageCode: locale,
    ));
  }

  void _listenToAuth() {
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _uid = user.uid;
        _syncWithFirestore(user.uid);
      } else {
        _uid = null;
      }
    });
  }

  Future<void> _syncWithFirestore(String uid) async {
    final result = await _loadPreferences(uid);
    result.fold(
      (_) {},
      (prefs) async {
        final isDark = prefs['darkMode'] as bool? ?? true;
        final lang = prefs['language'] as String? ?? 'ar';
        await _prefs.setBool(AppConstants.kThemeKey, isDark);
        await _prefs.setString(AppConstants.kLocaleKey, lang);
        if (!isClosed) {
          emit(state.copyWith(
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            languageCode: lang,
          ));
        }
      },
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    final isDark = mode == ThemeMode.dark;
    await _prefs.setBool(AppConstants.kThemeKey, isDark);
    emit(state.copyWith(themeMode: mode));
    if (_uid != null) {
      await _toggleTheme(ThemeParams(uid: _uid!, isDark: isDark));
    }
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setString(AppConstants.kLocaleKey, code);
    emit(state.copyWith(languageCode: code));
    if (_uid != null) {
      await _changeLanguage(LanguageParams(uid: _uid!, languageCode: code));
    }
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
