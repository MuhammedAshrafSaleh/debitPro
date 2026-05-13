// lib/core/presentation/widgets/app_snackbar.dart

import 'package:flutter/material.dart';

abstract class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(
      context,
      message,
      Theme.of(context).colorScheme.secondary,
      duration: const Duration(seconds: 3),
    );
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 4),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor, {
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );
  }
}
