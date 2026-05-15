// lib/features/dashboard/presentation/widgets/recent_transaction_tile.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/relative_time_utils.dart';
import '../../../payments/domain/entities/transaction_entity.dart';

class RecentTransactionTile extends StatelessWidget {
  const RecentTransactionTile({
    super.key,
    required this.transaction,
    required this.clientName,
  });

  final TransactionEntity transaction;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final displayName = clientName.isEmpty ? '—' : clientName;

    final typeLabel = switch (transaction.relatedType) {
      RelatedType.installmentPayment => l10n.dashboardTxInstallment,
      RelatedType.gracePeriod => l10n.dashboardTxGracePeriod,
      RelatedType.officeCommission => l10n.dashboardTxOfficeCommission,
    };
    final relative = RelativeTimeUtils.format(
      from: transaction.createdAt,
      now: DateTime.now(),
      languageCode: locale,
    );

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/clients/${transaction.clientId}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AvatarWidget(
                  name: displayName,
                  id: transaction.clientId,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$typeLabel · $relative',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${CurrencyUtils.formatCurrency(transaction.amount, locale)}',
                  style: tt.titleSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
