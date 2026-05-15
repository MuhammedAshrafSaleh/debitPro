// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/dashboard_data.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/collection_hero_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/recent_transaction_tile.dart';
import '../widgets/stat_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..load(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (ctx, state) {
            if (state.status == DashboardStatus.loading ||
                state.status == DashboardStatus.initial) {
              return const AppLoadingIndicator();
            }
            if (state.status == DashboardStatus.failure) {
              return EmptyState(
                icon: Icons.error_outline,
                message: state.failureMessage ?? l10n.commonError,
                ctaLabel: l10n.commonRetry,
                onCta: () => ctx.read<DashboardCubit>().refresh(),
              );
            }
            final data = state.data;
            if (data == null) {
              return EmptyState(
                icon: Icons.dashboard_outlined,
                message: l10n.commonError,
                ctaLabel: l10n.commonRetry,
                onCta: () => ctx.read<DashboardCubit>().refresh(),
              );
            }
            return RefreshIndicator(
              onRefresh: () => ctx.read<DashboardCubit>().refresh(),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: DashboardHeader()),
                  SliverToBoxAdapter(child: CollectionHeroCard(data: data)),
                  SliverToBoxAdapter(child: _StatsGrid(data: data)),
                  SliverToBoxAdapter(
                    child: _RecentHeader(l10n: l10n),
                  ),
                  if (data.recentTransactions.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          icon: Icons.receipt_long_outlined,
                          message: l10n.dashboardRecentTransactionsEmpty,
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final tx = data.recentTransactions[i];
                          return RecentTransactionTile(
                            transaction: tx,
                            clientName: data.clientNamesById[tx.clientId] ?? '',
                          );
                        },
                        childCount: data.recentTransactions.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.trending_up,
                  iconColor: Colors.green,
                  label: l10n.dashboardTotalProfits,
                  value: CurrencyUtils.formatCurrency(
                      data.totalProfits, locale),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.account_balance,
                  iconColor: cs.primary,
                  label: l10n.dashboardTotalCapital,
                  value: CurrencyUtils.formatCurrency(
                      data.totalCapital, locale),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.percent,
                  iconColor: cs.tertiary,
                  label: l10n.dashboardOfficeCommission,
                  value: CurrencyUtils.formatCurrency(
                      data.totalOfficeCommission, locale),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  icon: Icons.people_outline,
                  iconColor: Colors.blueAccent,
                  label: l10n.dashboardTotalClients,
                  value: data.totalClients.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  const _RecentHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          l10n.dashboardRecentTransactionsTitle,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
