import 'package:cloud_firestore/cloud_firestore.dart';

/// Active currency document from the Firestore
/// `currencies` collection.
class CurrencyModel {
  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
    this.usdToRate = 1.0,
    this.decimalDigits = 0,
  });

  /// ISO 4217 code e.g. 'GHS', 'USD', 'EUR'
  final String code;

  /// Display symbol e.g. '₵', '$', '€'
  final String symbol;

  /// Display name e.g. 'Ghanaian Cedi'
  final String name;

  /// How many units of this currency equal 1 USD.
  /// USD itself = 1.0.
  final double usdToRate;

  /// Decimal places for formatting.
  /// GHS = 0, USD = 0, EUR = 2.
  final int decimalDigits;

  factory CurrencyModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>?;
    return CurrencyModel(
      code: d?['code'] as String? ?? doc.id,
      symbol: d?['symbol'] as String? ?? '',
      name: d?['name'] as String? ?? '',
      usdToRate: (d?['usdToRate'] as num?)?.toDouble() ?? 1.0,
      decimalDigits: (d?['decimalDigits'] as num?)?.toInt() ?? 0,
    );
  }

  /// USD currency constant — used as fallback.
  static const usd = CurrencyModel(
    code: 'USD',
    symbol: r'$',
    name: 'US Dollar',
    usdToRate: 1.0,
    decimalDigits: 0,
  );
}
