// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/shipping.dart';

part 'shipping_model.freezed.dart';
part 'shipping_model.g.dart';

enum ShippingStatus {
  pending,
  booked,
  departed,
  inTransit,
  arrived,
  released;

  static ShippingStatus fromString(String v) {
    const map = <String, ShippingStatus>{
      'pending': ShippingStatus.pending,
      'booked': ShippingStatus.booked,
      'departed': ShippingStatus.departed,
      'in_transit': ShippingStatus.inTransit,
      'arrived': ShippingStatus.arrived,
      'released': ShippingStatus.released,
    };
    return map[v] ?? ShippingStatus.pending;
  }

  String get firestoreValue {
    const map = <ShippingStatus, String>{
      ShippingStatus.pending: 'pending',
      ShippingStatus.booked: 'booked',
      ShippingStatus.departed: 'departed',
      ShippingStatus.inTransit: 'in_transit',
      ShippingStatus.arrived: 'arrived',
      ShippingStatus.released: 'released',
    };
    return map[this] ?? 'pending';
  }
}

ShippingStatus _shippingStatusFromJson(Object? json) =>
    ShippingStatus.fromString(json as String? ?? 'pending');

String _shippingStatusToJson(ShippingStatus s) => s.firestoreValue;

@freezed
class ShippingModel with _$ShippingModel {
  const factory ShippingModel({
    required String id,
    required String orderId,
    String? vesselName,
    String? shippingLine,
    String? blNumber,
    String? containerNumber,
    String? originPort,
    @Default('Tema, Ghana') String destinationPort,
    String? trackingUrl,
    DateTime? estimatedDeparture,
    DateTime? actualDeparture,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    double? journeyProgressPct,
    @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
    @Default(ShippingStatus.pending)
    ShippingStatus status,
    String? agentNotes,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) = _ShippingModel;

  factory ShippingModel.fromJson(Map<String, dynamic> json) =>
      _$ShippingModelFromJson(json);

  factory ShippingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return ShippingModel(id: doc.id, orderId: '');
    }
    return ShippingModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      vesselName: data['vesselName'] as String?,
      shippingLine: data['shippingLine'] as String?,
      blNumber: data['blNumber'] as String?,
      containerNumber: data['containerNumber'] as String?,
      originPort: data['originPort'] as String?,
      destinationPort:
          data['destinationPort'] as String? ?? 'Tema, Ghana',
      trackingUrl: data['trackingUrl'] as String?,
      estimatedDeparture:
          (data['estimatedDeparture'] as Timestamp?)?.toDate(),
      actualDeparture:
          (data['actualDeparture'] as Timestamp?)?.toDate(),
      estimatedArrival:
          (data['estimatedArrival'] as Timestamp?)?.toDate(),
      actualArrival:
          (data['actualArrival'] as Timestamp?)?.toDate(),
      journeyProgressPct:
          (data['journeyProgressPct'] as num?)?.toDouble(),
      status: ShippingStatus.fromString(
        data['status'] as String? ?? 'pending',
      ),
      agentNotes: data['agentNotes'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Maps domain [Shipping] -> data [ShippingModel].
  factory ShippingModel.fromEntity(
    Shipping shipping, {
    String? id,
    DateTime? createdAt,
  }) {
    return ShippingModel(
      id: id ?? shipping.orderId,
      orderId: shipping.orderId,
      vesselName: shipping.vesselName,
      shippingLine: shipping.shippingLine,
      blNumber: shipping.blNumber,
      containerNumber: shipping.containerNumber,
      originPort: shipping.originPort,
      destinationPort: shipping.destinationPort ?? 'Tema, Ghana',
      trackingUrl: shipping.trackingUrl,
      estimatedDeparture: shipping.estimatedDeparture,
      actualDeparture: shipping.actualDeparture,
      estimatedArrival: shipping.estimatedArrival,
      actualArrival: shipping.actualArrival,
      journeyProgressPct: shipping.journeyProgressPct,
      status: ShippingStatus.fromString(shipping.status),
      agentNotes: shipping.agentNotes,
      updatedAt: shipping.updatedAt,
      createdAt: createdAt,
    );
  }
}

/// Maps Firestore shipping doc → domain [Shipping] (doc id is often `orderId`).
Shipping shippingFromDoc(DocumentSnapshot doc) {
  final m = ShippingModel.fromFirestore(doc);
  return m.toEntity(fallbackOrderId: doc.id);
}

extension ShippingModelX on ShippingModel {
  /// Maps data [ShippingModel] -> domain [Shipping].
  Shipping toEntity({String? fallbackOrderId}) {
    final resolvedOrderId =
        orderId.isNotEmpty ? orderId : (fallbackOrderId ?? id);
    return Shipping(
      orderId: resolvedOrderId,
      vesselName: vesselName,
      shippingLine: shippingLine,
      blNumber: blNumber,
      containerNumber: containerNumber,
      originPort: originPort,
      destinationPort: destinationPort,
      trackingUrl: trackingUrl,
      estimatedDeparture: estimatedDeparture,
      actualDeparture: actualDeparture,
      estimatedArrival: estimatedArrival,
      actualArrival: actualArrival,
      journeyProgressPct: journeyProgressPct,
      status: status.firestoreValue,
      agentNotes: agentNotes,
      updatedAt: updatedAt,
    );
  }
}
