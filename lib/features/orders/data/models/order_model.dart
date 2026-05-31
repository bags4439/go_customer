// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_model.freezed.dart';
part 'order_model.g.dart';

enum OrderStatus {
  open,
  agentAssigned,
  searching,
  bidPlaced,
  bidWon,
  bidLost,
  paymentPending,
  paymentReceived,
  shipping,
  arrived,
  dutyPending,
  dutyPaid,
  clearanceInProgress,
  clearanceComplete,
  repairPending,
  repairInProgress,
  repairComplete,
  deliveryInProgress,
  deliveryConfirmed,
  delivered,
  cancelled,
  dormant;

  static const _firestoreAliases = {
    'delivery_in_progress': OrderStatus.deliveryInProgress,
    'delivery_confirmed': OrderStatus.deliveryConfirmed,
  };

  static OrderStatus fromString(String value) {
    final alias = _firestoreAliases[value];
    if (alias != null) return alias;
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.open,
    );
  }

  bool get isActive => ![
        OrderStatus.delivered,
        OrderStatus.cancelled,
        OrderStatus.dormant,
      ].contains(this);

  bool get isCompleted => this == OrderStatus.delivered;
  bool get isCancelled => this == OrderStatus.cancelled;
}

OrderStatus _orderStatusFromJson(Object? json) =>
    OrderStatus.fromString(json as String? ?? 'open');

String _orderStatusToJson(OrderStatus status) => status.name;

@freezed
class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String orderRef,
    required String buyerId,
    String? agentId,
    @JsonKey(fromJson: _orderStatusFromJson, toJson: _orderStatusToJson)
    @Default(OrderStatus.open)
    OrderStatus status,
    String? currentStage,
    @Default(1) int stageNumber,
    @Default(false) bool firstPaymentMade,
    String? cancelledBy,
    String? cancellationReason,
    String? cancellationNote,
    DateTime? cancelledAt,
    DateTime? deliveredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return OrderModel(id: doc.id, orderRef: '', buyerId: '');
    }
    return OrderModel(
      id: doc.id,
      orderRef: data['orderRef'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      agentId: data['agentId'] as String?,
      status: OrderStatus.fromString(
        data['status'] as String? ?? 'open',
      ),
      currentStage: data['currentStage'] as String?,
      stageNumber: data['stageNumber'] as int? ?? 1,
      firstPaymentMade:
          data['firstPaymentMade'] as bool? ?? false,
      cancelledBy: data['cancelledBy'] as String?,
      cancellationReason: data['cancellationReason'] as String?,
      cancellationNote: data['cancellationNote'] as String?,
      cancelledAt:
          (data['cancelledAt'] as Timestamp?)?.toDate(),
      deliveredAt:
          (data['deliveredAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
