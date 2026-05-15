// lib/features/accounts/presentation/widgets/overdue_client_tile.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/accounts_item.dart';

class OverdueClientTile extends StatelessWidget {
  const OverdueClientTile({super.key, required this.info});

  final OverdueClientInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading:
            AvatarWidget(name: info.client.fullName, id: info.client.id, radius: 22),
        title: Text(info.client.fullName, style: tt.titleSmall),
        subtitle: Padding(
          padding: const EdgeInsetsDirectional.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 14, color: cs.error),
              const SizedBox(width: 4),
              Text(
                l10n.accountsOverdueDays(info.daysOverdue),
                style: tt.labelSmall?.copyWith(color: cs.error),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.accountsOverdueItemsCount(info.overdueItemsCount),
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        trailing: Text(
          CurrencyUtils.formatCurrency(info.totalOverdueAmount, locale),
          style: tt.titleSmall?.copyWith(
            color: cs.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => context.push('/clients/${info.client.id}'),
      ),
    );
  }
}
