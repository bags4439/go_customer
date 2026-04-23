// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_request_model.freezed.dart';
part 'payment_request_model.g.dart';

enum PaymentRequestType {
  initial,
  vehicleBalance,
  vehicleBalanceAndShipping, // deprecated — legacy records only
  shippingFee,
  clearanceFee,
  repairFee,
  repairBalance,
  deliveryFee;

  static PaymentRequestType fromString(String v) {
    const map = <String, PaymentRequestType>{
      'initial': PaymentRequestType.initial,
      'vehicle_balance': PaymentRequestType.vehicleBalance,
      'vehicle_balance_and_shipping':
          PaymentRequestType.vehicleBalanceAndShipping,
      'shipping_fee': PaymentRequestType.shippingFee,
      'clearance_fee': PaymentRequestType.clearanceFee,
      'repair_fee': PaymentRequestType.repairFee,
      'repair_balance': PaymentRequestType.repairBalance,
      'delivery_fee': PaymentRequestType.deliveryFee,
    };
    return map[v] ?? PaymentRequestType.initial;
  }

  String get firestoreValue {
    const map = <PaymentRequestType, String>{
      PaymentRequestType.initial: 'initial',
      PaymentRequestType.vehicleBalance: 'vehicle_balance',
      PaymentRequestType.vehicleBalanceAndShipping:
          'vehicle_balance_and_shipping',
      PaymentRequestType.shippingFee: 'shipping_fee',
      PaymentRequestType.clearanceFee: 'clearance_fee',
      PaymentRequestType.repairFee: 'repair_fee',
      PaymentRequestType.repairBalance: 'repair_balance',
      PaymentRequestType.deliveryFee: 'delivery_fee',
    };
    return map[this] ?? 'initial';
  }

  String get label {
    const map = <PaymentRequestType, String>{
      PaymentRequestType.initial: 'Deposit & service fee',
      PaymentRequestType.vehicleBalance: 'Vehicle balance',
      PaymentRequestType.vehicleBalanceAndShipping:
          'Vehicle balance + shipping (legacy)',
      PaymentRequestType.shippingFee: 'Shipping fee',
      PaymentRequestType.clearanceFee: 'Port clearance fee',
      PaymentRequestType.repairFee: 'Repair deposit',
      PaymentRequestType.repairBalance: 'Repair balance',
      PaymentRequestType.deliveryFee: 'Delivery fee',
    };
    return map[this] ?? '';
  }
}

PaymentRequestType _paymentRequestTypeFromJson(Object? json) =>
    PaymentRequestType.fromString(json as String? ?? 'initial');

String _paymentRequestTypeToJson(PaymentRequestType t) => t.firestoreValue;

List<BreakdownItem> _breakdownFromJson(Object? json) {
  if (json == null) return [];
  if (json is! List) return [];
  return json
      .whereType<Object?>()
      .map((e) {
        if (e is Map<String, dynamic>) {
          return BreakdownItem.fromJson(e);
        }
        if (e is Map) {
          return BreakdownItem.fromJson(Map<String, dynamic>.from(e));
        }
        return null;
      })
      .whereType<BreakdownItem>()
      .toList();
}

List<Map<String, dynamic>> _breakdownToJson(List<BreakdownItem> list) =>
    list.map((e) => e.toJson()).toList();

@freezed
class BreakdownItem with _$BreakdownItem {
  const factory BreakdownItem({
    required String label,
    required double amountUsd,
    @Default(false) bool isDeduction,
  }) = _BreakdownItem;

  factory BreakdownItem.fromJson(Map<String, dynamic> json) =>
      _$BreakdownItemFromJson(json);

  factory BreakdownItem.fromMap(Map<String, dynamic> map) => BreakdownItem(
        label: map['label'] as String? ?? '',
        amountUsd: (map['amountUsd'] as num?)?.toDouble() ?? 0,
        isDeduction: map['isDeduction'] as bool? ?? false,
      );
}

@freezed
class PaymentRequestModel with _$PaymentRequestModel {
  const factory PaymentRequestModel({
    required String id,
    required String orderId,
    String? createdByAgentId,
    String? paymentId,
    @JsonKey(
      fromJson: _paymentRequestTypeFromJson,
      toJson: _paymentRequestTypeToJson,
    )
    required PaymentRequestType type,
    String? description,
    @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
    @Default([])
    List<BreakdownItem> breakdown,
    required double amountUsd,
    double? exchangeRateAtRequest,
    double? depositDeductedUsd,
    String? timelineStageKey,
    String? invoiceImageUrl,
    DateTime? deadlineAt,
    @Default('pending') String status,
    DateTime? sentAt,
    DateTime? paidAt,
    DateTime? expiredAt,
    DateTime? cancelledAt,
  }) = _PaymentRequestModel;

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestModelFromJson(json);

  factory PaymentRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return PaymentRequestModel(
        id: doc.id,
        orderId: '',
        type: PaymentRequestType.initial,
        amountUsd: 0,
      );
    }
    final rawBreakdown = data['breakdown'] as List<dynamic>?;
    return PaymentRequestModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      createdByAgentId: data['createdByAgentId'] as String?,
      paymentId: data['paymentId'] as String?,
      type: PaymentRequestType.fromString(
        data['type'] as String? ?? 'initial',
      ),
      description: data['description'] as String?,
      breakdown: rawBreakdown
              ?.map((e) => BreakdownItem.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList() ??
          [],
      amountUsd: (data['amountUsd'] as num?)?.toDouble() ?? 0,
      exchangeRateAtRequest:
          (data['exchangeRateAtRequest'] as num?)?.toDouble(),
      depositDeductedUsd:
          (data['depositDeductedUsd'] as num?)?.toDouble(),
      timelineStageKey: data['timelineStageKey'] as String?,
      invoiceImageUrl: data['invoiceImageUrl'] as String?,
      deadlineAt: (data['deadlineAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'pending',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      expiredAt: (data['expiredAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }
}
