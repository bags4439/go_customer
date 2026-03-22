// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'car_preferences_model.freezed.dart';
part 'car_preferences_model.g.dart';

enum VehicleCondition {
  runAndDrive,
  repairable,
  fullRebuild;

  static VehicleCondition fromString(String value) {
    switch (value) {
      case 'run_and_drive':
        return VehicleCondition.runAndDrive;
      case 'repairable':
        return VehicleCondition.repairable;
      case 'full_rebuild':
        return VehicleCondition.fullRebuild;
      default:
        return VehicleCondition.runAndDrive;
    }
  }

  String get firestoreValue {
    switch (this) {
      case VehicleCondition.runAndDrive:
        return 'run_and_drive';
      case VehicleCondition.repairable:
        return 'repairable';
      case VehicleCondition.fullRebuild:
        return 'full_rebuild';
    }
  }

  String get label {
    switch (this) {
      case VehicleCondition.runAndDrive:
        return 'Run & drive';
      case VehicleCondition.repairable:
        return 'Needs moderate repair';
      case VehicleCondition.fullRebuild:
        return 'Full rebuild project';
    }
  }
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
      editedBy: data['editedBy'] as String?,
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      editReason: data['editReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
