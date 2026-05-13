// lib/core/presentation/widgets/status_badge.dart

import 'package:flutter/material.dart';

import '../../utils/status_utils.dart';

enum StatusLabel { upcoming, current, overdue, paid, graceWindow, reversed }

extension PaymentStatusToLabel on PaymentStatus {
  StatusLabel toLabel() => switch (this) {
        PaymentStatus.upcoming => StatusLabel.upcoming,
        PaymentStatus.current => StatusLabel.current,
        PaymentStatus.overdue => StatusLabel.overdue,
        PaymentStatus.paid => StatusLabel.paid,
        PaymentStatus.reversed => StatusLabel.reversed,
      };
}

extension GracePeriodStatusToLabel on GracePeriodStatus {
  StatusLabel toLabel() => switch (this) {
        GracePeriodStatus.upcoming => StatusLabel.upcoming,
        GracePeriodStatus.graceWindow => StatusLabel.graceWindow,
        GracePeriodStatus.overdue => StatusLabel.overdue,
        GracePeriodStatus.paid => StatusLabel.paid,
      };
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final StatusLabel status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _resolve(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }

  (String, Color, Color) _resolve(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (status) {
      StatusLabel.upcoming => ('قادم', cs.primary.withAlpha(30), cs.primary),
      StatusLabel.current => ('جاري', cs.tertiary.withAlpha(30), cs.tertiary),
      StatusLabel.overdue => ('متأخر', cs.error.withAlpha(30), cs.error),
      StatusLabel.paid => ('مدفوع', cs.secondary.withAlpha(30), cs.secondary),
      StatusLabel.graceWindow => ('مهلة', cs.tertiary.withAlpha(30), cs.tertiary),
      StatusLabel.reversed => ('محول', cs.onSurfaceVariant.withAlpha(30), cs.onSurfaceVariant),
    };
  }
}
