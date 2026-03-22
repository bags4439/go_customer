// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../vehicles/domain/entities/vehicle_option_entity.dart';

part 'vehicle_option_model.freezed.dart';
part 'vehicle_option_model.g.dart';

enum VehicleOptionStatus {
  draft,
  sent,
  confirmed,
  rejected;

  static VehicleOptionStatus fromString(String v) =>
      VehicleOptionStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => VehicleOptionStatus.draft,
      );
}

VehicleOptionStatus _vehicleOptionStatusFromJson(Object? json) =>
    VehicleOptionStatus.fromString(json as String? ?? 'draft');

String _vehicleOptionStatusToJson(VehicleOptionStatus s) => s.name;

List<String>? _stringListFromJson(Object? json) {
  if (json == null) return null;
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  return null;
}

Object? _stringListToJson(List<String>? list) => list;

DateTime? _dateTimeFromJson(Object? v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Object? _dateTimeToJson(DateTime? d) => d?.toIso8601String();

@freezed
class VehicleOptionModel with _$VehicleOptionModel {
  const factory VehicleOptionModel({
    required String id,
    required String orderId,
    required String agentId,
    String? lotNumber,
    String? source, // 'copart' | 'iaa'
    String? yearMakeModel,
    int? year,
    String? make,
    String? model,
    String? trim,
    int? mileage,
    String? condition,
    String? conditionLabel,
    String? damageDescription,
    String? photoUrl,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? photoUrlsJson,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? auctionDate,
    String? auctionLocation,
    String? vin,
    String? colour,
    String? engine,
    String? transmission,
    double? auctionPriceUsd,
    double? buyersPremiumPct,
    double? buyersPremiumUsd,
    double? towingStorageUsd,
    double? shippingUsd,
    double? marineInsuranceUsd,
    double? exchangeRate,
    double? dutyGhs,
    double? clearanceGhs,
    double? repairEstimateGhs,
    double? serviceFeeGhs,
    double? totalLandedGhs,
    String? agentNote,
    @JsonKey(
      fromJson: _vehicleOptionStatusFromJson,
      toJson: _vehicleOptionStatusToJson,
    )
    @Default(VehicleOptionStatus.draft)
    VehicleOptionStatus status,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? confirmedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,
  }) = _VehicleOptionModel;

  factory VehicleOptionModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleOptionModelFromJson(json);

  factory VehicleOptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return VehicleOptionModel(id: doc.id, orderId: '', agentId: '');
    }
    final rawPhotos = data['photoUrlsJson'];
    return VehicleOptionModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      agentId: data['agentId'] as String? ?? '',
      lotNumber: data['lotNumber'] as String?,
      source: data['source'] as String?,
      yearMakeModel: data['yearMakeModel'] as String?,
      year: data['year'] as int?,
      make: data['make'] as String?,
      model: data['model'] as String?,
      trim: data['trim'] as String?,
      mileage: data['mileage'] as int?,
      condition: data['condition'] as String?,
      conditionLabel: data['conditionLabel'] as String?,
      damageDescription: data['damageDescription'] as String?,
      photoUrl: data['photoUrl'] as String?,
      photoUrlsJson: rawPhotos != null
          ? List<String>.from((rawPhotos as List).map((e) => e.toString()))
          : null,
      auctionDate:
          (data['auctionDate'] as Timestamp?)?.toDate(),
      auctionLocation: data['auctionLocation'] as String?,
      vin: data['vin'] as String?,
      colour: data['colour'] as String?,
      engine: data['engine'] as String?,
      transmission: data['transmission'] as String?,
      auctionPriceUsd:
          (data['auctionPriceUsd'] as num?)?.toDouble(),
      buyersPremiumPct:
          (data['buyersPremiumPct'] as num?)?.toDouble(),
      buyersPremiumUsd:
          (data['buyersPremiumUsd'] as num?)?.toDouble(),
      towingStorageUsd:
          (data['towingStorageUsd'] as num?)?.toDouble(),
      shippingUsd: (data['shippingUsd'] as num?)?.toDouble(),
      marineInsuranceUsd:
          (data['marineInsuranceUsd'] as num?)?.toDouble(),
      exchangeRate: (data['exchangeRate'] as num?)?.toDouble(),
      dutyGhs: (data['dutyGhs'] as num?)?.toDouble(),
      clearanceGhs: (data['clearanceGhs'] as num?)?.toDouble(),
      repairEstimateGhs:
          (data['repairEstimateGhs'] as num?)?.toDouble(),
      serviceFeeGhs:
          (data['serviceFeeGhs'] as num?)?.toDouble(),
      totalLandedGhs:
          (data['totalLandedGhs'] as num?)?.toDouble(),
      agentNote: data['agentNote'] as String?,
      status: VehicleOptionStatus.fromString(
        data['status'] as String? ?? 'draft',
      ),
      confirmedAt: (data['confirmedAt'] as Timestamp?)?.toDate(),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

extension VehicleOptionModelEntityX on VehicleOptionModel {
  VehicleOptionEntity toVehicleOptionEntity() {
    return VehicleOptionEntity(
      id: id,
      orderId: orderId,
      agentId: agentId,
      lotNumber: lotNumber,
      source: source,
      yearMakeModel: yearMakeModel,
      year: year,
      make: make,
      model: model,
      trim: trim,
      mileage: mileage,
      condition: condition,
      conditionLabel: conditionLabel,
      damageDescription: damageDescription,
      photoUrl: photoUrl,
      photoUrls: photoUrlsJson ?? const [],
      auctionDate: auctionDate,
      auctionLocation: auctionLocation,
      vin: vin,
      colour: colour,
      engine: engine,
      transmission: transmission,
      auctionPriceUsd: auctionPriceUsd,
      buyersPremiumPct: buyersPremiumPct,
      buyersPremiumUsd: buyersPremiumUsd,
      towingStorageUsd: towingStorageUsd,
      shippingUsd: shippingUsd,
      marineInsuranceUsd: marineInsuranceUsd,
      exchangeRate: exchangeRate,
      dutyGhs: dutyGhs,
      clearanceGhs: clearanceGhs,
      repairEstimateGhs: repairEstimateGhs,
      serviceFeeGhs: serviceFeeGhs,
      totalLandedGhs: totalLandedGhs,
      agentNote: agentNote,
      status: status.name,
    );
  }

  /// Alias for repositories that map the data model to [VehicleOptionEntity].
  VehicleOptionEntity toEntity() => toVehicleOptionEntity();
}
