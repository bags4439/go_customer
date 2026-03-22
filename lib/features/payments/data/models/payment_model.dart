import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required String id,
    required String orderId,
    required String buyerId,
    String? paymentRequestId,
    String? paymentRef,
    required String type,
    String? description,
    required double amountGhs,
    double? amountUsd,
    double? exchangeRate,
    @Default('GHS') String currency,
    String? method,
    String? provider,
    String? providerRef,
    @Default('pending') String status,
    String? failureReason,
    DateTime? initiatedAt,
    DateTime? confirmedAt,
    DateTime? refundedAt,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return PaymentModel(
        id: doc.id,
        orderId: '',
        buyerId: '',
        type: '',
        amountGhs: 0,
      );
    }
    return PaymentModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      paymentRequestId: data['paymentRequestId'] as String?,
      paymentRef: data['paymentRef'] as String?,
      type: data['type'] as String? ?? '',
      description: data['description'] as String?,
      amountGhs: (data['amountGhs'] as num?)?.toDouble() ?? 0,
      amountUsd: (data['amountUsd'] as num?)?.toDouble(),
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble(),
      currency: data['currency'] as String? ?? 'GHS',
      method: data['method'] as String?,
      provider: data['provider'] as String?,
      providerRef: data['providerRef'] as String?,
      status: data['status'] as String? ?? 'pending',
      failureReason: data['failureReason'] as String?,
      initiatedAt: (data['initiatedAt'] as Timestamp?)?.toDate(),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      refundedAt: (data['refundedAt'] as Timestamp?)?.toDate(),
    );
  }
}
