// lib/core/utils/relative_time_utils.dart

import 'package:intl/intl.dart';

class RelativeTimeUtils {
  RelativeTimeUtils._();

  /// Returns a localized "X ago" string. For dates older than 7 days, falls
  /// back to a short absolute date (`dd MMM`).
  static String format({
    required DateTime from,
    required DateTime now,
    required String languageCode,
  }) {
    final diff = now.difference(from);

    if (diff.isNegative) {
      // Future dates (clock skew / queued writes) — treat as "just now".
      return _justNow(languageCode);
    }

    if (diff.inSeconds < 60) return _justNow(languageCode);

    if (diff.inMinutes < 60) {
      return languageCode == 'ar'
          ? _arMinutes(diff.inMinutes)
          : _enUnit(diff.inMinutes, 'minute');
    }

    if (diff.inHours < 24) {
      return languageCode == 'ar'
          ? _arHours(diff.inHours)
          : _enUnit(diff.inHours, 'hour');
    }

    if (diff.inDays == 1) {
      return languageCode == 'ar' ? 'أمس' : 'Yesterday';
    }

    if (diff.inDays < 7) {
      return languageCode == 'ar'
          ? _arDays(diff.inDays)
          : _enUnit(diff.inDays, 'day');
    }

    // Always format with en_US so the day number is a Western digit (PRD §3.3).
    return DateFormat('dd MMM', 'en_US').format(from);
  }

  static String _justNow(String code) =>
      code == 'ar' ? 'الآن' : 'Just now';

  static String _enUnit(int n, String unit) =>
      '$n $unit${n == 1 ? '' : 's'} ago';

  static String _arMinutes(int n) {
    if (n == 1) return 'منذ دقيقة';
    if (n == 2) return 'منذ دقيقتين';
    if (n >= 3 && n <= 10) return 'منذ $n دقائق';
    return 'منذ $n دقيقة';
  }

  static String _arHours(int n) {
    if (n == 1) return 'منذ ساعة';
    if (n == 2) return 'منذ ساعتين';
    if (n >= 3 && n <= 10) return 'منذ $n ساعات';
    return 'منذ $n ساعة';
  }

  static String _arDays(int n) {
    if (n == 2) return 'منذ يومين';
    if (n >= 3 && n <= 10) return 'منذ $n أيام';
    return 'منذ $n يوم';
  }
}
