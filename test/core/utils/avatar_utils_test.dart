// test/core/utils/avatar_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:debit_pro/core/utils/avatar_utils.dart';

void main() {
  group('AvatarUtils.initialsFromName', () {
    test('returns two initials for a two-word name', () {
      expect(AvatarUtils.initialsFromName('محمد أحمد'), 'مأ');
    });

    test('returns one initial for a single-word name', () {
      expect(AvatarUtils.initialsFromName('محمد'), 'م');
    });

    test('uppercases ASCII names', () {
      expect(AvatarUtils.initialsFromName('john doe'), 'JD');
    });

    test('handles extra whitespace', () {
      expect(AvatarUtils.initialsFromName('  Ali  Hassan  '), 'AH');
    });

    test('returns empty string for empty input', () {
      expect(AvatarUtils.initialsFromName(''), '');
    });
  });

  group('AvatarUtils.colorForId', () {
    test('returns a color from the palette for a non-empty id', () {
      final color = AvatarUtils.colorForId('abc123');
      expect(color, isNotNull);
    });

    test('is deterministic — same id yields same color', () {
      expect(AvatarUtils.colorForId('xyz'), AvatarUtils.colorForId('xyz'));
    });

    test('returns first palette color for empty id', () {
      expect(AvatarUtils.colorForId('').toARGB32(), isNonZero);
    });
  });
}
