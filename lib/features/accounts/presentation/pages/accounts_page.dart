// lib/features/accounts/presentation/pages/accounts_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../payments/presentation/bloc/payment_bloc.dart';
import '../../../payments/presentation/bloc/payment_state.dart';
import '../../domain/entities/accounts_filter.dart';
import '../../domain/entities/accounts_item.dart';
import '../../domain/entities/pdf_transaction_row.dart';
import '../../domain/usecases/get_transactions_pdf_use_case.dart';
import '../cubit/accounts_cubit.dart';
import '../cubit/accounts_state.dart';
import '../services/accounts_pdf_generator.dart';
import '../widgets/accounts_item_card.dart';
import '../widgets/overdue_client_tile.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountsCubit>(
          create: (_) => sl<AccountsCubit>()..load(),
        ),
        BlocProvider<PaymentBloc>(create: (_) => sl<PaymentBloc>()),
      ],
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatefulWidget {
  const _AccountsView();

  @override
  State<_AccountsView> createState() => _AccountsViewState();
}

class _AccountsViewState extends State<_AccountsView> {
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountsTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.tune),
          tooltip: l10n.accountsFilters,
          onPressed: () => _showFilterSheet(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_searchOpen) {
                  _searchController.clear();
                  context.read<AccountsCubit>().setSearchQuery('');
                }
                _searchOpen = !_searchOpen;
              });
            },
          ),
        ],
      ),
      body: BlocListener<PaymentBloc, PaymentState>(
        listenWhen: (prev, curr) =>
            prev.actionStatus != curr.actionStatus &&
            curr.actionStatus != PaymentActionStatus.idle &&
            curr.actionStatus != PaymentActionStatus.loading,
        listener: (ctx, payState) {
          if (payState.actionStatus == PaymentActionStatus.success) {
            AppSnackbar.success(
              ctx,
              payState.actionMessage ?? l10n.commonSuccess,
            );
            ctx.read<AccountsCubit>().refresh();
          } else if (payState.actionStatus == PaymentActionStatus.failure) {
            AppSnackbar.error(
              ctx,
              payState.actionMessage ?? l10n.commonError,
            );
          }
        },
        child: BlocBuilder<AccountsCubit, AccountsState>(
          builder: (ctx, state) {
            return RefreshIndicator(
              onRefresh: () => ctx.read<AccountsCubit>().refresh(),
              child: CustomScrollView(
                slivers: [
                  if (_searchOpen)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: l10n.accountsSearchHint,
                            prefixIcon: const Icon(Icons.search),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (v) =>
                              ctx.read<AccountsCubit>().setSearchQuery(v),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: _TypeTabsBar(filter: state.filter),
                  ),
                  SliverToBoxAdapter(
                    child: _DateRangeCard(filter: state.filter),
                  ),
                  SliverToBoxAdapter(
                    child: _ClientTypeChips(filter: state.filter),
                  ),
                  if (state.data != null) ...[
                    SliverToBoxAdapter(
                      child: _SummaryChipsRow(summary: state.data!.summary),
                    ),
                    if (state.filter.hasDateRange)
                      SliverToBoxAdapter(
                        child: _SummaryTotalsHeader(summary: state.data!.summary),
                      ),
                  ],
                  if (state.status == AccountsStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppLoadingIndicator(),
                    )
                  else if (state.status == AccountsStatus.failure)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.error_outline,
                        message: state.failureMessage ?? l10n.commonError,
                        ctaLabel: l10n.commonRetry,
                        onCta: () => ctx.read<AccountsCubit>().refresh(),
                      ),
                    )
                  else if (state.data == null || state.data!.items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: l10n.accountsEmpty,
                      ),
                    )
                  else ...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => AccountsItemCard(item: state.data!.items[i]),
                        childCount: state.data!.items.length,
                      ),
                    ),
                    if (state.data!.overdueClients.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _OverdueHeader(
                          count: state.data!.overdueClients.length,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => OverdueClientTile(
                            info: state.data!.overdueClients[i],
                          ),
                          childCount: state.data!.overdueClients.length,
                        ),
                      ),
                    ],
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final cubit = context.read<AccountsCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: const _FilterSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top type tabs (الكل / الأقساط / المهل)
// ─────────────────────────────────────────────────────────────────────────────
class _TypeTabsBar extends StatelessWidget {
  const _TypeTabsBar({required this.filter});

  final AccountsFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _TabSegment(
              label: l10n.accountsTabAll,
              selected: filter.typeTab == AccountsTypeTab.all,
              onTap: () => context
                  .read<AccountsCubit>()
                  .setTypeTab(AccountsTypeTab.all),
            ),
            _TabSegment(
              label: l10n.accountsTabInstallments,
              selected: filter.typeTab == AccountsTypeTab.installments,
              onTap: () => context
                  .read<AccountsCubit>()
                  .setTypeTab(AccountsTypeTab.installments),
            ),
            _TabSegment(
              label: l10n.accountsTabGracePeriods,
              selected: filter.typeTab == AccountsTypeTab.gracePeriods,
              onTap: () => context
                  .read<AccountsCubit>()
                  .setTypeTab(AccountsTypeTab.gracePeriods),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: tt.labelLarge?.copyWith(
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date range pickers (from month / to month)
// ─────────────────────────────────────────────────────────────────────────────
class _DateRangeCard extends StatelessWidget {
  const _DateRangeCard({required this.filter});

  final AccountsFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            _MonthPickerRow(
              label: l10n.accountsFromMonth,
              value: filter.fromMonth,
              onPick: (d) => context.read<AccountsCubit>().setFromMonth(d),
            ),
            const SizedBox(height: 10),
            _MonthPickerRow(
              label: l10n.accountsToMonth,
              value: filter.toMonth,
              onPick: (d) => context.read<AccountsCubit>().setToMonth(d),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickerRow extends StatelessWidget {
  const _MonthPickerRow({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final hasValue = value != null;
    final display = hasValue
        ? _formatMonth(locale, value!)
        : l10n.accountsSelectMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickMonth(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    display,
                    style: tt.bodyMedium?.copyWith(
                      color: hasValue ? cs.onSurface : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (hasValue)
                  InkWell(
                    onTap: () => onPick(null),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close,
                          size: 18, color: cs.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final initial = value ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
      helpText: AppLocalizations.of(context).accountsSelectMonth,
    );
    if (picked != null) {
      onPick(DateTime(picked.year, picked.month, 1));
    }
  }

  static String _formatMonth(String locale, DateTime date) {
    const enMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final months = locale == 'ar' ? arMonths : enMonths;
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client type chips (all / office / private)
// ─────────────────────────────────────────────────────────────────────────────
class _ClientTypeChips extends StatelessWidget {
  const _ClientTypeChips({required this.filter});

  final AccountsFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Row(
        children: [
          _typeChip(
              context, l10n.clientsFilterAll, AccountsClientType.all),
          const SizedBox(width: 8),
          _typeChip(context, l10n.clientsClientTypeOffice,
              AccountsClientType.office),
          const SizedBox(width: 8),
          _typeChip(context, l10n.clientsClientTypePrivate,
              AccountsClientType.private),
        ],
      ),
    );
  }

  Widget _typeChip(
    BuildContext context,
    String label,
    AccountsClientType type,
  ) {
    final selected = filter.clientType == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) =>
          context.read<AccountsCubit>().setClientType(type),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary chips (overdue / current / paid)
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryChipsRow extends StatelessWidget {
  const _SummaryChipsRow({required this.summary});

  final AccountsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryChip(
              icon: Icons.check_circle_outline,
              color: cs.secondary,
              label: l10n.accountsSummaryPaid(summary.paidCount),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryChip(
              icon: Icons.hourglass_bottom,
              color: cs.tertiary,
              label: l10n.accountsSummaryCurrent(summary.currentCount),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryChip(
              icon: Icons.error_outline,
              color: cs.error,
              label: l10n.accountsSummaryOverdue(summary.overdueCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary totals header (collected / profits / ops) — shown only with date range
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryTotalsHeader extends StatelessWidget {
  const _SummaryTotalsHeader({required this.summary});

  final AccountsSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _Total(
              label: l10n.accountsTotalCollected,
              value: CurrencyUtils.formatCurrency(summary.totalCollected, locale),
              color: cs.secondary,
              tt: tt,
            ),
            const SizedBox(width: 10),
            _Total(
              label: l10n.accountsTotalProfits,
              value: CurrencyUtils.formatCurrency(summary.totalProfits, locale),
              color: cs.primary,
              tt: tt,
            ),
            const SizedBox(width: 10),
            _Total(
              label: l10n.accountsTotalOperations,
              value: summary.operationsCount.toString(),
              color: cs.tertiary,
              tt: tt,
            ),
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.value,
    required this.color,
    required this.tt,
  });

  final String label;
  final String value;
  final Color color;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: tt.labelSmall?.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value,
              style: tt.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overdue clients section header
// ─────────────────────────────────────────────────────────────────────────────
class _OverdueHeader extends StatelessWidget {
  const _OverdueHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(Icons.report_gmailerrorred_outlined, size: 18, color: cs.error),
          const SizedBox(width: 8),
          Text(l10n.accountsOverdueClientsTitle,
              style: tt.titleSmall?.copyWith(color: cs.error)),
          const SizedBox(width: 6),
          Text('($count)',
              style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter bottom sheet (alternative entry from filter icon)
// ─────────────────────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  bool _generatingPdf = false;

  Future<void> _generateAndSharePdf(
    BuildContext ctx,
    AccountsState state,
  ) async {
    if (state.data == null) return;
    // Capture context-dependent values before any async gap
    final locale = Localizations.localeOf(ctx).languageCode;
    final l10n = AppLocalizations.of(ctx);
    setState(() => _generatingPdf = true);
    try {
      // Fetch actual transactions for Table 1
      final txResult = await sl<GetTransactionsPdfUseCase>()(state.filter);
      final txRows = txResult.fold(
        (_) => <PdfTransactionRow>[],
        (rows) => rows,
      );

      final fontData = await rootBundle.load('assets/fonts/Cairo/Cairo-variable.ttf');
      final cairoFont = pw.Font.ttf(fontData);
      final doc = AccountsPdfGenerator(
        txRows: txRows,
        overdueClients: state.data!.overdueClients,
        summary: state.data!.summary,
        filter: state.filter,
        locale: locale,
        cairoFont: cairoFont,
        l10n: l10n,
      ).generate();
      final bytes = await doc.save();
      await Printing.sharePdf(bytes: bytes, filename: 'accounts_report.pdf');
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<AccountsCubit, AccountsState>(
      builder: (ctx, state) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: 16,
            end: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom +
                MediaQuery.viewPaddingOf(ctx).bottom +
                16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(l10n.accountsFilters, style: tt.titleMedium),
              const SizedBox(height: 16),
              _TypeTabsBar(filter: state.filter),
              _DateRangeCard(filter: state.filter),
              _ClientTypeChips(filter: state.filter),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: _generatingPdf
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(l10n.accountsPrintReport),
                  onPressed: (state.data == null || _generatingPdf)
                      ? null
                      : () => _generateAndSharePdf(ctx, state),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.commonConfirm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
