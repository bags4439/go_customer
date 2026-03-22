import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../vehicles/domain/entities/max_bid_entity.dart';

part 'max_bid_model.freezed.dart';
part 'max_bid_model.g.dart';

@freezed
class MaxBidModel with _$MaxBidModel {
  const factory MaxBidModel({
    required String id,
    required String orderId,
    required String vehicleOptionId,
    required String buyerId,
    required double maxBidUsd,
    required double maxBidGhs,
    required double exchangeRate,
    DateTime? confirmedAt,
    @Default(false) bool agentNotified,
    DateTime? agentNotifiedAt,
  }) = _MaxBidModel;

  factory MaxBidModel.fromJson(Map<String, dynamic> json) =>
      _$MaxBidModelFromJson(json);

  factory MaxBidModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return MaxBidModel(
        id: doc.id,
        orderId: '',
        vehicleOptionId: '',
        buyerId: '',
        maxBidUsd: 0,
        maxBidGhs: 0,
        exchangeRate: 0,
      );
    }
    return MaxBidModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      vehicleOptionId: data['vehicleOptionId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      maxBidUsd: (data['maxBidUsd'] as num?)?.toDouble() ?? 0,
      maxBidGhs: (data['maxBidGhs'] as num?)?.toDouble() ?? 0,
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble() ?? 0,
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      agentNotified: data['agentNotified'] as bool? ?? false,
      agentNotifiedAt: (data['agentNotifiedAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension MaxBidModelEntityX on MaxBidModel {
  MaxBidEntity toEntity() => MaxBidEntity(
        id: id,
        orderId: orderId,
        vehicleOptionId: vehicleOptionId,
        buyerId: buyerId,
        maxBidUsd: maxBidUsd,
        maxBidGhs: maxBidGhs,
        exchangeRate: exchangeRate,
        confirmedAt: confirmedAt,
      );
}
