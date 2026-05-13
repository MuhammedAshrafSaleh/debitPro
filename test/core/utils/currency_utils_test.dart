// test/core/utils/currency_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:debit_pro/core/utils/currency_utils.dart';

void main() {
  group('CurrencyUtils.currencyForLocale', () {
    test('returns SAR for ar', () {
      expect(CurrencyUtils.currencyForLocale('ar'), 'SAR');
    });

    test('returns SAR for en', () {
      expect(CurrencyUtils.currencyForLocale('en'), 'SAR');
    });

    test('returns SAR for any locale', () {
      expect(CurrencyUtils.currencyForLocale('fr'), 'SAR');
    });
  });

  group('CurrencyUtils.formatCurrency', () {
    test('formats positive amount for Arabic locale', () {
      final result = CurrencyUtils.formatCurrency(1000, 'ar');
      expect(result, contains('1,000'));
      expect(result, contains('ر.س'));
    });

    test('formats positive amount for English locale', () {
      final result = CurrencyUtils.formatCurrency(1000, 'en');
      expect(result, contains('1,000'));
      expect(result, contains('ر.س'));
    });

    test('formats zero', () {
      final result = CurrencyUtils.formatCurrency(0, 'en');
      expect(result, contains('0'));
    });
  });
}
