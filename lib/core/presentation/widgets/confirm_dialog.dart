// lib/core/presentation/widgets/confirm_dialog.dart

import 'package:flutter/material.dart';

import '../../../config/l10n/app_localizations.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
}) async {
  final resolvedCancel =
      cancelLabel ?? AppLocalizations.of(context).commonCancel;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(resolvedCancel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  confirmLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}
