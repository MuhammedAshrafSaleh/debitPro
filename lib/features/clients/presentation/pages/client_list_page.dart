// lib/features/clients/presentation/pages/client_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/presentation/widgets/empty_state.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/client_entity.dart';
import '../cubit/client_list_cubit.dart';
import '../cubit/client_list_state.dart';

class ClientListPage extends StatelessWidget {
  const ClientListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ClientListCubit>()..loadClients(),
      child: const _ClientListView(),
    );
  }
}

class _ClientListView extends StatefulWidget {
  const _ClientListView();

  @override
  State<_ClientListView> createState() => _ClientListViewState();
}

class _ClientListViewState extends State<_ClientListView> {
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch(BuildContext context) {
    setState(() => _searching = !_searching);
    if (!_searching) {
      _searchController.clear();
      context.read<ClientListCubit>().search('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
              child: _searching
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: l10n.clientsSearchHint,
                              prefixIcon: const Icon(Icons.search),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (q) =>
                                context.read<ClientListCubit>().search(q),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _toggleSearch(context),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.clientsTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          tooltip: l10n.clientsSearchHint,
                          onPressed: () => _toggleSearch(context),
                        ),
                      ],
                    ),
            ),

            // Filter tabs
            BlocBuilder<ClientListCubit, ClientListState>(
              buildWhen: (p, c) =>
                  c is ClientListLoaded && p is ClientListLoaded
                  ? p.filter != c.filter
                  : true,
              builder: (context, state) {
                final filter = state is ClientListLoaded
                    ? state.filter
                    : ClientFilter.all;
                return _FilterTabs(
                  selected: filter,
                  onTap: (f) => context.read<ClientListCubit>().changeFilter(f),
                );
              },
            ),

            // List
            Expanded(
              child: BlocBuilder<ClientListCubit, ClientListState>(
                builder: (context, state) {
                  if (state is ClientListLoading ||
                      state is ClientListInitial) {
                    return const AppLoadingIndicator();
                  }
                  if (state is ClientListFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: cs.error),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (state is ClientListLoaded) {
                    if (state.clients.isEmpty) {
                      final isFiltered =
                          state.filter != ClientFilter.all ||
                          state.searchQuery.isNotEmpty;
                      return EmptyState(
                        icon: Icons.people_outline,
                        message: isFiltered
                            ? l10n.clientsFilterEmpty
                            : l10n.clientsEmpty,
                        ctaLabel: isFiltered ? null : l10n.clientsAddButton,
                        onCta: isFiltered
                            ? null
                            : () => context.push('/clients/add'),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: state.clients.length,
                      itemBuilder: (ctx, i) =>
                          _ClientCard(client: state.clients[i]),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation:
          Directionality.of(context) == TextDirection.rtl
              ? FloatingActionButtonLocation.startFloat
              : FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/clients/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onTap});

  final ClientFilter selected;
  final void Function(ClientFilter) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = [
      (ClientFilter.all, l10n.clientsFilterAll),
      (ClientFilter.electronic, l10n.clientsFilterElectronic),
      (ClientFilter.paper, l10n.clientsFilterPaper),
      (ClientFilter.office, l10n.clientsFilterOffice),
      (ClientFilter.private, l10n.clientsFilterPrivate),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Row(
        children: filters.map((entry) {
          final (filter, label) = entry;
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onTap(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final ClientEntity client;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/clients/${client.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AvatarWidget(name: client.fullName, id: client.id),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.fullName,
                            style: tt.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _DocTypeChip(
                          documentationType: client.documentationType,
                        ),
                        const SizedBox(width: 4),
                        _TypeChip(clientType: client.clientType),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.phone,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (client.activeDebtsCount > 0 ||
                        client.totalRemaining > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 14,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CurrencyUtils.formatCurrency(
                              client.totalRemaining,
                              locale,
                            ),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (client.activeDebtsCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${client.activeDebtsCount}',
                                style: tt.labelSmall?.copyWith(
                                  color: cs.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocTypeChip extends StatelessWidget {
  const _DocTypeChip({required this.documentationType});

  final DocumentationType documentationType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isElectronic = documentationType == DocumentationType.electronic;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isElectronic
            ? cs.secondaryContainer
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isElectronic ? l10n.clientsFilterElectronic : l10n.clientsFilterPaper,
        style: tt.labelSmall?.copyWith(
          color: isElectronic ? cs.onSecondaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.clientType});

  final ClientType clientType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOffice = clientType == ClientType.office;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOffice ? cs.tertiaryContainer : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isOffice ? l10n.clientsClientTypeOffice : l10n.clientsClientTypePrivate,
        style: tt.labelSmall?.copyWith(
          color: isOffice ? cs.onTertiaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
