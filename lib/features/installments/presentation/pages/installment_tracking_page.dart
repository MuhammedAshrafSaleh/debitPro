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
        if (state is InstallmentTrackingLoaded) {
          // Refresh completed — no-op
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
                    return _PaymentRow(payment: payment);
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
  });

  final InstallmentEntity installment;
  final String installmentId;
  final bool isCommissionLoading;
  final VoidCallback onPayCommission;

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
        if (!installment.editLocked)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.commonEdit,
            onPressed: () =>
                context.push('/installments/$installmentId/edit'),
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
                  if (!installment.officeCommissionPaid &&
                      installment.officeCommissionAmount > 0) ...[
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: isCommissionLoading ? null : onPayCommission,
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

/// 8.10 — Localized month names using intl
class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final PaymentEntity payment;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();

    // Re-compute live status for display (stored status may be stale for upcoming/current)
    final displayStatus = switch (payment.status) {
      PaymentStatus.paid => PaymentStatus.paid,
      PaymentStatus.reversed => PaymentStatus.reversed,
      _ => StatusUtils.computeInstallmentPaymentStatus(payment.dueDate, now),
    };

    final monthLabel = _localizedMonthName(locale, payment.dueDate.month);
    final label = locale == 'ar'
        ? 'دفعة $monthLabel'
        : '$monthLabel Payment';
    final dateLabel =
        '${payment.dueDate.day.toString().padLeft(2, '0')}/'
        '${payment.dueDate.month.toString().padLeft(2, '0')}/'
        '${payment.dueDate.year}';

    return ListTile(
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
