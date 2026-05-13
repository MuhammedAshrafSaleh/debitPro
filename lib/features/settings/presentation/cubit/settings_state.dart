// lib/features/settings/presentation/cubit/settings_state.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.themeMode,
    required this.languageCode,
  });

  final ThemeMode themeMode;
  final String languageCode;

  SettingsState copyWith({ThemeMode? themeMode, String? languageCode}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
      );

  @override
  List<Object?> get props => [themeMode, languageCode];
}
