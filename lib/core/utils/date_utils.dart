// lib/core/utils/date_utils.dart

class AppDateUtils {
  AppDateUtils._();

  /// Returns a `"YYYY-MM"` string for use as a Firestore key.
  static String yearMonthKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  static DateTime firstDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime lastDayOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0);

  /// Adds [months] calendar months to [date], preserving the day where possible.
  static DateTime addMonths(DateTime date, int months) {
    final targetMonth = date.month + months;
    final year = date.year + (targetMonth - 1) ~/ 12;
    final month = ((targetMonth - 1) % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }

  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }
}
