// lib/features/grace_periods/presentation/pages/add_grace_period_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/quality_badge.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/status_utils.dart';
import '../../../clients/domain/entities/client_entity.dart';
import '../../../clients/presentation/cubit/client_detail_cubit.dart';
import '../../../clients/presentation/cubit/client_detail_state.dart';
import '../cubit/add_grace_period_cubit.dart';
import '../cubit/add_grace_period_state.dart';

class AddGracePeriodPage extends StatelessWidget {
  const AddGracePeriodPage({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ClientDetailCubit>()..loadClient(clientId),
        ),
        BlocProvider(create: (_) => sl<AddGracePeriodCubit>()),
      ],
      child: _AddGracePeriodView(clientId: clientId),
    );
  }
}

class _AddGracePeriodView extends StatelessWidget {
  const _AddGracePeriodView({required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AddGracePeriodCubit, AddGracePeriodState>(
      listener: (context, state) {
        if (state.status == AddGracePeriodStatus.failure &&
            state.errorMessage != null) {
          AppSnackbar.error(context, state.errorMessage!);
        } else if (state.status == AddGracePeriodStatus.saved) {
          AppSnackbar.success(context, l10n.gracePeriodAddSuccess);
          if (context.mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.gracePeriodAddTitle)),
        body: BlocBuilder<ClientDetailCubit, ClientDetailState>(
          builder: (context, clientState) {
            if (clientState is ClientDetailLoading ||
                clientState is ClientDetailInitial) {
              return const AppLoadingIndicator();
            }
            if (clientState is ClientDetailFailure) {
              return Center(child: Text(clientState.message));
            }
            if (clientState is! ClientDetailLoaded) {
              return const SizedBox.shrink();
            }

            final client = clientState.client;
            final badge =
                StatusUtils.qualityBadge(client.paymentQualityScore);

            return BlocBuilder<AddGracePeriodCubit, AddGracePeriodState>(
              builder: (context, formState) {
                return _GracePeriodForm(
                  client: client,
                  qualityBadgeWidget: QualityBadgeWidget(badge: badge),
                  officeCommissionAmount: formState.officeCommissionAmount,
                  isLoading: formState.isSaving,
                  onCapitalChanged: (capital) {
                    context
                        .read<AddGracePeriodCubit>()
                        .updateOfficeCommission(
                          capital: capital,
                          isOfficeClient:
                              client.clientType == ClientType.office,
                        );
                  },
                  onSave: ({
                    required name,
                    required capital,
                    required dueDate,
                    required officeCommissionPaidAtCreation,
                    notes,
                  }) {
                    context.read<AddGracePeriodCubit>().save(
                          clientId: clientId,
                          clientType: client.clientType,
                          officeCommissionPaidAtCreation:
                              officeCommissionPaidAtCreation,
                          name: name,
                          capital: capital,
                          dueDate: dueDate,
                          notes: notes,
                        );
                  },
                  onCancel: () => context.pop(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GracePeriodForm extends StatefulWidget {
  const _GracePeriodForm({
    required this.client,
    required this.qualityBadgeWidget,
    required this.officeCommissionAmount,
    required this.isLoading,
    required this.onCapitalChanged,
    required this.onSave,
    required this.onCancel,
  });

  final ClientEntity client;
  final Widget qualityBadgeWidget;
  final double officeCommissionAmount;
  final bool isLoading;
  final void Function(double capital) onCapitalChanged;
  final void Function({
    required String name,
    required double capital,
    required DateTime dueDate,
    required bool officeCommissionPaidAtCreation,
    String? notes,
  }) onSave;
  final VoidCallback onCancel;

  @override
  State<_GracePeriodForm> createState() => _GracePeriodFormState();
}

class _GracePeriodFormState extends State<_GracePeriodForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capitalCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _dueDate;
  late bool _officeCommissionPaid;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _capitalCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _dueDate = DateTime.now();
    _officeCommissionPaid = false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capitalCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    final capital = double.tryParse(_capitalCtrl.text) ?? 0;
    widget.onSave(
      name: _nameCtrl.text,
      capital: capital,
      dueDate: _dueDate,
      officeCommissionPaidAtCreation: _officeCommissionPaid,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOffice = widget.client.clientType == ClientType.office;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Client banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.client.fullName, style: tt.titleMedium),
                      const SizedBox(height: 4),
                      widget.qualityBadgeWidget,
                    ],
                  ),
                ),
                if (isOffice)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.clientsClientTypeOffice,
                      style: tt.labelSmall?.copyWith(color: cs.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Office commission toggle (only for office clients)
          if (isOffice) ...[
            Row(
              children: [
                Icon(Icons.business_center_outlined,
                    size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(l10n.gracePeriodOfficeCommissionPaid, style: tt.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SelectableChip(
                    label: l10n.commonYes,
                    selected: _officeCommissionPaid,
                    onTap: () =>
                        setState(() => _officeCommissionPaid = true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SelectableChip(
                    label: l10n.commonNo,
                    selected: !_officeCommissionPaid,
                    onTap: () =>
                        setState(() => _officeCommissionPaid = false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Name
          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n.gracePeriodName,
              hintText: l10n.gracePeriodNameHint,
              prefixIcon: const Icon(Icons.label_outline),
            ),
            enabled: true,
          ),
          const SizedBox(height: 12),

          // Capital
          TextFormField(
            controller: _capitalCtrl,
            decoration: InputDecoration(
              labelText: l10n.gracePeriodCapital,
              prefixIcon: const Icon(Icons.attach_money_outlined),
              suffixText: CurrencyUtils.currencyForLocale(locale),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: true,
            onChanged: (v) {
              final capital = double.tryParse(v) ?? 0;
              widget.onCapitalChanged(capital);
            },
          ),
          const SizedBox(height: 16),

          // Due date picker
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(l10n.gracePeriodDueDate, style: tt.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(locale, _dueDate),
                    style: tt.bodyMedium,
                  ),
                  Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notes
          TextFormField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: l10n.gracePeriodNotes,
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
            maxLines: 3,
            enabled: true,
          ),
          const SizedBox(height: 16),

          // Summary card (commission preview)
          if (isOffice && widget.officeCommissionAmount > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: cs.outline.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.gracePeriodOfficeCommission,
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  Text(
                    CurrencyUtils.formatCurrency(
                        widget.officeCommissionAmount, locale),
                    style: tt.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          AppButton(
            label: l10n.gracePeriodSave,
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(l10n.commonCancel),
          ),
          SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
        ],
      ),
    );
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
    final month = (locale == 'ar' ? arMonths : enMonths)[date.month - 1];
    return '${date.day.toString().padLeft(2, '0')} $month ${date.year}';
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
