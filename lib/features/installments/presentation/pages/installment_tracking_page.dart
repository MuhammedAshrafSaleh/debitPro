// lib/features/installments/presentation/pages/installment_tracking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/confirm_dialog.dart';
import '../../../../core/presentation/widgets/status_badge.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../domain/entities/installment_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../cubit/installment_tracking_cubit.dart';
import '../cubit/installment_tracking_state.dart';

class InstallmentTrackingPage extends StatelessWidget {
  const InstallmentTrackingPage({super.key, required this.installmentId});

  final String installmentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<InstallmentTrackingCubit>()..load(installmentId),
      child: _InstallmentTrackingView(installmentId: installmentId),
    );
  }
}

class _InstallmentTrackingView extends StatelessWidget {
  const _InstallmentTrackingView({required this.installmentId});

  final String installmentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<InstallmentTrackingCubit, InstallmentTrackingState>(
      listener: (context, state) {
        if (state is InstallmentTrackingDeleted) {
          AppSnackbar.success(context, l10n.installmentsDeleteSuccess);
          context.pop();
        } else if (state is InstallmentTrackingPaymentSuccess) {
          AppSnackbar.success(context, l10n.installmentsPaySuccess);
        } else if (state is InstallmentTrackingReverseSuccess) {
          AppSnackbar.success(context, l10n.installmentsReverseSuccess);
        } else if (state is InstallmentTrackingFailure) {
          AppSnackbar.error(context, state.message);
        } else if (state is InstallmentTrackingPaymentError) {
          AppSnackbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is InstallmentTrackingInitial ||
            state is InstallmentTrackingLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppLoadingIndicator(),
          );
        }

        if (state is InstallmentTrackingFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(state.message)),
          );
        }

        final InstallmentEntity installment;
        final List<PaymentEntity> payments;
        final bool isCommissionLoading;

        if (state is InstallmentTrackingLoaded) {
          installment = state.installment;
          payments = state.payments;
          isCommissionLoading = false;
        } else if (state is InstallmentTrackingCommissionLoading) {
          installment = state.installment;
          payments = state.payments;
          isCommissionLoading = true;
        } else if (state is InstallmentTrackingPaymentError) {
          installment = state.installment;
          payments = state.payments;
          isCommissionLoading = false;
        } else if (state is InstallmentTrackingPaymentSuccess) {
          installment = state.installment;
          payments = state.payments;
          isCommissionLoading = false;
        } else if (state is InstallmentTrackingReverseSuccess) {
          installment = state.installment;
          payments = state.payments;
          isCommissionLoading = false;
        } else {
          return const SizedBox.shrink();
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _InstallmentHeader(
                installment: installment,
                installmentId: installmentId,
                isCommissionLoading: isCommissionLoading,
                onPayCommission: () => _confirmPayCommission(
                  context,
                  installmentId,
                  l10n,
                ),
                onEdit: () => _onEditPressed(context, installmentId),
                onDelete: () => _confirmDelete(
                  context,
                  installmentId,
                  l10n,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    l10n.installmentsPaymentSchedule,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final payment = payments[index];
                    final now = DateTime.now();
                    final displayStatus = switch (payment.status) {
                      PaymentStatus.paid => PaymentStatus.paid,
                      PaymentStatus.reversed => PaymentStatus.reversed,
                      _ => StatusUtils.computeInstallmentPaymentStatus(
                          payment.dueDate, now),
                    };
                    return _DismissiblePaymentRow(
                      payment: payment,
                      displayStatus: displayStatus,
                    );
                  },
                  childCount: payments.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onEditPressed(
    BuildContext context,
    String installmentId,
  ) async {
    await context.push('/installments/$installmentId/edit');
    if (context.mounted) {
      context.read<InstallmentTrackingCubit>().load(installmentId);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String installmentId,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.installmentsDeleteConfirmTitle,
      message: l10n.installmentsDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
    );
    if (confirmed && context.mounted) {
      context.read<InstallmentTrackingCubit>().delete(installmentId);
    }
  }

  Future<void> _confirmPayCommission(
    BuildContext context,
    String installmentId,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: l10n.installmentsCommissionConfirmTitle,
      message: l10n.installmentsCommissionConfirmMessage,
      confirmLabel: l10n.commonConfirm,
    );
    if (confirmed && context.mounted) {
      context
          .read<InstallmentTrackingCubit>()
          .payOfficeCommission(installmentId);
      AppSnackbar.success(context, l10n.installmentsCommissionPaidSuccess);
    }
  }
}

class _InstallmentHeader extends StatelessWidget {
  const _InstallmentHeader({
    required this.installment,
    required this.installmentId,
    required this.isCommissionLoading,
    required this.onPayCommission,
    required this.onEdit,
    required this.onDelete,
  });

  final InstallmentEntity installment;
  final String installmentId;
  final bool isCommissionLoading;
  final VoidCallback onPayCommission;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = installment.totalPaymentsCount > 0
        ? installment.paidPaymentsCount / installment.totalPaymentsCount
        : 0.0;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      actions: [
        if (installment.paidPaymentsCount == 0)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.commonDelete,
            onPressed: onDelete,
          ),
        if (!installment.editLocked)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.commonEdit,
            onPressed: onEdit,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                cs.primary,
                cs.primary.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 56, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          color: cs.onPrimary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          installment.itemName,
                          style: tt.titleLarge
                              ?.copyWith(color: cs.onPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _HeaderStat(
                        label: l10n.installmentsPaidSlashTotal,
                        value:
                            '${installment.paidPaymentsCount}/${installment.totalPaymentsCount}',
                        onPrimary: cs.onPrimary,
                      ),
                      const SizedBox(width: 20),
                      _HeaderStat(
                        label: l10n.installmentsDurationMonths,
                        value: '${installment.durationMonths}m',
                        onPrimary: cs.onPrimary,
                      ),
                      const SizedBox(width: 20),
                      _HeaderStat(
                        label: l10n.installmentsMonthlyAmount,
                        value: CurrencyUtils.formatCurrency(
                            installment.monthlyAmount, locale),
                        onPrimary: cs.onPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HeaderStat(
                          label: l10n.installmentsTotalPaid,
                          value: CurrencyUtils.formatCurrency(
                              installment.totalPaidAmount, locale),
                          onPrimary: cs.onPrimary,
                        ),
                      ),
                      Expanded(
                        child: _HeaderStat(
                          label: l10n.installmentsTotalRemaining,
                          value: CurrencyUtils.formatCurrency(
                              installment.totalDebt -
                                  installment.totalPaidAmount,
                              locale),
                          onPrimary: cs.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: cs.onPrimary.withValues(alpha: 0.3),
                      color: cs.onPrimary,
                    ),
                  ),
                  if (installment.officeCommissionAmount > 0) ...[
                    const SizedBox(height: 8),
                    if (installment.officeCommissionPaid)
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16,
                              color: cs.onPrimary.withValues(alpha: 0.9)),
                          const SizedBox(width: 6),
                          Text(
                            l10n.installmentsCommissionPaidLabel,
                            style: TextStyle(
                              color: cs.onPrimary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      FilledButton.tonal(
                        onPressed:
                            isCommissionLoading ? null : onPayCommission,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              cs.onPrimary.withValues(alpha: 0.15),
                          foregroundColor: cs.onPrimary,
                          minimumSize: const Size(double.infinity, 36),
                        ),
                        child: isCommissionLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Text(l10n.installmentsPayCommission),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.onPrimary,
  });

  final String label;
  final String value;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: tt.titleSmall
              ?.copyWith(color: onPrimary, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: tt.labelSmall
              ?.copyWith(color: onPrimary.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}

class _DismissiblePaymentRow extends StatelessWidget {
  const _DismissiblePaymentRow({
    required this.payment,
    required this.displayStatus,
  });

  final PaymentEntity payment;
  final PaymentStatus displayStatus;

  DismissDirection _direction() {
    if (displayStatus == PaymentStatus.paid) {
      return DismissDirection.startToEnd;
    }
    return DismissDirection.endToStart;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final canPay = displayStatus != PaymentStatus.paid;
    final canReverse = displayStatus == PaymentStatus.paid;

    return Dismissible(
      key: ValueKey(payment.id),
      direction: _direction(),
      // background: startToEnd (physical LEFT swipe in RTL) → reverse
      background: canReverse
          ? _SwipeBackground(
              color: cs.error,
              icon: Icons.undo_outlined,
              label: l10n.installmentsReverseAction,
              alignment: AlignmentDirectional.centerStart,
            )
          : const SizedBox.shrink(),
      // secondaryBackground: endToStart (physical RIGHT swipe in RTL) → pay
      secondaryBackground: canPay
          ? _SwipeBackground(
              color: Colors.green.shade700,
              icon: Icons.check_circle_outline,
              label: l10n.installmentsPayAction,
              alignment: AlignmentDirectional.centerEnd,
            )
          : const SizedBox.shrink(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart && canPay) {
          final confirmed = await showConfirmDialog(
            context,
            title: l10n.installmentsPayConfirmTitle,
            message: l10n.installmentsPayConfirmMessage,
            confirmLabel: l10n.installmentsPayAction,
          );
          if (confirmed && context.mounted) {
            context.read<InstallmentTrackingCubit>().payPayment(payment);
          }
        } else if (direction == DismissDirection.startToEnd && canReverse) {
          final confirmed = await showConfirmDialog(
            context,
            title: l10n.installmentsReverseConfirmTitle,
            message: l10n.installmentsReverseConfirmMessage,
            confirmLabel: l10n.installmentsReverseAction,
          );
          if (confirmed && context.mounted) {
            context.read<InstallmentTrackingCubit>().reversePayment(payment);
          }
        }
        return false;
      },
      child: _PaymentRow(payment: payment, displayStatus: displayStatus),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final String label;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.payment,
    required this.displayStatus,
  });

  final PaymentEntity payment;
  final PaymentStatus displayStatus;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final monthLabel = _localizedMonthName(locale, payment.dueDate.month);
    final label = locale == 'ar'
        ? 'دفعة $monthLabel'
        : '$monthLabel Payment';
    final dateLabel =
        '${payment.dueDate.day.toString().padLeft(2, '0')}/'
        '${payment.dueDate.month.toString().padLeft(2, '0')}/'
        '${payment.dueDate.year}';

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        contentPadding:
            const EdgeInsetsDirectional.only(start: 16, end: 16),
        leading: _StatusIcon(status: displayStatus),
        title: Text(label, style: tt.bodyMedium),
        subtitle: Text(dateLabel,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyUtils.formatCurrency(payment.amount, locale),
              style: tt.titleSmall,
            ),
            const SizedBox(width: 8),
            StatusBadge(status: displayStatus.toLabel()),
          ],
        ),
      ),
    );
  }

  static String _localizedMonthName(String locale, int month) {
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const enMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return (locale == 'ar' ? arMonths : enMonths)[month - 1];
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (icon, color) = switch (status) {
      PaymentStatus.paid => (Icons.check_circle_outline, cs.secondary),
      PaymentStatus.overdue => (Icons.warning_amber_outlined, cs.error),
      PaymentStatus.current =>
        (Icons.hourglass_top_outlined, cs.tertiary),
      PaymentStatus.reversed =>
        (Icons.undo_outlined, cs.onSurfaceVariant),
      PaymentStatus.upcoming =>
        (Icons.radio_button_unchecked, cs.onSurfaceVariant),
    };
    return Icon(icon, color: color);
  }
}
