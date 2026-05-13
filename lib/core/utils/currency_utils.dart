// lib/core/utils/currency_utils.dart

import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String currencyForLocale(String languageCode) => 'SAR';

  static String formatCurrency(num amount, String languageCode) {
    final formatter = NumberFormat.currency(
      locale: languageCode == 'ar' ? 'ar_SA' : 'en_US',
      symbol: 'ر.س',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}
