// lib/features/auth/presentation/pages/verify_email_page.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_snackbar.dart';
import '../cubit/verify_email_cubit.dart';
import '../cubit/verify_email_state.dart';

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerifyEmailCubit>()..startPolling(),
      child: const _VerifyEmailView(),
    );
  }
}

class _VerifyEmailView extends StatefulWidget {
  const _VerifyEmailView();

  @override
  State<_VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<_VerifyEmailView> {
  static const _resendCooldown = 60;
  int _secondsLeft = 0;
  Timer? _cooldownTimer;

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsLeft = _resendCooldown);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final email = context.read<VerifyEmailCubit>().currentEmail;

    return BlocListener<VerifyEmailCubit, VerifyEmailState>(
      listener: (context, state) {
        if (state is VerifyEmailVerified) {
          context.go('/dashboard');
        } else if (state is VerifyEmailResendSuccess) {
          AppSnackbar.success(context, l10n.authVerifyEmailResendSuccess);
          _startCooldown();
        } else if (state is VerifyEmailResendFailure) {
          AppSnackbar.error(context, state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Icon
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 2),
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 44,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.authVerifyEmailTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.authVerifyEmailSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.authVerifyEmailInstruction,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                // Check now
                BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
                  builder: (context, state) => SizedBox(
                    height: 52,
                    child: AppButton(
                      label: l10n.authVerifyEmailCheckNow,
                      isLoading: state is VerifyEmailResendLoading,
                      onPressed: () =>
                          context.read<VerifyEmailCubit>().checkNow(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Resend with cooldown
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          l10n.authVerifyEmailResendIn(
                            _formatTime(_secondsLeft),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : TextButton(
                          onPressed: () =>
                              context.read<VerifyEmailCubit>().resend(),
                          child: Text(l10n.authVerifyEmailResend),
                        ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await context.read<VerifyEmailCubit>().signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: Text(
                      l10n.authVerifyEmailSignOut,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
