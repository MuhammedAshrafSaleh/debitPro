// lib/features/dashboard/presentation/widgets/dashboard_header.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/l10n/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/presentation/widgets/avatar_widget.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final user = sl<GetCurrentUserUseCase>()();
    final firstName = _firstName(user?.displayName ?? '');
    final hour = DateTime.now().hour;
    final isMorning = hour >= 5 && hour < 18;
    final greeting = isMorning
        ? l10n.dashboardGreetingMorning
        : l10n.dashboardGreetingEvening;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
      child: Row(
        children: [
          AvatarWidget(
            name: user?.displayName ?? l10n.appName,
            id: user?.uid ?? 'guest',
            radius: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMorning ? Icons.wb_sunny_outlined : Icons.nightlight_round,
                    size: 16,
                    color: isMorning ? Colors.amber : cs.tertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    greeting,
                    style:
                        tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                firstName.isEmpty ? l10n.appName : firstName,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.go('/settings'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.person_outline, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  String _firstName(String full) {
    final trimmed = full.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}
