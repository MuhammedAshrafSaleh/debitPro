// lib/core/utils/avatar_utils.dart

import 'package:flutter/material.dart';

class AvatarUtils {
  AvatarUtils._();

  static const List<Color> _palette = [
    Color(0xFF3B82F6), // blue
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // amber
    Color(0xFFEF4444), // red
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFFF97316), // orange
  ];

  /// Returns the first letter of each of the first two words (uppercased).
  static String initialsFromName(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Deterministic color based on the document ID.
  static Color colorForId(String id) {
    if (id.isEmpty) return _palette[0];
    final index = id.codeUnits.fold<int>(0, (sum, c) => sum + c) % _palette.length;
    return _palette[index];
  }
}
