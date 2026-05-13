// lib/features/clients/presentation/widgets/client_form.dart

import 'package:flutter/material.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../domain/entities/client_entity.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({
    super.key,
    this.initialFullName,
    this.initialPhone,
    this.initialGender,
    this.initialDocumentationType,
    this.initialClientType,
    this.initialNotes,
    required this.isLoading,
    required this.onSave,
    required this.onCancel,
  });

  final String? initialFullName;
  final String? initialPhone;
  final Gender? initialGender;
  final DocumentationType? initialDocumentationType;
  final ClientType? initialClientType;
  final String? initialNotes;
  final bool isLoading;
  final void Function({
    required String fullName,
    required String phone,
    required Gender gender,
    required DocumentationType documentationType,
    required ClientType clientType,
    String? notes,
  }) onSave;
  final VoidCallback onCancel;

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;
  late Gender _gender;
  late DocumentationType _docType;
  late ClientType _clientType;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialFullName ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialPhone ?? '');
    _notesCtrl = TextEditingController(text: widget.initialNotes ?? '');
    _gender = widget.initialGender ?? Gender.male;
    _docType = widget.initialDocumentationType ?? DocumentationType.electronic;
    _clientType = widget.initialClientType ?? ClientType.private;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSave(
      fullName: _nameCtrl.text,
      phone: _phoneCtrl.text,
      gender: _gender,
      documentationType: _docType,
      clientType: _clientType,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.clientsFullName,
              controller: _nameCtrl,
              prefixIcon: const Icon(Icons.person_outline),
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.clientsFullNameRequired : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: l10n.clientsPhone,
              controller: _phoneCtrl,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? l10n.clientsPhoneRequired : null,
            ),
            const SizedBox(height: 24),

            // Gender
            Text(l10n.clientsGender, style: tt.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Gender>(
              segments: [
                ButtonSegment(
                  value: Gender.male,
                  label: Text(l10n.clientsGenderMale),
                  icon: const Icon(Icons.male),
                ),
                ButtonSegment(
                  value: Gender.female,
                  label: Text(l10n.clientsGenderFemale),
                  icon: const Icon(Icons.female),
                ),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
            const SizedBox(height: 24),

            // Documentation type
            Text(l10n.clientsDocType, style: tt.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<DocumentationType>(
              segments: [
                ButtonSegment(
                  value: DocumentationType.electronic,
                  label: Text(l10n.clientsDocTypeElectronic),
                  icon: const Icon(Icons.smartphone_outlined),
                ),
                ButtonSegment(
                  value: DocumentationType.paper,
                  label: Text(l10n.clientsDocTypePaper),
                  icon: const Icon(Icons.description_outlined),
                ),
              ],
              selected: {_docType},
              onSelectionChanged: (s) => setState(() => _docType = s.first),
            ),
            const SizedBox(height: 24),

            // Client type
            Text(l10n.clientsClientType, style: tt.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<ClientType>(
              segments: [
                ButtonSegment(
                  value: ClientType.private,
                  label: Text(l10n.clientsClientTypePrivate),
                  icon: const Icon(Icons.person_outlined),
                ),
                ButtonSegment(
                  value: ClientType.office,
                  label: Text(l10n.clientsClientTypeOffice),
                  icon: const Icon(Icons.business_outlined),
                ),
              ],
              selected: {_clientType},
              onSelectionChanged: (s) => setState(() => _clientType = s.first),
            ),
            const SizedBox(height: 24),

            // Notes
            AppTextField(
              label: l10n.clientsNotes,
              controller: _notesCtrl,
              prefixIcon: const Icon(Icons.notes_outlined),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),

            AppButton(
              label: l10n.commonSave,
              isLoading: widget.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            AppOutlinedButton(
              label: l10n.commonCancel,
              onPressed: widget.isLoading ? null : widget.onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
