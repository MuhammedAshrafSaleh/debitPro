// lib/features/dashboard/presentation/widgets/collection_hero_card.dart

import 'package:flutter/material.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/dashboard_data.dart';

class CollectionHeroCard extends StatelessWidget {
  const CollectionHeroCard({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = data.collectionProgress;
    final percent = (progress * 100).round();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardMonthlyCollection,
              style: tt.labelMedium?.copyWith(
                color: cs.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyUtils.formatCurrency(data.monthlyCollection, locale),
              style: tt.headlineMedium?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.onPrimary.withValues(alpha: 0.2),
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.onPrimary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$percent%',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onPrimary.withValues(alpha: 0.9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: Text(
                    l10n.dashboardMonthlyTarget(
                      CurrencyUtils.formatCurrency(data.monthlyTarget, locale),
                    ),
                    style: tt.labelMedium?.copyWith(
                      color: cs.onPrimary.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
