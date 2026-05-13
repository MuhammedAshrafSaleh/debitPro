// test/core/utils/status_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:debit_pro/core/utils/status_utils.dart';

void main() {
  // ── Installment payment status ──────────────────────────────────────────────

  group('StatusUtils.computeInstallmentPaymentStatus', () {
    // Due date is always treated as the 10th of the given month.

    test('upcoming — today is before the 10th of the due month', () {
      final due = DateTime(2024, 5, 10);
      final now = DateTime(2024, 5, 5);
      expect(
        StatusUtils.computeInstallmentPaymentStatus(due, now),
        PaymentStatus.upcoming,
      );
    });

    test('current — today IS the 10th of the due month', () {
      final due = DateTime(2024, 5, 10);
      final now = DateTime(2024, 5, 10);
      expect(
        StatusUtils.computeInstallmentPaymentStatus(due, now),
        PaymentStatus.current,
      );
    });

    test('current — today is after the 10th but still in the due month', () {
      final due = DateTime(2024, 5, 10);
      final now = DateTime(2024, 5, 25);
      expect(
        StatusUtils.computeInstallmentPaymentStatus(due, now),
        PaymentStatus.current,
      );
    });

    test('overdue — today is in the month after the due month', () {
      final due = DateTime(2024, 5, 10);
      final now = DateTime(2024, 6, 1);
      expect(
        StatusUtils.computeInstallmentPaymentStatus(due, now),
        PaymentStatus.overdue,
      );
    });

    test('overdue — today is many months past due', () {
      final due = DateTime(2024, 1, 10);
      final now = DateTime(2024, 12, 1);
      expect(
        StatusUtils.computeInstallmentPaymentStatus(due, now),
        PaymentStatus.overdue,
      );
    });
  });

  // ── Grace period status ──────────────────────────────────────────────────────

  group('StatusUtils.computeGracePeriodStatus', () {
    test('upcoming — today is before due date', () {
      final due = DateTime(2024, 5, 20);
      final now = DateTime(2024, 5, 15);
      expect(
        StatusUtils.computeGracePeriodStatus(due, now),
        GracePeriodStatus.upcoming,
      );
    });

    test('graceWindow — today is exactly the due date', () {
      final due = DateTime(2024, 5, 20);
      final now = DateTime(2024, 5, 20);
      expect(
        StatusUtils.computeGracePeriodStatus(due, now),
        GracePeriodStatus.graceWindow,
      );
    });

    test('graceWindow — today is within the 10-day window', () {
      final due = DateTime(2024, 5, 20);
      final now = DateTime(2024, 5, 28); // day 8 of window
      expect(
        StatusUtils.computeGracePeriodStatus(due, now),
        GracePeriodStatus.graceWindow,
      );
    });

    test('graceWindow — today is exactly on the last day of the grace window', () {
      final due = DateTime(2024, 5, 20);
      final now = DateTime(2024, 5, 30); // day 10 of window
      expect(
        StatusUtils.computeGracePeriodStatus(due, now),
        GracePeriodStatus.graceWindow,
      );
    });

    test('overdue — today is one day past the grace window', () {
      final due = DateTime(2024, 5, 20);
      final now = DateTime(2024, 5, 31); // day 11 of window
      expect(
        StatusUtils.computeGracePeriodStatus(due, now),
        GracePeriodStatus.overdue,
      );
    });
  });

  // ── Quality score ────────────────────────────────────────────────────────────

  group('StatusUtils.qualityScore', () {
    test('returns 100 when totalDue is 0', () {
      expect(StatusUtils.qualityScore(0, 0), 100.0);
    });

    test('returns 100 when all payments are on time', () {
      expect(StatusUtils.qualityScore(10, 10), 100.0);
    });

    test('returns 50 for half on-time', () {
      expect(StatusUtils.qualityScore(5, 10), 50.0);
    });

    test('returns 0 when none are on time', () {
      expect(StatusUtils.qualityScore(0, 10), 0.0);
    });
  });

  // ── Quality badge ────────────────────────────────────────────────────────────

  group('StatusUtils.qualityBadge', () {
    test('excellent at 90+', () {
      expect(StatusUtils.qualityBadge(90), QualityBadge.excellent);
      expect(StatusUtils.qualityBadge(100), QualityBadge.excellent);
    });

    test('good at 70–89', () {
      expect(StatusUtils.qualityBadge(70), QualityBadge.good);
      expect(StatusUtils.qualityBadge(89), QualityBadge.good);
    });

    test('fair at 50–69', () {
      expect(StatusUtils.qualityBadge(50), QualityBadge.fair);
      expect(StatusUtils.qualityBadge(69), QualityBadge.fair);
    });

    test('poor below 50', () {
      expect(StatusUtils.qualityBadge(49), QualityBadge.poor);
      expect(StatusUtils.qualityBadge(0), QualityBadge.poor);
    });
  });
}
