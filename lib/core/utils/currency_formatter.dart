import 'package:intl/intl.dart';

import '../models/currency_model.dart';

/// Value object returned by [CurrencyFormatter.formatForDisplay].
/// Primary is the user's preferred currency (large).
/// Secondary is the USD equivalent (small, muted).
/// When preferred currency IS USD, hasSecondary is false.
class CurrencyDisplay {
  const CurrencyDisplay({
    required this.primary,
    this.secondary,
  });

  /// Primary amount in user's preferred currency.
  /// e.g. '₵ 12,500' or '€ 780'
  final String primary;

  /// Secondary USD equivalent shown below primary.
  /// e.g. '≈ $ 850'
  /// Null when preferred currency is USD.
  final String? secondary;

  bool get hasSecondary => secondary != null;
}

/// All monetary formatting for the customer app.
///
/// IMPORTANT: All stored amounts are treated as
/// USD. Convert using currency.usdToRate to get
/// the display amount in preferred currency.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _ghsFormat = NumberFormat.currency(
    symbol: 'GHS ',
    decimalDigits: 0,
  );
  static final _usdFormat = NumberFormat.currency(
    symbol: r'$ ',
    decimalDigits: 0,
  );
  static final _eurFormat = NumberFormat.currency(
    symbol: '€ ',
    decimalDigits: 2,
  );

  /// Format a GHS amount. Uses ₵ symbol.
  static String formatGhs(double amount) => _ghsFormat.format(amount);

  /// Format a USD amount.
  static String formatUsd(double amount) => _usdFormat.format(amount);

  /// Format a EUR amount.
  static String formatEur(double amount) => _eurFormat.format(amount);

  /// Format any amount in any currency using
  /// the correct symbol and decimal places.
  static String format(
    double amount,
    CurrencyModel currency,
  ) {
    final formatter = NumberFormat.currency(
      symbol: '${currency.symbol} ',
      decimalDigits: currency.decimalDigits,
    );
    return formatter.format(amount);
  }

  /// Returns the correct symbol for a currency code.
  static String symbolFor(String code) {
    switch (code) {
      case 'GHS':
        return 'GHS';
      case 'USD':
        return r'$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NGN':
        return 'NGN';
      case 'CAD':
        return r'C$';
      case 'AUD':
        return r'A$';
      case 'ZAR':
        return 'R';
      case 'KES':
        return 'KSh';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'CHF':
        return 'Fr';
      case 'SEK':
        return 'kr';
      case 'NOK':
        return 'kr';
      case 'DKK':
        return 'kr';
      default:
        return code;
    }
  }

  /// The core display method used across all
  /// price display widgets.
  ///
  /// [usdAmount] — the stored amount, treated
  /// as USD regardless of field name.
  ///
  /// [preferredCurrency] — the user's selected
  /// currency from preferredCurrencyProvider.
  ///
  /// Returns [CurrencyDisplay] with:
  /// - primary: amount in preferred currency
  /// - secondary: '≈ $ X' when not USD, null
  ///   when preferred currency is USD
  static CurrencyDisplay formatForDisplay({
    required double usdAmount,
    required CurrencyModel preferredCurrency,
  }) {
    final convertedAmount = usdAmount * preferredCurrency.usdToRate;
    final primaryStr = format(convertedAmount, preferredCurrency);

    if (preferredCurrency.code == 'USD') {
      return CurrencyDisplay(primary: primaryStr);
    }

    final secondaryStr = '≈ ${formatUsd(usdAmount)}';
    return CurrencyDisplay(
      primary: primaryStr,
      secondary: secondaryStr,
    );
  }

  static double ghsToUsd(
    double amountGhs,
    double rateUsdToGhs,
  ) {
    if (rateUsdToGhs <= 0) return 0;
    return amountGhs / rateUsdToGhs;
  }

  static double usdToGhs(
    double amountUsd,
    double rateUsdToGhs,
  ) {
    return amountUsd * rateUsdToGhs;
  }
}
