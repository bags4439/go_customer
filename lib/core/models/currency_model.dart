import 'package:cloud_firestore/cloud_firestore.dart';

/// Active currency document from Firestore `currencies` collection.
class CurrencyModel {
  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
  });

  final String code;
  final String symbol;
  final String name;

  factory CurrencyModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>?;
    return CurrencyModel(
      code: d?['code'] as String? ?? doc.id,
      symbol: d?['symbol'] as String? ?? '',
      name: d?['name'] as String? ?? '',
    );
  }
}
