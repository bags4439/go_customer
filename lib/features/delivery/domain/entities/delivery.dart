class Delivery {
  const Delivery({
    required this.id,
    required this.orderId,
    this.handledBy,
    this.paymentsCleared,
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
    this.collectionAddress,
    this.collectionLatitude,
    this.collectionLongitude,
    this.collectionNotes,
    this.createdAt,
  });

  final String id;
  final String orderId;

  /// 'agent' or 'self' — set when
  /// customer makes delivery choice.
  final String? handledBy;

  /// Set by agent when all required
  /// payments are cleared. Customer
  /// can only set delivery address
  /// after this is true.
  final bool? paymentsCleared;

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

  /// Self-pickup collection point
  /// details — set by agent.
  final String? collectionAddress;
  final double? collectionLatitude;
  final double? collectionLongitude;
  final String? collectionNotes;

  final DateTime? createdAt;

  bool get hasLocation =>
      deliveryAddress != null &&
      deliveryAddress!.trim().isNotEmpty;

  bool get isConfirmed =>
      buyerConfirmed == true;

  bool get isAgentHandled =>
      handledBy == 'agent';

  bool get isSelfPickup =>
      handledBy == 'self';

  bool get isPaymentsCleared =>
      paymentsCleared == true;

  bool get hasCollectionDetails =>
      collectionAddress != null &&
      collectionAddress!
          .trim().isNotEmpty;
}
