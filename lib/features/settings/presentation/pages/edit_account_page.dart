// lib/features/settings/presentation/pages/edit_account_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../cubit/edit_account_cubit.dart';
import '../cubit/edit_account_state.dart';

class EditAccountPage extends StatelessWidget {
  const EditAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditAccountCubit>(
      create: (_) => sl<EditAccountCubit>(),
      child: const _EditAccountView(),
    );
  }
}

class _EditAccountView extends StatefulWidget {
  const _EditAccountView();

  @override
  State<_EditAccountView> createState() => _EditAccountViewState();
}

class _EditAccountViewState extends State<_EditAccountView> {
  late final TextEditingController _nameController;
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late String _initialName;
  late String _currentEmail;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _initialName = user?.displayName ?? '';
    _currentEmail = user?.email ?? '';

    _nameController = TextEditingController(text: _initialName);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return BlocListener<EditAccountCubit, EditAccountState>(
      listener: (context, state) {
        if (state is EditAccountSuccess) {
          AppSnackbar.success(context, _successMessage(context, state.type));
          if (state.type == EditAccountSuccessType.password) {
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          }
          context.read<EditAccountCubit>().reset();
        } else if (state is EditAccountFailure) {
          final msg = state.code != null
              ? _validationMessage(context, state.code!)
              : (state.serverMessage ?? AppLocalizations.of(context).commonError);
          AppSnackbar.error(context, msg);
          context.read<EditAccountCubit>().reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsAccountSection),
          centerTitle: true,
        ),
        body: BlocBuilder<EditAccountCubit, EditAccountState>(
          builder: (context, state) {
            final isLoading = state is EditAccountLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  AvatarWidget(
                    name: user?.displayName ?? '',
                    id: user?.uid ?? '',
                    radius: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PRO',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _SectionHeader(label: l10n.settingsProfileInfo),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: l10n.settingsDisplayName,
                    controller: _nameController,
                    prefixIcon: const Icon(Icons.person_outline),
                    enabled: !isLoading,
                    textInputAction: TextInputAction.next,
                    suffixIcon: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => _saveName(context),
                      child: Text(l10n.commonEdit),
                    ),
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: l10n.authEmailLabel,
                    initialValue: _currentEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    enabled: false,
                    suffixIcon: TextButton(
                      onPressed: isLoading
                          ? null
                          : () => _showEmailDialog(context),
                      child: Text(l10n.commonEdit),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _SectionHeader(label: l10n.settingsSecurity),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: l10n.settingsCurrentPassword,
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: l10n.settingsNewPassword,
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),

                  AppTextField(
                    label: l10n.settingsConfirmNewPassword,
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    enabled: !isLoading,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _saveChanges(context),
                  ),
                  const SizedBox(height: 32),

                  if (isLoading)
                    const AppLoadingIndicator()
                  else
                    AppButton(
                      label: l10n.settingsSaveChanges,
                      onPressed: () => _saveChanges(context),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _successMessage(BuildContext context, EditAccountSuccessType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case EditAccountSuccessType.displayName:
        return l10n.settingsDisplayNameUpdated;
      case EditAccountSuccessType.email:
        return l10n.settingsEmailVerificationSent;
      case EditAccountSuccessType.password:
        return l10n.settingsPasswordUpdated;
    }
  }

  String _validationMessage(BuildContext context, EditAccountErrorCode code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case EditAccountErrorCode.emptyDisplayName:
        return l10n.settingsDisplayNameEmpty;
      case EditAccountErrorCode.emptyEmail:
        return l10n.settingsEmailEmpty;
      case EditAccountErrorCode.emptyCurrentPasswordForEmail:
        return l10n.settingsCurrentPasswordRequiredForEmail;
      case EditAccountErrorCode.emptyCurrentPassword:
        return l10n.settingsCurrentPasswordRequired;
      case EditAccountErrorCode.shortNewPassword:
        return l10n.authPasswordMinLength;
      case EditAccountErrorCode.passwordMismatch:
        return l10n.authPasswordMismatch;
    }
  }

  void _saveName(BuildContext context) {
    final newName = _nameController.text.trim();
    if (newName == _initialName) return;
    context.read<EditAccountCubit>().updateDisplayName(newName);
  }

  Future<void> _showEmailDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.authEmailLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: l10n.authEmailLabel,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: l10n.settingsCurrentPassword,
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<EditAccountCubit>().updateEmail(
        newEmail: emailController.text,
        currentPassword: passwordController.text,
      );
    }

    emailController.dispose();
    passwordController.dispose();
  }

  void _saveChanges(BuildContext context) {
    final newName = _nameController.text.trim();
    final currentPw = _currentPasswordController.text;
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;

    if (newName != _initialName && newName.isNotEmpty) {
      context.read<EditAccountCubit>().updateDisplayName(newName);
      return;
    }

    if (newPw.isNotEmpty || currentPw.isNotEmpty) {
      context.read<EditAccountCubit>().updatePassword(
        currentPassword: currentPw,
        newPassword: newPw,
        confirmPassword: confirmPw,
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
