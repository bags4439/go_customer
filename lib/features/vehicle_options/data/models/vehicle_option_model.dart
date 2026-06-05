// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/buyer_vehicle_response.dart';
import '../../domain/entities/listing_source.dart';
import '../../domain/entities/vehicle_option.dart';
import '../../domain/entities/vehicle_option_status.dart';

part 'vehicle_option_model.freezed.dart';
part 'vehicle_option_model.g.dart';

BuyerVehicleResponse _buyerResponseFromJson(Object? json) =>
    BuyerVehicleResponse.fromString(json as String?);

String _buyerResponseToJson(BuyerVehicleResponse value) => value.name;

VehicleOptionStatus _statusFromJson(Object? json) =>
    VehicleOptionStatus.fromString(json as String?);

String _statusToJson(VehicleOptionStatus value) => value.name;

ListingSource? _sourceFromJson(Object? json) =>
    ListingSource.fromString(json as String?);

String? _sourceToJson(ListingSource? value) => value?.name;

DateTime? _dateTimeFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

Object? _dateTimeToJson(DateTime? value) => value?.toIso8601String();

@freezed
class VehicleOptionModel with _$VehicleOptionModel {
  const VehicleOptionModel._();

  const factory VehicleOptionModel({
    required String id,
    required String orderId,
    required String agentId,
    @Default('') String listingUrl,
    @Default('') String listingTitle,
    @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
    ListingSource? source,
    String? agentNote,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    @Default(VehicleOptionStatus.draft)
    VehicleOptionStatus status,
    @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
    @Default(BuyerVehicleResponse.pending)
    BuyerVehicleResponse buyerResponse,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? buyerRespondedAt,
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
    return VehicleOptionModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      agentId: data['agentId'] as String? ?? '',
      listingUrl: data['listingUrl'] as String? ?? '',
      listingTitle: data['listingTitle'] as String? ?? '',
      source: ListingSource.fromString(data['source'] as String?),
      agentNote: data['agentNote'] as String?,
      status: VehicleOptionStatus.fromString(data['status'] as String?),
      buyerResponse: BuyerVehicleResponse.fromString(
        data['buyerResponse'] as String?,
      ),
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      buyerRespondedAt: (data['buyerRespondedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  VehicleOption toEntity() => VehicleOption(
        id: id,
        orderId: orderId,
        agentId: agentId,
        listingUrl: listingUrl,
        listingTitle: listingTitle,
        source: source,
        agentNote: agentNote,
        status: status,
        buyerResponse: buyerResponse,
        sentAt: sentAt,
        buyerRespondedAt: buyerRespondedAt,
        createdAt: createdAt,
      );
}
