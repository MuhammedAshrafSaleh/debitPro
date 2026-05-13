// lib/core/utils/status_utils.dart

import '../constants/app_constants.dart';

enum PaymentStatus { upcoming, current, overdue, paid, reversed }

enum GracePeriodStatus { upcoming, graceWindow, overdue, paid }

enum QualityBadge { excellent, good, fair, poor }

class StatusUtils {
  StatusUtils._();

  /// Due day is always the 10th of the month.
  /// - Before the 10th of due month → upcoming
  /// - On or after the 10th (within same month) → current
  /// - Past due month → overdue
  static PaymentStatus computeInstallmentPaymentStatus(
    DateTime dueDate,
    DateTime now,
  ) {
    final due = DateTime(dueDate.year, dueDate.month, AppConstants.kPaymentDueDay);
    final today = DateTime(now.year, now.month, now.day);

    if (today.isBefore(due)) return PaymentStatus.upcoming;
    if (today.year == due.year && today.month == due.month) {
      return PaymentStatus.current;
    }
    return PaymentStatus.overdue;
  }

  /// Grace window = dueDate + kGraceWindowDays.
  /// - Before dueDate → upcoming
  /// - Between dueDate and dueDate + grace → graceWindow
  /// - After grace window → overdue
  static GracePeriodStatus computeGracePeriodStatus(
    DateTime dueDate,
    DateTime now,
  ) {
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final graceEnd = due.add(const Duration(days: AppConstants.kGraceWindowDays));
    final today = DateTime(now.year, now.month, now.day);

    if (today.isBefore(due)) return GracePeriodStatus.upcoming;
    if (!today.isAfter(graceEnd)) return GracePeriodStatus.graceWindow;
    return GracePeriodStatus.overdue;
  }

  /// Returns a 0–100 score: (onTime / totalDue) * 100.
  static double qualityScore(int onTime, int totalDue) {
    if (totalDue <= 0) return 100.0;
    return (onTime / totalDue) * 100.0;
  }

  static QualityBadge qualityBadge(double score) {
    if (score >= 90) return QualityBadge.excellent;
    if (score >= 70) return QualityBadge.good;
    if (score >= 50) return QualityBadge.fair;
    return QualityBadge.poor;
  }
}
