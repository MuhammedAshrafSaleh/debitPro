// lib/features/installments/presentation/widgets/installment_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/installment_entity.dart';

class InstallmentCard extends StatelessWidget {
  const InstallmentCard({super.key, required this.installment});

  final InstallmentEntity installment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isCompleted =
        installment.status == InstallmentStatus.completed;
    final progress = installment.totalPaymentsCount > 0
        ? installment.paidPaymentsCount / installment.totalPaymentsCount
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push('/installments/${installment.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      installment.itemName,
                      style: tt.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? cs.secondary.withValues(alpha: 0.15)
                          : cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isCompleted
                          ? l10n.installmentsStatusCompleted
                          : l10n.installmentsStatusActive,
                      style: tt.labelSmall?.copyWith(
                        color: isCompleted ? cs.secondary : cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyUtils.formatCurrency(
                        installment.monthlyAmount, locale),
                    style: tt.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${installment.paidPaymentsCount}/${installment.totalPaymentsCount}',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: isCompleted ? cs.secondary : cs.primary,
                ),
              ),
              if (!installment.officeCommissionPaid &&
                  installment.officeCommissionAmount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14,
                        color: cs.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.installmentsCommissionPending,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.tertiary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
