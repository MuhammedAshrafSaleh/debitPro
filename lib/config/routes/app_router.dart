// lib/config/routes/app_router.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/auth/presentation/pages/email_sent_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/clients/presentation/pages/add_client_page.dart';
import '../../features/clients/presentation/pages/client_detail_page.dart';
import '../../features/clients/presentation/pages/client_list_page.dart';
import '../../features/clients/presentation/pages/edit_client_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/grace_periods/presentation/pages/add_grace_period_page.dart';
import '../../features/grace_periods/presentation/pages/edit_grace_period_page.dart';
import '../../features/installments/presentation/pages/add_installment_page.dart';
import '../../features/installments/presentation/pages/edit_installment_page.dart';
import '../../features/installments/presentation/pages/installment_tracking_page.dart';
import '../../features/settings/presentation/pages/edit_account_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../core/presentation/widgets/main_shell.dart';

const _authRoutes = {'/login', '/register', '/forgot-password', '/forgot-password/sent'};

GoRouter buildRouter() => GoRouter(
      initialLocation: '/login',
      refreshListenable: _AuthChangeNotifier(),
      redirect: (context, state) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        final location = state.matchedLocation;
        final isAuthRoute = _authRoutes.contains(location);
        final isVerifyRoute = location == '/verify-email';

        if (firebaseUser == null) {
          // Not signed in — force to login unless already on an auth screen
          return isAuthRoute ? null : '/login';
        }

        if (!firebaseUser.emailVerified) {
          // Signed in but unverified — only allow /verify-email
          return isVerifyRoute ? null : '/verify-email';
        }

        // Fully authenticated — bounce auth/verify screens to dashboard
        if (isAuthRoute || isVerifyRoute) return '/dashboard';
        return null;
      },
      routes: [
        // ── Auth routes (no shell) ─────────────────────────────────────────────
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/forgot-password/sent',
          builder: (context, state) => EmailSentPage(
            email: state.extra as String?,
          ),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (context, state) => const VerifyEmailPage(),
        ),

        // ── Main shell (persistent bottom nav) ─────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/clients',
              builder: (context, state) => const ClientListPage(),
            ),
            GoRoute(
              path: '/accounts',
              builder: (context, state) => const AccountsPage(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),

        // ── Client sub-routes ─────────────────────────────────────────────────
        GoRoute(
          path: '/clients/add',
          builder: (context, state) => const AddClientPage(),
        ),
        GoRoute(
          path: '/clients/:clientId',
          builder: (context, state) => ClientDetailPage(
            clientId: state.pathParameters['clientId']!,
          ),
        ),
        GoRoute(
          path: '/clients/:clientId/edit',
          builder: (context, state) => EditClientPage(
            clientId: state.pathParameters['clientId']!,
          ),
        ),

        // ── Installment sub-routes ─────────────────────────────────────────────
        GoRoute(
          path: '/installments/add/:clientId',
          builder: (context, state) => AddInstallmentPage(
            clientId: state.pathParameters['clientId']!,
          ),
        ),
        GoRoute(
          path: '/installments/:installmentId',
          builder: (context, state) => InstallmentTrackingPage(
            installmentId: state.pathParameters['installmentId']!,
          ),
        ),
        GoRoute(
          path: '/installments/:installmentId/edit',
          builder: (context, state) => EditInstallmentPage(
            installmentId: state.pathParameters['installmentId']!,
          ),
        ),

        // ── Grace period sub-routes ────────────────────────────────────────────
        GoRoute(
          path: '/grace-periods/add/:clientId',
          builder: (context, state) => AddGracePeriodPage(
            clientId: state.pathParameters['clientId']!,
          ),
        ),
        GoRoute(
          path: '/grace-periods/:gracePeriodId/edit',
          builder: (context, state) => EditGracePeriodPage(
            gracePeriodId: state.pathParameters['gracePeriodId']!,
          ),
        ),

        // ── Settings sub-routes ────────────────────────────────────────────────
        GoRoute(
          path: '/settings/edit-account',
          builder: (context, state) => const EditAccountPage(),
        ),
      ],
    );

/// Notifies GoRouter when Firebase auth state changes so the redirect guard re-runs.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
