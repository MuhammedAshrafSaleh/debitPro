// lib/core/presentation/widgets/quality_badge.dart

import 'package:flutter/material.dart';

import '../../utils/status_utils.dart';

class QualityBadgeWidget extends StatelessWidget {
  const QualityBadgeWidget({super.key, required this.badge});

  final QualityBadge badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, bg, fg) = switch (badge) {
      QualityBadge.excellent => ('ممتاز', cs.secondary.withAlpha(30), cs.secondary),
      QualityBadge.good => ('جيد', cs.primary.withAlpha(30), cs.primary),
      QualityBadge.fair => ('متوسط', cs.tertiary.withAlpha(30), cs.tertiary),
      QualityBadge.poor => ('ضعيف', cs.error.withAlpha(30), cs.error),
    };

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
}
