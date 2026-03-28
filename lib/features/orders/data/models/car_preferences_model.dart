// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_preferences_model.freezed.dart';
part 'car_preferences_model.g.dart';

enum VehicleCondition {
  runAndDrive,
  repairable,
  fullRebuild,
  newVehicle,
  goodCondition,
  fairCondition;

  static VehicleCondition fromString(String value) {
    return switch (value) {
      'run_and_drive' => VehicleCondition.runAndDrive,
      'repairable' => VehicleCondition.repairable,
      'full_rebuild' => VehicleCondition.fullRebuild,
      'new_vehicle' => VehicleCondition.newVehicle,
      'good_condition' => VehicleCondition.goodCondition,
      'fair_condition' => VehicleCondition.fairCondition,
      _ => VehicleCondition.runAndDrive,
    };
  }

  String get firestoreValue => switch (this) {
        VehicleCondition.runAndDrive => 'run_and_drive',
        VehicleCondition.repairable => 'repairable',
        VehicleCondition.fullRebuild => 'full_rebuild',
        VehicleCondition.newVehicle => 'new_vehicle',
        VehicleCondition.goodCondition => 'good_condition',
        VehicleCondition.fairCondition => 'fair_condition',
      };

  String get label => switch (this) {
        VehicleCondition.runAndDrive => 'Run & drive',
        VehicleCondition.repairable => 'Needs moderate repair',
        VehicleCondition.fullRebuild => 'Full rebuild project',
        VehicleCondition.newVehicle => 'Brand new',
        VehicleCondition.goodCondition => 'Good condition',
        VehicleCondition.fairCondition => 'Fair condition',
      };
}

VehicleCondition? _vehicleConditionFromJson(Object? json) {
  if (json == null) return null;
  return VehicleCondition.fromString(json as String);
}

Object? _vehicleConditionToJson(VehicleCondition? c) => c?.firestoreValue;

@freezed
class CarPreferencesModel with _$CarPreferencesModel {
  const factory CarPreferencesModel({
    required String id,
    required String orderId,
    String? make,
    String? model,
    int? yearMin,
    int? yearMax,
    @Default(false) bool isSingleYear,
    @JsonKey(
      fromJson: _vehicleConditionFromJson,
      toJson: _vehicleConditionToJson,
    )
    VehicleCondition? condition,
    String? conditionLabel,
    int? maxMileage,
    bool? repairOptedIn,
    bool? clearanceOptedIn,
    String? trim,
    @Default('any') String purchaseOrigin,
    @Default(false) bool isNewVehicle,
    String? editedBy,
    DateTime? editedAt,
    String? editReason,
    DateTime? createdAt,
  }) = _CarPreferencesModel;

  factory CarPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$CarPreferencesModelFromJson(json);

  factory CarPreferencesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return CarPreferencesModel(id: doc.id, orderId: '');
    }
    final conditionStr = data['condition'] as String?;
    return CarPreferencesModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      make: data['make'] as String?,
      model: data['model'] as String?,
      yearMin: data['yearMin'] as int?,
      yearMax: data['yearMax'] as int?,
      isSingleYear: data['isSingleYear'] as bool? ?? false,
      condition: conditionStr != null
          ? VehicleCondition.fromString(conditionStr)
          : null,
      conditionLabel: data['conditionLabel'] as String?,
      maxMileage: data['maxMileage'] as int?,
      repairOptedIn: data['repairOptedIn'] as bool?,
      clearanceOptedIn: data['clearanceOptedIn'] as bool?,
      trim: data['trim'] as String?,
      purchaseOrigin: data['purchaseOrigin'] as String? ?? 'any',
      isNewVehicle: data['isNewVehicle'] as bool? ?? false,
      editedBy: data['editedBy'] as String?,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      editReason: data['editReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
