// lib/core/presentation/widgets/destructive_bottom_sheet.dart

import 'package:flutter/material.dart';

Future<bool> showDestructiveBottomSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'إلغاء',
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(cancelLabel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      backgroundColor: Theme.of(ctx).colorScheme.error,
                      foregroundColor: Theme.of(ctx).colorScheme.onError,
                    ),
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
      ),
    ),
  );
  return result ?? false;
}
