// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bid_outcome_model.freezed.dart';
part 'bid_outcome_model.g.dart';

DateTime? _bidDateTimeFromJson(Object? v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Object? _bidDateTimeToJson(DateTime? d) => d?.toIso8601String();

@freezed
class BidOutcomeModel with _$BidOutcomeModel {
  const factory BidOutcomeModel({
    required String id,
    required String orderId,
    String? vehicleOptionId,
    required String agentId,
    required String outcome, // 'won' | 'lost'
    double? maxBidUsd,
    double? finalPriceUsd,
    double? savingUsd,
    double? finalPriceGhs,
    String? lossReason,
    double? lossPriceUsd,
    String? nextStep,
    String? noteToBuyer,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    DateTime? bidDate,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    DateTime? loggedAt,
  }) = _BidOutcomeModel;

  factory BidOutcomeModel.fromJson(Map<String, dynamic> json) =>
      _$BidOutcomeModelFromJson(json);

  factory BidOutcomeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return BidOutcomeModel(
        id: doc.id,
        orderId: '',
        agentId: '',
        outcome: 'lost',
      );
    }
    return BidOutcomeModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      vehicleOptionId: data['vehicleOptionId'] as String?,
      agentId: data['agentId'] as String? ?? '',
      outcome: data['outcome'] as String? ?? 'lost',
      maxBidUsd: (data['maxBidUsd'] as num?)?.toDouble(),
      finalPriceUsd: (data['finalPriceUsd'] as num?)?.toDouble(),
      savingUsd: (data['savingUsd'] as num?)?.toDouble(),
      finalPriceGhs: (data['finalPriceGhs'] as num?)?.toDouble(),
      lossReason: data['lossReason'] as String?,
      lossPriceUsd: (data['lossPriceUsd'] as num?)?.toDouble(),
      nextStep: data['nextStep'] as String?,
      noteToBuyer: data['noteToBuyer'] as String?,
      bidDate: (data['bidDate'] as Timestamp?)?.toDate(),
      loggedAt: (data['loggedAt'] as Timestamp?)?.toDate(),
    );
  }
}
