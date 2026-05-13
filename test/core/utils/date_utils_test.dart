// test/core/utils/date_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:debit_pro/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils.yearMonthKey', () {
    test('pads single-digit month', () {
      expect(AppDateUtils.yearMonthKey(DateTime(2024, 3, 15)), '2024-03');
    });

    test('handles December', () {
      expect(AppDateUtils.yearMonthKey(DateTime(2024, 12, 1)), '2024-12');
    });
  });

  group('AppDateUtils.firstDayOfMonth', () {
    test('returns day 1 of the same month', () {
      final result = AppDateUtils.firstDayOfMonth(DateTime(2024, 5, 20));
      expect(result, DateTime(2024, 5, 1));
    });
  });

  group('AppDateUtils.lastDayOfMonth', () {
    test('returns last day for February in a leap year', () {
      expect(AppDateUtils.lastDayOfMonth(DateTime(2024, 2, 1)), DateTime(2024, 2, 29));
    });

    test('returns 30 for April', () {
      expect(AppDateUtils.lastDayOfMonth(DateTime(2024, 4, 1)), DateTime(2024, 4, 30));
    });

    test('returns 31 for January', () {
      expect(AppDateUtils.lastDayOfMonth(DateTime(2024, 1, 1)), DateTime(2024, 1, 31));
    });
  });

  group('AppDateUtils.addMonths', () {
    test('adds months within the same year', () {
      expect(AppDateUtils.addMonths(DateTime(2024, 1, 10), 3), DateTime(2024, 4, 10));
    });

    test('rolls over to the next year', () {
      expect(AppDateUtils.addMonths(DateTime(2024, 11, 10), 3), DateTime(2025, 2, 10));
    });

    test('clamps day when target month is shorter', () {
      // Jan 31 + 1 month → Feb 29 (2024 is a leap year)
      expect(AppDateUtils.addMonths(DateTime(2024, 1, 31), 1), DateTime(2024, 2, 29));
    });
  });

  group('AppDateUtils.daysBetween', () {
    test('returns 0 for the same day', () {
      expect(AppDateUtils.daysBetween(DateTime(2024, 5, 1), DateTime(2024, 5, 1)), 0);
    });

    test('returns positive days forward', () {
      expect(AppDateUtils.daysBetween(DateTime(2024, 5, 1), DateTime(2024, 5, 11)), 10);
    });

    test('returns negative days backward', () {
      expect(AppDateUtils.daysBetween(DateTime(2024, 5, 11), DateTime(2024, 5, 1)), -10);
    });

    test('ignores time component', () {
      expect(
        AppDateUtils.daysBetween(
          DateTime(2024, 5, 1, 23, 59),
          DateTime(2024, 5, 2, 0, 1),
        ),
        1,
      );
    });
  });
}
