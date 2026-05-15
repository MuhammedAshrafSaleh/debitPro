// lib/features/accounts/presentation/widgets/accounts_item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../domain/entities/accounts_item.dart';

class AccountsItemCard extends StatelessWidget {
  const AccountsItemCard({super.key, required this.item});

  final AccountsItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final isReversed = item.reversed;
    final amountStyle = tt.titleMedium?.copyWith(
      color: cs.primary,
      fontWeight: FontWeight.bold,
      decoration: isReversed ? TextDecoration.lineThrough : null,
      decorationColor: cs.onSurfaceVariant,
    );

    return Card(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.clientName,
                        style: tt.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            item.kind == AccountsItemKind.installmentPayment
                                ? Icons.calendar_view_month_outlined
                                : Icons.hourglass_bottom_outlined,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _TypeChip(kind: item.kind),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyUtils.formatCurrency(item.amount, locale),
                        style: amountStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isPaid && item.paidDate != null
                            ? l10n.accountsPaidOn(_formatDate(locale, item.paidDate!))
                            : _formatDate(locale, item.dueDate),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AvatarWidget(name: item.clientName, id: item.clientId, radius: 22),
                    const SizedBox(height: 10),
                    _StatusPill(status: item.status, reversed: isReversed),
                  ],
                ),
              ],
            ),
            if (!item.isPaid && !isReversed) ...[
              const SizedBox(height: 12),
              _PayButton(item: item),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(String locale, DateTime date) {
    const enMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final months = locale == 'ar' ? arMonths : enMonths;
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.kind});

  final AccountsItemKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final label = kind == AccountsItemKind.installmentPayment
        ? l10n.accountsTypeInstallment
        : l10n.accountsTypeGracePeriod;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.reversed});

  final AccountsItemStatus status;
  final bool reversed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (label, color, icon) = _resolve(l10n, cs);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: tt.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }

  (String, Color, IconData?) _resolve(AppLocalizations l10n, ColorScheme cs) {
    if (reversed) {
      return (l10n.statusReversed, cs.onSurfaceVariant, Icons.undo);
    }
    switch (status) {
      case AccountsItemStatus.paid:
        return (l10n.statusPaid, cs.secondary, Icons.check_circle_outline);
      case AccountsItemStatus.overdue:
        return (l10n.statusOverdue, cs.error, Icons.error_outline);
      case AccountsItemStatus.graceWindow:
        return (l10n.statusGraceWindow, cs.tertiary, Icons.hourglass_bottom);
      case AccountsItemStatus.current:
        return (l10n.statusCurrent, cs.tertiary, Icons.hourglass_bottom);
      case AccountsItemStatus.upcoming:
        return (l10n.statusUpcoming, cs.primary, null);
      case AccountsItemStatus.reversed:
        return (l10n.statusReversed, cs.onSurfaceVariant, Icons.undo);
    }
  }
}

class _PayButton extends StatelessWidget {
  const _PayButton({required this.item});

  final AccountsItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PaymentBloc, PaymentState>(
      buildWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
      builder: (ctx, state) {
        final isLoading =
            state.actionStatus == PaymentActionStatus.loading;
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isLoading ? null : () => _confirmAndPay(ctx, l10n),
            icon: const Icon(Icons.payments_outlined, size: 18),
            label: Text(
              item.kind == AccountsItemKind.installmentPayment
                  ? l10n.accountsPayInstallment
                  : l10n.accountsPayGracePeriod,
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndPay(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          item.kind == AccountsItemKind.installmentPayment
              ? l10n.installmentsPayConfirmTitle
              : l10n.gracePeriodPayConfirmTitle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.kind == AccountsItemKind.installmentPayment
                  ? l10n.installmentsPayConfirmMessage
                  : l10n.gracePeriodPayConfirmMessage,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: const Size(0, 48)),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48)),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      l10n.commonConfirm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final bloc = context.read<PaymentBloc>();
    final now = DateTime.now();
    if (item.kind == AccountsItemKind.installmentPayment &&
        item.payment != null) {
      bloc.add(PayInstallmentPaymentEvent(payment: item.payment!, now: now));
    } else if (item.gracePeriod != null) {
      bloc.add(PayGracePeriodEvent(gracePeriod: item.gracePeriod!, now: now));
    }
  }
}
