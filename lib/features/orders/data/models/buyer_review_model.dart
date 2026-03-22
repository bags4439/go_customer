import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'buyer_review_model.freezed.dart';
part 'buyer_review_model.g.dart';

@freezed
class BuyerReviewModel with _$BuyerReviewModel {
  const factory BuyerReviewModel({
    required String id,
    required String orderId,
    required String buyerId,
    required String agentId,
    required double overallRating,
    required double agentRating,
    required double communicationRating,
    required double speedRating,
    String? comment,
    DateTime? createdAt,
  }) = _BuyerReviewModel;

  factory BuyerReviewModel.fromJson(Map<String, dynamic> json) =>
      _$BuyerReviewModelFromJson(json);

  factory BuyerReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return BuyerReviewModel(
        id: doc.id,
        orderId: '',
        buyerId: '',
        agentId: '',
        overallRating: 0,
        agentRating: 0,
        communicationRating: 0,
        speedRating: 0,
      );
    }
    return BuyerReviewModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      agentId: data['agentId'] as String? ?? '',
      overallRating: (data['overallRating'] as num?)?.toDouble() ?? 0,
      agentRating: (data['agentRating'] as num?)?.toDouble() ?? 0,
      communicationRating:
          (data['communicationRating'] as num?)?.toDouble() ?? 0,
      speedRating: (data['speedRating'] as num?)?.toDouble() ?? 0,
      comment: data['comment'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
