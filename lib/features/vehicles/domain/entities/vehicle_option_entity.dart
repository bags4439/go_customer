/// Domain representation of a vehicle option (no Firestore/types).
class VehicleOptionEntity {
  final String id;
  final String orderId;
  final String? agentId;
  final String? lotNumber;
  final String? source;
  final String? yearMakeModel;
  final int? year;
  final String? make;
  final String? model;
  final String? trim;
  final int? mileage;
  final String? condition;
  final String? conditionLabel;
  final String? damageDescription;
  final String? photoUrl;
  final List<String> photoUrls;
  final DateTime? auctionDate;
  final String? auctionLocation;
  final String? vin;
  final String? colour;
  final String? engine;
  final String? transmission;
  final double? auctionPriceUsd;
  final double? buyersPremiumPct;
  final double? buyersPremiumUsd;
  final double? towingStorageUsd;
  final double? shippingUsd;
  final double? marineInsuranceUsd;
  final double? exchangeRate;
  final double? dutyGhs;
  final double? clearanceGhs;
  final double? repairEstimateGhs;
  final double? serviceFeeGhs;
  final double? totalLandedGhs;
  final String? agentNote;
  final String? status;

  const VehicleOptionEntity({
    required this.id,
    required this.orderId,
    this.agentId,
    this.lotNumber,
    this.source,
    this.yearMakeModel,
    this.year,
    this.make,
    this.model,
    this.trim,
    this.mileage,
    this.condition,
    this.conditionLabel,
    this.damageDescription,
    this.photoUrl,
    this.photoUrls = const [],
    this.auctionDate,
    this.auctionLocation,
    this.vin,
    this.colour,
    this.engine,
    this.transmission,
    this.auctionPriceUsd,
    this.buyersPremiumPct,
    this.buyersPremiumUsd,
    this.towingStorageUsd,
    this.shippingUsd,
    this.marineInsuranceUsd,
    this.exchangeRate,
    this.dutyGhs,
    this.clearanceGhs,
    this.repairEstimateGhs,
    this.serviceFeeGhs,
    this.totalLandedGhs,
    this.agentNote,
    this.status,
  });
}
