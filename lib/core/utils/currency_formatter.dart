import 'package:intl/intl.dart';

/// GHS and USD formatting. Never hardcode exchange rates — use value from payment_requests or exchangeRateProvider.
class CurrencyFormatter {
  static final _ghsFormat = NumberFormat.currency(
    symbol: 'GHS ',
    decimalDigits: 0,
  );
  static final _usdFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static String formatGhs(double amount) {
    return _ghsFormat.format(amount);
  }

  static String formatUsd(double amount) {
    return _usdFormat.format(amount);
  }

  static double ghsToUsd(double amountGhs, double rateUsdToGhs) {
    if (rateUsdToGhs <= 0) return 0;
    return amountGhs / rateUsdToGhs;
  }

  static double usdToGhs(double amountUsd, double rateUsdToGhs) {
    return amountUsd * rateUsdToGhs;
  }
}
