// lib/core/presentation/widgets/offline_banner.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../../config/l10n/app_localizations.dart';
import '../../constants/app_spacing.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen(_onChanged);
    // Check current connectivity immediately
    Connectivity().checkConnectivity().then(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline != _isOffline) {
      setState(() => _isOffline = offline);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isOffline
              ? _OfflineBannerBar(message: AppLocalizations.of(context).commonOfflineBanner)
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBannerBar extends StatelessWidget {
  const _OfflineBannerBar({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.error,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
