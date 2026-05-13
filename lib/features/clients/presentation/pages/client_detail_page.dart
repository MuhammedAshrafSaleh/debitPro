// lib/features/clients/presentation/pages/client_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/presentation/widgets/destructive_bottom_sheet.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/quality_badge.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../../features/installments/presentation/cubit/client_installments_cubit.dart';
import '../../../../features/installments/presentation/cubit/client_installments_state.dart';
import '../../../../features/installments/presentation/widgets/installment_card.dart';
import '../../domain/entities/client_entity.dart';
import '../cubit/client_detail_cubit.dart';
import '../cubit/client_detail_state.dart';
import '../cubit/edit_client_cubit.dart';
import '../cubit/edit_client_state.dart';

class ClientDetailPage extends StatelessWidget {
  const ClientDetailPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<ClientDetailCubit>()..loadClient(clientId),
        ),
        BlocProvider(create: (_) => sl<EditClientCubit>()),
        BlocProvider(
          create: (_) =>
              sl<ClientInstallmentsCubit>()..watch(clientId),
        ),
      ],
      child: _ClientDetailView(clientId: clientId),
    );
  }
}

class _ClientDetailView extends StatelessWidget {
  const _ClientDetailView({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<EditClientCubit, EditClientState>(
      listener: (context, state) {
        if (state is EditClientFailure) {
          AppSnackbar.error(context, state.message);
        } else if (state is EditClientDeleted) {
          AppSnackbar.success(context, l10n.clientsDeleteSuccess);
          if (context.mounted) context.go('/clients');
        }
      },
      child: BlocBuilder<ClientDetailCubit, ClientDetailState>(
        builder: (context, state) {
          if (state is ClientDetailLoading || state is ClientDetailInitial) {
            return Scaffold(
              appBar: AppBar(),
              body: const AppLoadingIndicator(),
            );
          }
          if (state is ClientDetailFailure) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            );
          }
          if (state is ClientDetailLoaded) {
            return _ClientDetailScaffold(
              clientId: clientId,
              client: state.client,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ClientDetailScaffold extends StatefulWidget {
  const _ClientDetailScaffold({
    required this.clientId,
    required this.client,
  });

  final String clientId;
  final ClientEntity client;

  @override
  State<_ClientDetailScaffold> createState() => _ClientDetailScaffoldState();
}

class _ClientDetailScaffoldState extends State<_ClientDetailScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDestructiveBottomSheet(
      context,
      title: l10n.clientsDeleteConfirmTitle,
      message: l10n.clientsDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed && context.mounted) {
      context.read<EditClientCubit>().delete(widget.clientId);
    }
  }

  void _showAddRecordSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.clientsAddRecord,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(l10n.clientsAddInstallment),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/installments/add/${widget.clientId}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: Text(l10n.clientsAddGracePeriod),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.push('/grace-periods/add/${widget.clientId}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final client = widget.client;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final badge = StatusUtils.qualityBadge(client.paymentQualityScore);

    return Scaffold(
      appBar: AppBar(
        title: Text(client.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.commonEdit,
            onPressed: () => context.push('/clients/${client.id}/edit'),
          ),
          BlocBuilder<EditClientCubit, EditClientState>(
            builder: (context, state) => IconButton(
              icon: state is EditClientSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: l10n.commonDelete,
              onPressed: state is EditClientSaving
                  ? null
                  : () => _confirmDelete(context),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    AvatarWidget(name: client.fullName, id: client.id, radius: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.fullName, style: tt.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            client.phone,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          QualityBadgeWidget(badge: badge),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatColumn(
                      label: l10n.clientsTotalPaid,
                      value: CurrencyUtils.formatCurrency(client.totalPaid, locale),
                      color: cs.secondary,
                    ),
                    _StatColumn(
                      label: l10n.clientsTotalRemaining,
                      value: CurrencyUtils.formatCurrency(client.totalRemaining, locale),
                      color: cs.error,
                    ),
                    _StatColumn(
                      label: l10n.clientsActiveDebts,
                      value: '${client.activeDebtsCount}',
                      color: cs.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.clientsTabInstallments),
              Tab(text: l10n.clientsTabGracePeriods),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Installments tab — Phase 8
                BlocBuilder<ClientInstallmentsCubit, ClientInstallmentsState>(
                  builder: (context, instState) {
                    if (instState is ClientInstallmentsLoading) {
                      return const AppLoadingIndicator();
                    }
                    if (instState is ClientInstallmentsFailure) {
                      return Center(child: Text(instState.message));
                    }
                    if (instState is ClientInstallmentsLoaded) {
                      if (instState.installments.isEmpty) {
                        return EmptyState(
                          icon: Icons.calendar_month_outlined,
                          message: l10n.installmentsEmpty,
                          ctaLabel: l10n.clientsAddInstallment,
                          onCta: () => context
                              .push('/installments/add/${client.id}'),
                        );
                      }
                      return ListView.builder(
                        itemCount: instState.installments.length,
                        itemBuilder: (context, index) => InstallmentCard(
                          installment: instState.installments[index],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Grace periods tab — stub until Phase 9
                EmptyState(
                  icon: Icons.timer_outlined,
                  message: l10n.gracePeriodEmpty,
                  ctaLabel: l10n.clientsAddGracePeriod,
                  onCta: () => context.push('/grace-periods/add/${client.id}'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
