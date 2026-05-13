// lib/features/installments/presentation/widgets/installment_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../features/clients/domain/entities/client_entity.dart';

class InstallmentFormData {
  const InstallmentFormData({
    required this.itemName,
    required this.capital,
    required this.profitAmount,
    required this.durationMonths,
    required this.startDate,
    required this.officeCommissionPaidAtCreation,
  });

  final String itemName;
  final double capital;
  final double profitAmount;
  final int durationMonths;
  final DateTime startDate;
  final bool officeCommissionPaidAtCreation;
}

class InstallmentForm extends StatefulWidget {
  const InstallmentForm({
    super.key,
    required this.clientName,
    required this.clientType,
    required this.qualityBadgeWidget,
    required this.monthlyAmount,
    required this.totalDebt,
    required this.durationMonths,
    required this.officeCommissionAmount,
    required this.isLoading,
    required this.onSave,
    required this.onFormChanged,
    required this.onCancel,
    this.initialItemName,
    this.initialCapital,
    this.initialProfitAmount,
    this.initialDurationMonths,
    this.initialStartDate,
    this.initialOfficeCommissionPaid = false,
    this.isEditLocked = false,
  });

  final String clientName;
  final ClientType clientType;
  final Widget qualityBadgeWidget;
  final double monthlyAmount;
  final double totalDebt;
  final int durationMonths;
  final double officeCommissionAmount;
  final bool isLoading;
  final void Function(InstallmentFormData) onSave;
  final void Function({
    required double capital,
    required double profitAmount,
    required int durationMonths,
  }) onFormChanged;
  final VoidCallback onCancel;

  final String? initialItemName;
  final double? initialCapital;
  final double? initialProfitAmount;
  final int? initialDurationMonths;
  final DateTime? initialStartDate;
  final bool initialOfficeCommissionPaid;
  final bool isEditLocked;

  @override
  State<InstallmentForm> createState() => _InstallmentFormState();
}

class _InstallmentFormState extends State<InstallmentForm> {
  late final TextEditingController _itemNameCtrl;
  late final TextEditingController _capitalCtrl;
  late final TextEditingController _profitCtrl;
  late int _selectedDuration;
  late DateTime _startDate;
  late bool _officeCommissionPaid;

  @override
  void initState() {
    super.initState();
    _itemNameCtrl =
        TextEditingController(text: widget.initialItemName ?? '');
    _capitalCtrl = TextEditingController(
      text: widget.initialCapital != null && widget.initialCapital! > 0
          ? widget.initialCapital!.toStringAsFixed(0)
          : '',
    );
    _profitCtrl = TextEditingController(
      text: widget.initialProfitAmount != null &&
              widget.initialProfitAmount! > 0
          ? widget.initialProfitAmount!.toStringAsFixed(0)
          : '',
    );
    _selectedDuration =
        widget.initialDurationMonths ?? AppConstants.kAllowedDurationMonths[3];
    _startDate = widget.initialStartDate ?? DateTime.now();
    _officeCommissionPaid = widget.initialOfficeCommissionPaid;
  }

  @override
  void dispose() {
    _itemNameCtrl.dispose();
    _capitalCtrl.dispose();
    _profitCtrl.dispose();
    super.dispose();
  }

  void _notifyFormChanged() {
    final capital = double.tryParse(_capitalCtrl.text) ?? 0;
    final profit = double.tryParse(_profitCtrl.text) ?? 0;
    widget.onFormChanged(
      capital: capital,
      profitAmount: profit,
      durationMonths: _selectedDuration,
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  void _submit() {
    final capital = double.tryParse(_capitalCtrl.text) ?? 0;
    final profit = double.tryParse(_profitCtrl.text) ?? 0;
    widget.onSave(InstallmentFormData(
      itemName: _itemNameCtrl.text,
      capital: capital,
      profitAmount: profit,
      durationMonths: _selectedDuration,
      startDate: _startDate,
      officeCommissionPaidAtCreation: _officeCommissionPaid,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isOffice = widget.clientType == ClientType.office;

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
                      Text(widget.clientName, style: tt.titleMedium),
                      const SizedBox(height: 4),
                      widget.qualityBadgeWidget,
                    ],
                  ),
                ),
                if (isOffice)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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

          // Locked banner
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
                      l10n.installmentsEditLocked,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),

          // Office commission toggle (only for office clients, not in edit mode)
          if (isOffice && !widget.isEditLocked) ...[
            Row(
              children: [
                Icon(Icons.business_center_outlined,
                    size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  l10n.installmentsOfficeCommissionPaid,
                  style: tt.bodyMedium,
                ),
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

          // Item name
          TextFormField(
            controller: _itemNameCtrl,
            decoration: InputDecoration(
              labelText: l10n.installmentsItemName,
              hintText: l10n.installmentsItemNameHint,
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
            ),
            enabled: !widget.isEditLocked,
          ),
          const SizedBox(height: 12),

          // Capital
          TextFormField(
            controller: _capitalCtrl,
            decoration: InputDecoration(
              labelText: l10n.installmentsCapital,
              prefixIcon: const Icon(Icons.attach_money_outlined),
              suffixText: CurrencyUtils.currencyForLocale(locale),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: !widget.isEditLocked,
            onChanged: (_) => _notifyFormChanged(),
          ),
          const SizedBox(height: 12),

          // Profit
          TextFormField(
            controller: _profitCtrl,
            decoration: InputDecoration(
              labelText: l10n.installmentsProfit,
              prefixIcon: const Icon(Icons.percent_outlined),
              suffixText: CurrencyUtils.currencyForLocale(locale),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            enabled: !widget.isEditLocked,
            onChanged: (_) => _notifyFormChanged(),
          ),
          const SizedBox(height: 16),

          // Duration chips
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(l10n.installmentsDuration, style: tt.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.kAllowedDurationMonths.map((months) {
              return _SelectableChip(
                label: '$months',
                selected: _selectedDuration == months,
                onTap: widget.isEditLocked
                    ? null
                    : () {
                        setState(() => _selectedDuration = months);
                        _notifyFormChanged();
                      },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Start date
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(l10n.installmentsStartDate, style: tt.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: widget.isEditLocked ? null : () => _pickDate(context),
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
                    '${_startDate.day.toString().padLeft(2, '0')} '
                    '${_monthShort(locale, _startDate.month)} '
                    '${_startDate.year}',
                    style: tt.bodyMedium,
                  ),
                  Icon(Icons.expand_more, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Live summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: cs.outline.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.summarize_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(l10n.installmentsSummary,
                        style: tt.labelLarge),
                  ],
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  label: l10n.installmentsMonthlyAmount,
                  value: CurrencyUtils.formatCurrency(
                      widget.monthlyAmount, locale),
                  highlight: true,
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: l10n.installmentsTotalDuration,
                  value:
                      '${widget.durationMonths} ${l10n.installmentsMonths}',
                ),
                const Divider(height: 20),
                _SummaryRow(
                  label: l10n.installmentsTotalDebt,
                  value: CurrencyUtils.formatCurrency(
                      widget.totalDebt, locale),
                  highlight: true,
                ),
                if (isOffice && widget.officeCommissionAmount > 0) ...[
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: l10n.installmentsOfficeCommission,
                    value: CurrencyUtils.formatCurrency(
                        widget.officeCommissionAmount, locale),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            label: l10n.installmentsSave,
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

  static String _monthShort(String locale, int month) {
    const arMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const enMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return (locale == 'ar' ? arMonths : enMonths)[month - 1];
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        Text(
          value,
          style: highlight
              ? tt.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                )
              : tt.bodyMedium,
        ),
      ],
    );
  }
}
