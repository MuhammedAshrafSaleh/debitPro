// lib/features/grace_periods/presentation/pages/edit_grace_period_page.dart

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
import '../cubit/edit_grace_period_cubit.dart';
import '../cubit/edit_grace_period_state.dart';

class EditGracePeriodPage extends StatelessWidget {
  const EditGracePeriodPage({super.key, required this.gracePeriodId});

  final String gracePeriodId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditGracePeriodCubit>()..load(gracePeriodId),
      child: _EditGracePeriodView(gracePeriodId: gracePeriodId),
    );
  }
}

class _EditGracePeriodView extends StatelessWidget {
  const _EditGracePeriodView({required this.gracePeriodId});

  final String gracePeriodId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<EditGracePeriodCubit, EditGracePeriodState>(
      listener: (context, state) {
        if (state.status == EditGracePeriodStatus.failure &&
            state.errorMessage != null) {
          AppSnackbar.error(context, state.errorMessage!);
        } else if (state.status == EditGracePeriodStatus.saved) {
          AppSnackbar.success(context, l10n.gracePeriodEditSuccess);
          if (context.mounted) context.pop();
        }
      },
      builder: (context, state) {
        if (state.isLoading ||
            state.status == EditGracePeriodStatus.initial) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.gracePeriodEditTitle)),
            body: const AppLoadingIndicator(),
          );
        }

        if (state.status == EditGracePeriodStatus.failure &&
            state.gracePeriod == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.gracePeriodEditTitle)),
            body: Center(
                child: Text(state.errorMessage ?? l10n.commonError)),
          );
        }

        final gp = state.gracePeriod!;

        return BlocProvider(
          create: (_) =>
              sl<ClientDetailCubit>()..loadClient(gp.clientId),
          child: Scaffold(
            appBar: AppBar(title: Text(l10n.gracePeriodEditTitle)),
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

                return _EditGracePeriodForm(
                  client: client,
                  qualityBadgeWidget: QualityBadgeWidget(badge: badge),
                  officeCommissionAmount: state.officeCommissionAmount,
                  isLoading: state.isSaving,
                  isEditLocked: gp.editLocked,
                  initialName: gp.name,
                  initialCapital: gp.capital,
                  initialDueDate: gp.dueDate,
                  initialNotes: gp.notes,
                  onSave: ({
                    required name,
                    required capital,
                    required dueDate,
                    notes,
                  }) {
                    context.read<EditGracePeriodCubit>().save(
                          gracePeriodId: gracePeriodId,
                          clientId: gp.clientId,
                          name: name,
                          capital: capital,
                          dueDate: dueDate,
                          notes: notes,
                        );
                  },
                  onCancel: () => context.pop(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _EditGracePeriodForm extends StatefulWidget {
  const _EditGracePeriodForm({
    required this.client,
    required this.qualityBadgeWidget,
    required this.officeCommissionAmount,
    required this.isLoading,
    required this.isEditLocked,
    required this.onSave,
    required this.onCancel,
    this.initialName,
    this.initialCapital,
    this.initialDueDate,
    this.initialNotes,
  });

  final ClientEntity client;
  final Widget qualityBadgeWidget;
  final double officeCommissionAmount;
  final bool isLoading;
  final bool isEditLocked;
  final void Function({
    required String name,
    required double capital,
    required DateTime dueDate,
    String? notes,
  }) onSave;
  final VoidCallback onCancel;
  final String? initialName;
  final double? initialCapital;
  final DateTime? initialDueDate;
  final String? initialNotes;

  @override
  State<_EditGracePeriodForm> createState() => _EditGracePeriodFormState();
}

class _EditGracePeriodFormState extends State<_EditGracePeriodForm> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capitalCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _capitalCtrl = TextEditingController(
      text: widget.initialCapital != null && widget.initialCapital! > 0
          ? widget.initialCapital!.toStringAsFixed(0)
          : '',
    );
    _notesCtrl = TextEditingController(text: widget.initialNotes ?? '');
    _dueDate = widget.initialDueDate ?? DateTime.now();
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

          if (widget.isEditLocked)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      color: cs.onErrorContainer, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.gracePeriodEditLocked,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),

          TextFormField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: l10n.gracePeriodName,
              hintText: l10n.gracePeriodNameHint,
              prefixIcon: const Icon(Icons.label_outline),
            ),
            enabled: !widget.isEditLocked,
          ),
          const SizedBox(height: 12),

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
            enabled: !widget.isEditLocked,
          ),
          const SizedBox(height: 16),

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
            onTap: widget.isEditLocked ? null : () => _pickDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(locale, _dueDate), style: tt.bodyMedium),
                  Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: l10n.gracePeriodNotes,
              prefixIcon: const Icon(Icons.notes_outlined),
            ),
            maxLines: 3,
            enabled: !widget.isEditLocked,
          ),
          const SizedBox(height: 16),

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
            onPressed: widget.isEditLocked ? null : _submit,
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
