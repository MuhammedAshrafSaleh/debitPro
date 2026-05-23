// lib/features/settings/presentation/pages/settings_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../../core/presentation/widgets/confirm_dialog.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../features/auth/domain/usecases/sign_out_use_case.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../widgets/owner_config_row.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final displayName = firebaseUser?.displayName ?? '';
    final email = firebaseUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: AvatarWidget(
            name: displayName,
            id: firebaseUser?.uid ?? '',
            radius: 16,
          ),
        ),
        title: Text(l10n.settingsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _ProfileCard(name: displayName, email: email),
          const SizedBox(height: 24),
          _SectionLabel(label: l10n.settingsPreferences),
          const SizedBox(height: 8),
          _PreferencesCard(),
          const SizedBox(height: 24),
          _SectionLabel(label: l10n.settingsAccountSection),
          const SizedBox(height: 8),
          _AccountCard(),
          const SizedBox(height: 32),
          _LogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AvatarWidget(name: name, id: uid, radius: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PRO',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, left: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.start,
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final isDark = settings.themeMode == ThemeMode.dark;
        final langLabel = settings.languageCode == 'ar'
            ? l10n.settingsLanguageAr
            : l10n.settingsLanguageEn;

        return Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l10n.settingsLanguage),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      langLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                    ),
                  ],
                ),
                onTap: () =>
                    _showLanguagePicker(context, settings.languageCode),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.settingsNightMode),
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) => context.read<SettingsCubit>().setTheme(
                    val ? ThemeMode.dark : ThemeMode.light,
                  ),
                ),
              ),
              if (AppConstants.kShowOwnerSettings) ...[
                const Divider(),
                const OwnerConfigRowProvider(),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, String currentCode) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.settingsSelectLanguage,
                style: Theme.of(sheetCtx).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                label: l10n.settingsLanguageAr,
                code: 'ar',
                isSelected: currentCode == 'ar',
                onTap: () {
                  context.read<SettingsCubit>().setLanguage('ar');
                  Navigator.of(sheetCtx).pop();
                },
              ),
              const SizedBox(height: 8),
              _LanguageOption(
                label: l10n.settingsLanguageEn,
                code: 'en',
                isSelected: currentCode == 'en',
                onTap: () {
                  context.read<SettingsCubit>().setLanguage('en');
                  Navigator.of(sheetCtx).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isSelected ? colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.settingsAccountSettings),
            trailing: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
            ),
            onTap: () => context.push('/settings/edit-account'),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      icon: const Icon(Icons.logout),
      label: Text(l10n.settingsLogout, style: TextStyle(fontSize: 15.0)),
      onPressed: () async {
        final confirmed = await showConfirmDialog(
          context,
          title: l10n.settingsLogout,
          message: l10n.commonLogoutConfirm,
          confirmLabel: l10n.commonLogout,
        );
        if (!confirmed || !context.mounted) return;
        final result = await sl<SignOutUseCase>().call(NoParams());
        if (!context.mounted) return;
        result.fold(
          (failure) => AppSnackbar.error(context, failure.message),
          (_) {},
        );
      },
    );
  }
}
