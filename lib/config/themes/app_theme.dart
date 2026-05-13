// lib/config/themes/app_theme.dart

import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'dark_colors.dart';
import 'light_colors.dart';

abstract class AppTheme {
  static ThemeData dark({required String languageCode}) {
    final textTheme = AppTypography.forLocale(languageCode);
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DarkColors.primary,
      onPrimary: DarkColors.onPrimary,
      secondary: DarkColors.secondary,
      onSecondary: DarkColors.onSecondary,
      tertiary: DarkColors.tertiary,
      onTertiary: DarkColors.onTertiary,
      error: DarkColors.error,
      onError: DarkColors.onError,
      surface: DarkColors.surface,
      onSurface: DarkColors.onSurface,
      outline: DarkColors.outline,
      surfaceContainerHighest: DarkColors.surfaceVariant,
      onSurfaceVariant: DarkColors.onSurfaceVariant,
    );
    return _buildTheme(colorScheme, textTheme, DarkColors.base, DarkColors.surface, DarkColors.outline);
  }

  static ThemeData light({required String languageCode}) {
    final textTheme = AppTypography.forLocale(languageCode);
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: LightColors.primary,
      onPrimary: LightColors.onPrimary,
      secondary: LightColors.secondary,
      onSecondary: LightColors.onSecondary,
      tertiary: LightColors.tertiary,
      onTertiary: LightColors.onTertiary,
      error: LightColors.error,
      onError: LightColors.onError,
      surface: LightColors.surface,
      onSurface: LightColors.onSurface,
      outline: LightColors.outline,
      surfaceContainerHighest: LightColors.surfaceVariant,
      onSurfaceVariant: LightColors.onSurfaceVariant,
    );
    return _buildTheme(colorScheme, textTheme, LightColors.base, LightColors.surface, LightColors.outline);
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color scaffoldBg,
    Color surfaceColor,
    Color outlineColor,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      // Filled button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outlineColor.withAlpha(120)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Bottom navigation bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: outlineColor, thickness: 1, space: 1),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colorScheme.primary;
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withAlpha(80);
          }
          return outlineColor;
        }),
      ),
    );
  }
}
