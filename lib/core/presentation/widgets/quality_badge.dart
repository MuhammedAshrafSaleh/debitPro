// lib/core/presentation/widgets/quality_badge.dart

import 'package:flutter/material.dart';
import '../../../config/l10n/app_localizations.dart';

import '../../utils/status_utils.dart';

class QualityBadgeWidget extends StatelessWidget {
  const QualityBadgeWidget({super.key, required this.badge});

  final QualityBadge badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final (label, bg, fg) = switch (badge) {
      QualityBadge.excellent => (l10n.qualityBadgeExcellent, cs.secondary.withAlpha(30), cs.secondary),
      QualityBadge.good => (l10n.qualityBadgeGood, cs.primary.withAlpha(30), cs.primary),
      QualityBadge.fair => (l10n.qualityBadgeFair, cs.tertiary.withAlpha(30), cs.tertiary),
      QualityBadge.poor => (l10n.qualityBadgePoor, cs.error.withAlpha(30), cs.error),
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
