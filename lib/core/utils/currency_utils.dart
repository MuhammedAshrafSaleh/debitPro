// lib/core/utils/currency_utils.dart

import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String currencyForLocale(String languageCode) => 'SAR';

  static String formatCurrency(num amount, String languageCode) {
    // Always use en_US for number formatting so digits stay Western (0-9)
    // even in the Arabic locale (PRD §3.3 — no Hindi/Arabic-Indic digits).
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: languageCode == 'ar' ? 'ر.س' : '',
      decimalDigits: 2,
    );
    final formatted = formatter.format(amount).trim();
    return languageCode == 'ar' ? formatted : '$formatted SAR';
  }
}
