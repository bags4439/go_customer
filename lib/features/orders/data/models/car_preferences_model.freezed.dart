// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CarPreferencesModel _$CarPreferencesModelFromJson(Map<String, dynamic> json) {
  return _CarPreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$CarPreferencesModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get make => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  int? get yearMin => throw _privateConstructorUsedError;
  int? get yearMax => throw _privateConstructorUsedError;
  bool get isSingleYear => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _vehicleConditionFromJson, toJson: _vehicleConditionToJson)
  VehicleCondition? get condition => throw _privateConstructorUsedError;
  String? get conditionLabel => throw _privateConstructorUsedError;
  int? get maxMileage => throw _privateConstructorUsedError;
  bool? get repairOptedIn => throw _privateConstructorUsedError;
  bool? get clearanceOptedIn => throw _privateConstructorUsedError;
  String? get trim => throw _privateConstructorUsedError;
  String get purchaseOrigin => throw _privateConstructorUsedError;
  bool get isNewVehicle => throw _privateConstructorUsedError;
  String? get editedBy => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  String? get editReason => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CarPreferencesModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CarPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarPreferencesModelCopyWith<CarPreferencesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarPreferencesModelCopyWith<$Res> {
  factory $CarPreferencesModelCopyWith(
    CarPreferencesModel value,
    $Res Function(CarPreferencesModel) then,
  ) = _$CarPreferencesModelCopyWithImpl<$Res, CarPreferencesModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String? make,
    String? model,
    int? yearMin,
    int? yearMax,
    bool isSingleYear,
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
    String purchaseOrigin,
    bool isNewVehicle,
    String? editedBy,
    DateTime? editedAt,
    String? editReason,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$CarPreferencesModelCopyWithImpl<$Res, $Val extends CarPreferencesModel>
    implements $CarPreferencesModelCopyWith<$Res> {
  _$CarPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? make = freezed,
    Object? model = freezed,
    Object? yearMin = freezed,
    Object? yearMax = freezed,
    Object? isSingleYear = null,
    Object? condition = freezed,
    Object? conditionLabel = freezed,
    Object? maxMileage = freezed,
    Object? repairOptedIn = freezed,
    Object? clearanceOptedIn = freezed,
    Object? trim = freezed,
    Object? purchaseOrigin = null,
    Object? isNewVehicle = null,
    Object? editedBy = freezed,
    Object? editedAt = freezed,
    Object? editReason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            make: freezed == make
                ? _value.make
                : make // ignore: cast_nullable_to_non_nullable
                      as String?,
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            yearMin: freezed == yearMin
                ? _value.yearMin
                : yearMin // ignore: cast_nullable_to_non_nullable
                      as int?,
            yearMax: freezed == yearMax
                ? _value.yearMax
                : yearMax // ignore: cast_nullable_to_non_nullable
                      as int?,
            isSingleYear: null == isSingleYear
                ? _value.isSingleYear
                : isSingleYear // ignore: cast_nullable_to_non_nullable
                      as bool,
            condition: freezed == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as VehicleCondition?,
            conditionLabel: freezed == conditionLabel
                ? _value.conditionLabel
                : conditionLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxMileage: freezed == maxMileage
                ? _value.maxMileage
                : maxMileage // ignore: cast_nullable_to_non_nullable
                      as int?,
            repairOptedIn: freezed == repairOptedIn
                ? _value.repairOptedIn
                : repairOptedIn // ignore: cast_nullable_to_non_nullable
                      as bool?,
            clearanceOptedIn: freezed == clearanceOptedIn
                ? _value.clearanceOptedIn
                : clearanceOptedIn // ignore: cast_nullable_to_non_nullable
                      as bool?,
            trim: freezed == trim
                ? _value.trim
                : trim // ignore: cast_nullable_to_non_nullable
                      as String?,
            purchaseOrigin: null == purchaseOrigin
                ? _value.purchaseOrigin
                : purchaseOrigin // ignore: cast_nullable_to_non_nullable
                      as String,
            isNewVehicle: null == isNewVehicle
                ? _value.isNewVehicle
                : isNewVehicle // ignore: cast_nullable_to_non_nullable
                      as bool,
            editedBy: freezed == editedBy
                ? _value.editedBy
                : editedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            editedAt: freezed == editedAt
                ? _value.editedAt
                : editedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            editReason: freezed == editReason
                ? _value.editReason
                : editReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CarPreferencesModelImplCopyWith<$Res>
    implements $CarPreferencesModelCopyWith<$Res> {
  factory _$$CarPreferencesModelImplCopyWith(
    _$CarPreferencesModelImpl value,
    $Res Function(_$CarPreferencesModelImpl) then,
  ) = __$$CarPreferencesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String? make,
    String? model,
    int? yearMin,
    int? yearMax,
    bool isSingleYear,
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
    String purchaseOrigin,
    bool isNewVehicle,
    String? editedBy,
    DateTime? editedAt,
    String? editReason,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$CarPreferencesModelImplCopyWithImpl<$Res>
    extends _$CarPreferencesModelCopyWithImpl<$Res, _$CarPreferencesModelImpl>
    implements _$$CarPreferencesModelImplCopyWith<$Res> {
  __$$CarPreferencesModelImplCopyWithImpl(
    _$CarPreferencesModelImpl _value,
    $Res Function(_$CarPreferencesModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CarPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? make = freezed,
    Object? model = freezed,
    Object? yearMin = freezed,
    Object? yearMax = freezed,
    Object? isSingleYear = null,
    Object? condition = freezed,
    Object? conditionLabel = freezed,
    Object? maxMileage = freezed,
    Object? repairOptedIn = freezed,
    Object? clearanceOptedIn = freezed,
    Object? trim = freezed,
    Object? purchaseOrigin = null,
    Object? isNewVehicle = null,
    Object? editedBy = freezed,
    Object? editedAt = freezed,
    Object? editReason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$CarPreferencesModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        make: freezed == make
            ? _value.make
            : make // ignore: cast_nullable_to_non_nullable
                  as String?,
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        yearMin: freezed == yearMin
            ? _value.yearMin
            : yearMin // ignore: cast_nullable_to_non_nullable
                  as int?,
        yearMax: freezed == yearMax
            ? _value.yearMax
            : yearMax // ignore: cast_nullable_to_non_nullable
                  as int?,
        isSingleYear: null == isSingleYear
            ? _value.isSingleYear
            : isSingleYear // ignore: cast_nullable_to_non_nullable
                  as bool,
        condition: freezed == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as VehicleCondition?,
        conditionLabel: freezed == conditionLabel
            ? _value.conditionLabel
            : conditionLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxMileage: freezed == maxMileage
            ? _value.maxMileage
            : maxMileage // ignore: cast_nullable_to_non_nullable
                  as int?,
        repairOptedIn: freezed == repairOptedIn
            ? _value.repairOptedIn
            : repairOptedIn // ignore: cast_nullable_to_non_nullable
                  as bool?,
        clearanceOptedIn: freezed == clearanceOptedIn
            ? _value.clearanceOptedIn
            : clearanceOptedIn // ignore: cast_nullable_to_non_nullable
                  as bool?,
        trim: freezed == trim
            ? _value.trim
            : trim // ignore: cast_nullable_to_non_nullable
                  as String?,
        purchaseOrigin: null == purchaseOrigin
            ? _value.purchaseOrigin
            : purchaseOrigin // ignore: cast_nullable_to_non_nullable
                  as String,
        isNewVehicle: null == isNewVehicle
            ? _value.isNewVehicle
            : isNewVehicle // ignore: cast_nullable_to_non_nullable
                  as bool,
        editedBy: freezed == editedBy
            ? _value.editedBy
            : editedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        editedAt: freezed == editedAt
            ? _value.editedAt
            : editedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        editReason: freezed == editReason
            ? _value.editReason
            : editReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CarPreferencesModelImpl implements _CarPreferencesModel {
  const _$CarPreferencesModelImpl({
    required this.id,
    required this.orderId,
    this.make,
    this.model,
    this.yearMin,
    this.yearMax,
    this.isSingleYear = false,
    @JsonKey(
      fromJson: _vehicleConditionFromJson,
      toJson: _vehicleConditionToJson,
    )
    this.condition,
    this.conditionLabel,
    this.maxMileage,
    this.repairOptedIn,
    this.clearanceOptedIn,
    this.trim,
    this.purchaseOrigin = 'any',
    this.isNewVehicle = false,
    this.editedBy,
    this.editedAt,
    this.editReason,
    this.createdAt,
  });

  factory _$CarPreferencesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CarPreferencesModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? make;
  @override
  final String? model;
  @override
  final int? yearMin;
  @override
  final int? yearMax;
  @override
  @JsonKey()
  final bool isSingleYear;
  @override
  @JsonKey(fromJson: _vehicleConditionFromJson, toJson: _vehicleConditionToJson)
  final VehicleCondition? condition;
  @override
  final String? conditionLabel;
  @override
  final int? maxMileage;
  @override
  final bool? repairOptedIn;
  @override
  final bool? clearanceOptedIn;
  @override
  final String? trim;
  @override
  @JsonKey()
  final String purchaseOrigin;
  @override
  @JsonKey()
  final bool isNewVehicle;
  @override
  final String? editedBy;
  @override
  final DateTime? editedAt;
  @override
  final String? editReason;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'CarPreferencesModel(id: $id, orderId: $orderId, make: $make, model: $model, yearMin: $yearMin, yearMax: $yearMax, isSingleYear: $isSingleYear, condition: $condition, conditionLabel: $conditionLabel, maxMileage: $maxMileage, repairOptedIn: $repairOptedIn, clearanceOptedIn: $clearanceOptedIn, trim: $trim, purchaseOrigin: $purchaseOrigin, isNewVehicle: $isNewVehicle, editedBy: $editedBy, editedAt: $editedAt, editReason: $editReason, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarPreferencesModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.yearMin, yearMin) || other.yearMin == yearMin) &&
            (identical(other.yearMax, yearMax) || other.yearMax == yearMax) &&
            (identical(other.isSingleYear, isSingleYear) ||
                other.isSingleYear == isSingleYear) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.conditionLabel, conditionLabel) ||
                other.conditionLabel == conditionLabel) &&
            (identical(other.maxMileage, maxMileage) ||
                other.maxMileage == maxMileage) &&
            (identical(other.repairOptedIn, repairOptedIn) ||
                other.repairOptedIn == repairOptedIn) &&
            (identical(other.clearanceOptedIn, clearanceOptedIn) ||
                other.clearanceOptedIn == clearanceOptedIn) &&
            (identical(other.trim, trim) || other.trim == trim) &&
            (identical(other.purchaseOrigin, purchaseOrigin) ||
                other.purchaseOrigin == purchaseOrigin) &&
            (identical(other.isNewVehicle, isNewVehicle) ||
                other.isNewVehicle == isNewVehicle) &&
            (identical(other.editedBy, editedBy) ||
                other.editedBy == editedBy) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.editReason, editReason) ||
                other.editReason == editReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    make,
    model,
    yearMin,
    yearMax,
    isSingleYear,
    condition,
    conditionLabel,
    maxMileage,
    repairOptedIn,
    clearanceOptedIn,
    trim,
    purchaseOrigin,
    isNewVehicle,
    editedBy,
    editedAt,
    editReason,
    createdAt,
  ]);

  /// Create a copy of CarPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarPreferencesModelImplCopyWith<_$CarPreferencesModelImpl> get copyWith =>
      __$$CarPreferencesModelImplCopyWithImpl<_$CarPreferencesModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CarPreferencesModelImplToJson(this);
  }
}

abstract class _CarPreferencesModel implements CarPreferencesModel {
  const factory _CarPreferencesModel({
    required final String id,
    required final String orderId,
    final String? make,
    final String? model,
    final int? yearMin,
    final int? yearMax,
    final bool isSingleYear,
    @JsonKey(
      fromJson: _vehicleConditionFromJson,
      toJson: _vehicleConditionToJson,
    )
    final VehicleCondition? condition,
    final String? conditionLabel,
    final int? maxMileage,
    final bool? repairOptedIn,
    final bool? clearanceOptedIn,
    final String? trim,
    final String purchaseOrigin,
    final bool isNewVehicle,
    final String? editedBy,
    final DateTime? editedAt,
    final String? editReason,
    final DateTime? createdAt,
  }) = _$CarPreferencesModelImpl;

  factory _CarPreferencesModel.fromJson(Map<String, dynamic> json) =
      _$CarPreferencesModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get make;
  @override
  String? get model;
  @override
  int? get yearMin;
  @override
  int? get yearMax;
  @override
  bool get isSingleYear;
  @override
  @JsonKey(fromJson: _vehicleConditionFromJson, toJson: _vehicleConditionToJson)
  VehicleCondition? get condition;
  @override
  String? get conditionLabel;
  @override
  int? get maxMileage;
  @override
  bool? get repairOptedIn;
  @override
  bool? get clearanceOptedIn;
  @override
  String? get trim;
  @override
  String get purchaseOrigin;
  @override
  bool get isNewVehicle;
  @override
  String? get editedBy;
  @override
  DateTime? get editedAt;
  @override
  String? get editReason;
  @override
  DateTime? get createdAt;

  /// Create a copy of CarPreferencesModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarPreferencesModelImplCopyWith<_$CarPreferencesModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
