// lib/features/grace_periods/presentation/widgets/grace_period_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_event.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../domain/entities/grace_period_entity.dart';
import '../cubit/client_grace_periods_cubit.dart';
import '../cubit/client_grace_periods_state.dart';

class GracePeriodCard extends StatelessWidget {
  const GracePeriodCard({super.key, required this.gracePeriod});

  final GracePeriodEntity gracePeriod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final statusColor = _statusColor(gracePeriod.status, cs);
    final statusLabel = _statusLabel(gracePeriod.status, l10n);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      gracePeriod.name,
                      style: tt.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: tt.labelSmall?.copyWith(color: statusColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyUtils.formatCurrency(gracePeriod.capital, locale),
                    style: tt.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatDate(locale, gracePeriod.dueDate),
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              if (gracePeriod.officeCommissionAmount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      gracePeriod.officeCommissionPaid
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: 14,
                      color: gracePeriod.officeCommissionPaid
                          ? cs.secondary
                          : cs.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gracePeriod.officeCommissionPaid
                          ? l10n.gracePeriodCommissionPaidLabel
                          : l10n.gracePeriodCommissionPending,
                      style: tt.labelSmall?.copyWith(
                        color: gracePeriod.officeCommissionPaid
                            ? cs.secondary
                            : cs.tertiary,
                      ),
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

  void _showDetailSheet(BuildContext context) {
    final cubit = context.read<ClientGracePeriodsCubit>();
    final paymentBloc = context.read<PaymentBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: cubit),
          BlocProvider.value(value: paymentBloc),
        ],
        child: _GracePeriodDetailSheet(
          gracePeriod: gracePeriod,
          parentContext: context,
        ),
      ),
    );
  }

  Color _statusColor(GracePeriodStatus status, ColorScheme cs) {
    switch (status) {
      case GracePeriodStatus.paid:
        return cs.secondary;
      case GracePeriodStatus.upcoming:
        return cs.primary;
      case GracePeriodStatus.graceWindow:
        return cs.tertiary;
      case GracePeriodStatus.overdue:
        return cs.error;
    }
  }

  String _statusLabel(GracePeriodStatus status, AppLocalizations l10n) {
    switch (status) {
      case GracePeriodStatus.paid:
        return l10n.statusPaid;
      case GracePeriodStatus.upcoming:
        return l10n.statusUpcoming;
      case GracePeriodStatus.graceWindow:
        return l10n.statusGraceWindow;
      case GracePeriodStatus.overdue:
        return l10n.statusOverdue;
    }
  }

  static String _formatDate(String locale, DateTime date) {
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const enMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month =
        (locale == 'ar' ? arMonths : enMonths)[date.month - 1];
    return '${date.day.toString().padLeft(2, '0')} $month ${date.year}';
  }
}

// ── Detail bottom sheet ──────────────────────────────────────────────────────

class _GracePeriodDetailSheet extends StatelessWidget {
  const _GracePeriodDetailSheet({
    required this.gracePeriod,
    required this.parentContext,
  });

  final GracePeriodEntity gracePeriod;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<ClientGracePeriodsCubit, ClientGracePeriodsState>(
          listenWhen: (prev, curr) =>
              curr is ClientGracePeriodsLoaded &&
              curr.actionStatus != GracePeriodActionStatus.idle,
          listener: (ctx, state) {
            if (state is! ClientGracePeriodsLoaded) return;
            if (state.actionStatus == GracePeriodActionStatus.success) {
              AppSnackbar.success(ctx, l10n.gracePeriodCommissionPaidSuccess);
              Navigator.of(ctx).pop();
            } else if (state.actionStatus == GracePeriodActionStatus.failure) {
              AppSnackbar.error(
                ctx,
                state.actionMessage ?? l10n.commonError,
              );
            }
          },
        ),
        BlocListener<PaymentBloc, PaymentState>(
          listenWhen: (prev, curr) =>
              prev.actionStatus != curr.actionStatus &&
              curr.actionStatus != PaymentActionStatus.idle,
          listener: (ctx, state) {
            if (state.actionStatus == PaymentActionStatus.success) {
              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
            }
          },
        ),
      ],
      child: BlocBuilder<ClientGracePeriodsCubit, ClientGracePeriodsState>(
        buildWhen: (prev, curr) =>
            curr is ClientGracePeriodsLoaded &&
            (prev is! ClientGracePeriodsLoaded ||
                prev.actionStatus != curr.actionStatus ||
                prev.actionType != curr.actionType),
        builder: (ctx, state) {
          final loaded =
              state is ClientGracePeriodsLoaded ? state : null;
          final isCommissionLoading =
              loaded?.actionStatus == GracePeriodActionStatus.loading &&
                  loaded?.actionType ==
                      GracePeriodActionType.payOfficeCommission;

          return BlocBuilder<PaymentBloc, PaymentState>(
            buildWhen: (prev, curr) =>
                prev.actionStatus != curr.actionStatus,
            builder: (ctx, payState) {
              final isPayGpLoading =
                  payState.actionStatus == PaymentActionStatus.loading &&
                      payState.actionKind == PaymentActionKind.pay;
              final isLoading = isPayGpLoading || isCommissionLoading;

              return Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 16,
                  end: 16,
                  top: 12,
                  bottom: MediaQuery.viewInsetsOf(ctx).bottom +
                      MediaQuery.viewPaddingOf(ctx).bottom +
                      24,
                ),
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:
                          cs.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title row with optional edit button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.gracePeriodDetailsTitle,
                        style: tt.titleMedium,
                      ),
                    ),
                    if (!gracePeriod.editLocked)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: l10n.commonEdit,
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          if (parentContext.mounted) {
                            parentContext.push(
                              '/grace-periods/${gracePeriod.id}/edit',
                            );
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Name + status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        gracePeriod.name,
                        style: tt.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusBadge(status: gracePeriod.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Capital
                _InfoRow(
                  icon: Icons.attach_money_outlined,
                  label: l10n.gracePeriodCapital,
                  value: CurrencyUtils.formatCurrency(
                      gracePeriod.capital, locale),
                  valueStyle: tt.bodyLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Due date
                _InfoRow(
                  icon: Icons.event_outlined,
                  label: l10n.gracePeriodDueDate,
                  value: GracePeriodCard._formatDate(
                      locale, gracePeriod.dueDate),
                ),
                const SizedBox(height: 10),

                // Grace period end date
                _InfoRow(
                  icon: Icons.hourglass_bottom_outlined,
                  label: l10n.gracePeriodGraceUntil,
                  value: GracePeriodCard._formatDate(
                      locale, gracePeriod.gracePeriodEndDate),
                ),

                // Notes
                if (gracePeriod.notes != null &&
                    gracePeriod.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: l10n.gracePeriodNotes,
                    value: gracePeriod.notes!,
                  ),
                ],

                // Office commission section
                if (gracePeriod.officeCommissionAmount > 0) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.gracePeriodOfficeCommission,
                        style: tt.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      Text(
                        CurrencyUtils.formatCurrency(
                            gracePeriod.officeCommissionAmount, locale),
                        style: tt.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        gracePeriod.officeCommissionPaid
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        size: 16,
                        color: gracePeriod.officeCommissionPaid
                            ? cs.secondary
                            : cs.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        gracePeriod.officeCommissionPaid
                            ? l10n.gracePeriodCommissionPaidLabel
                            : l10n.gracePeriodCommissionPending,
                        style: tt.labelMedium?.copyWith(
                          color: gracePeriod.officeCommissionPaid
                              ? cs.secondary
                              : cs.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Pay Grace Period button
                if (gracePeriod.status != GracePeriodStatus.paid) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: isPayGpLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.payments_outlined),
                      label: Text(l10n.gracePeriodPayTitle),
                      onPressed: isLoading
                          ? null
                          : () => _confirmAction(
                                ctx,
                                l10n,
                                isCommission: false,
                              ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Pay Office Commission button
                if (gracePeriod.officeCommissionAmount > 0 &&
                    !gracePeriod.officeCommissionPaid) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: isCommissionLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.business_center_outlined),
                      label: Text(l10n.gracePeriodPayCommission),
                      onPressed: isLoading
                          ? null
                          : () => _confirmAction(
                                ctx,
                                l10n,
                                isCommission: true,
                              ),
                    ),
                  ),
                ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    AppLocalizations l10n, {
    required bool isCommission,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(isCommission
            ? l10n.gracePeriodCommissionConfirmTitle
            : l10n.gracePeriodPayConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(isCommission
                ? l10n.gracePeriodCommissionConfirmMessage
                : l10n.gracePeriodPayConfirmMessage),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        minimumSize: const Size(0, 48)),
                    onPressed: () => Navigator.of(dCtx).pop(false),
                    child: Text(l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48)),
                    onPressed: () => Navigator.of(dCtx).pop(true),
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
    if (confirmed == true && context.mounted) {
      if (isCommission) {
        context
            .read<ClientGracePeriodsCubit>()
            .payOfficeCommission(gracePeriod.id);
      } else {
        context.read<PaymentBloc>().add(
              PayGracePeriodEvent(
                gracePeriod: gracePeriod,
                now: DateTime.now(),
              ),
            );
      }
    }
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final GracePeriodStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final color = _color(cs);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(l10n),
        style: tt.labelSmall?.copyWith(color: color),
      ),
    );
  }

  Color _color(ColorScheme cs) {
    switch (status) {
      case GracePeriodStatus.paid:
        return cs.secondary;
      case GracePeriodStatus.upcoming:
        return cs.primary;
      case GracePeriodStatus.graceWindow:
        return cs.tertiary;
      case GracePeriodStatus.overdue:
        return cs.error;
    }
  }

  String _label(AppLocalizations l10n) {
    switch (status) {
      case GracePeriodStatus.paid:
        return l10n.statusPaid;
      case GracePeriodStatus.upcoming:
        return l10n.statusUpcoming;
      case GracePeriodStatus.graceWindow:
        return l10n.statusGraceWindow;
      case GracePeriodStatus.overdue:
        return l10n.statusOverdue;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: valueStyle ?? tt.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
