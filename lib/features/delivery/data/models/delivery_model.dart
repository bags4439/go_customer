import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_model.freezed.dart';
part 'delivery_model.g.dart';

@freezed
class DeliveryModel with _$DeliveryModel {
  const factory DeliveryModel({
    required String id,
    required String orderId,
    String? handledBy,
    @Default(false) bool paymentsCleared,
    String? deliveryAddress,
    String? deliveryCity,
    double? latitude,
    double? longitude,
    String? locationLabel,
    String? locationSource,
    String? recipientName,
    String? recipientPhone,
    DateTime? scheduledDate,
    DateTime? actualDeliveryDate,
    String? deliveredBy,
    String? proofOfDeliveryUrl,
    @Default(false) bool buyerConfirmed,
    DateTime? buyerConfirmedAt,
    @Default('pending_payment') String status,
    @Default(false) bool paymentConfirmed,
    DateTime? paymentConfirmedAt,
    String? notes,
    String? collectionAddress,
    double? collectionLatitude,
    double? collectionLongitude,
    String? collectionNotes,
    DateTime? createdAt,
  }) = _DeliveryModel;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);

  factory DeliveryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return DeliveryModel(
        id: doc.id,
        orderId: '',
      );
    }
    return DeliveryModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      handledBy: data['handledBy'] as String?,
      paymentsCleared: data['paymentsCleared'] as bool? ?? false,
      deliveryAddress: data['deliveryAddress'] as String?,
      deliveryCity: data['deliveryCity'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationLabel: data['locationLabel'] as String?,
      locationSource: data['locationSource'] as String?,
      recipientName: data['recipientName'] as String?,
      recipientPhone: data['recipientPhone'] as String?,
      scheduledDate: (data['scheduledDate'] as Timestamp?)?.toDate(),
      actualDeliveryDate:
          (data['actualDeliveryDate'] as Timestamp?)?.toDate(),
      deliveredBy: data['deliveredBy'] as String?,
      proofOfDeliveryUrl: data['proofOfDeliveryUrl'] as String?,
      buyerConfirmed: data['buyerConfirmed'] as bool? ?? false,
      buyerConfirmedAt:
          (data['buyerConfirmedAt'] as Timestamp?)?.toDate(),
      status: data['status'] as String? ?? 'pending_payment',
      paymentConfirmed: data['paymentConfirmed'] as bool? ?? false,
      paymentConfirmedAt:
          (data['paymentConfirmedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      collectionAddress: data['collectionAddress'] as String?,
      collectionLatitude:
          (data['collectionLatitude'] as num?)?.toDouble(),
      collectionLongitude:
          (data['collectionLongitude'] as num?)?.toDouble(),
      collectionNotes: data['collectionNotes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
