// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const int kPaymentDueDay = 10;
  static const int kGraceWindowDays = 10;
  static const double kOfficeCommissionRate = 0.10;
  static const List<int> kAllowedDurationMonths = [3, 6, 9, 12, 24];
  static const int kBatchLimit = 499;

  // Set to false before App Store / Play Store upload
  static const bool kShowOwnerSettings = true;

  // SharedPreferences keys
  static const String kLocaleKey = 'app_language';
  static const String kThemeKey = 'app_theme';
}
