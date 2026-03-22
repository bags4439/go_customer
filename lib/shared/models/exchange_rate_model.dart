import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exchange_rate_model.freezed.dart';
part 'exchange_rate_model.g.dart';

@freezed
class ExchangeRateModel with _$ExchangeRateModel {
  const factory ExchangeRateModel({
    required String id,
    required double usdToGhs,
    String? source,
    DateTime? fetchedAt,
    @Default(true) bool isCurrent,
  }) = _ExchangeRateModel;

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateModelFromJson(json);

  factory ExchangeRateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return ExchangeRateModel(id: doc.id, usdToGhs: 15.40);
    }
    return ExchangeRateModel(
      id: doc.id,
      usdToGhs: (data['usdToGhs'] as num?)?.toDouble() ?? 15.40,
      source: data['source'] as String?,
      fetchedAt: (data['fetchedAt'] as Timestamp?)?.toDate(),
      isCurrent: data['isCurrent'] as bool? ?? false,
    );
  }
}
