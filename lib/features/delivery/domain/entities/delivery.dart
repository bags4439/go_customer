class Delivery {
  const Delivery({
    required this.id,
    required this.orderId,
    this.deliveryAddress,
    this.deliveryCity,
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.locationSource,
    this.recipientName,
    this.recipientPhone,
    this.buyerConfirmed,
    this.buyerConfirmedAt,
    this.status,
    this.paymentConfirmed,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String orderId;
  final String? deliveryAddress;
  final String? deliveryCity;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final String? locationSource;
  final String? recipientName;
  final String? recipientPhone;
  final bool? buyerConfirmed;
  final DateTime? buyerConfirmedAt;
  final String? status;
  final bool? paymentConfirmed;
  final String? notes;
  final DateTime? createdAt;

  bool get hasLocation =>
      deliveryAddress != null && deliveryAddress!.trim().isNotEmpty;

  bool get isConfirmed => buyerConfirmed == true;
}
