// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_option_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VehicleOptionModel _$VehicleOptionModelFromJson(Map<String, dynamic> json) {
  return _VehicleOptionModel.fromJson(json);
}

/// @nodoc
mixin _$VehicleOptionModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String? get lotNumber => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError; // 'copart' | 'iaa'
  String? get yearMakeModel => throw _privateConstructorUsedError;
  int? get year => throw _privateConstructorUsedError;
  String? get make => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String? get trim => throw _privateConstructorUsedError;
  int? get mileage => throw _privateConstructorUsedError;
  String? get condition => throw _privateConstructorUsedError;
  String? get conditionLabel => throw _privateConstructorUsedError;
  String? get damageDescription => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get photoUrlsJson => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get auctionDate => throw _privateConstructorUsedError;
  String? get auctionLocation => throw _privateConstructorUsedError;
  String? get vin => throw _privateConstructorUsedError;
  String? get colour => throw _privateConstructorUsedError;
  String? get engine => throw _privateConstructorUsedError;
  String? get transmission => throw _privateConstructorUsedError;
  double? get auctionPriceUsd => throw _privateConstructorUsedError;
  double? get buyersPremiumPct => throw _privateConstructorUsedError;
  double? get buyersPremiumUsd => throw _privateConstructorUsedError;
  double? get towingStorageUsd => throw _privateConstructorUsedError;
  double? get shippingUsd => throw _privateConstructorUsedError;
  double? get marineInsuranceUsd => throw _privateConstructorUsedError;
  double? get exchangeRate => throw _privateConstructorUsedError;
  double? get dutyGhs => throw _privateConstructorUsedError;
  double? get clearanceGhs => throw _privateConstructorUsedError;
  double? get repairEstimateGhs => throw _privateConstructorUsedError;
  double? get serviceFeeGhs => throw _privateConstructorUsedError;
  double? get totalLandedGhs => throw _privateConstructorUsedError;
  String? get agentNote => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _vehicleOptionStatusFromJson,
    toJson: _vehicleOptionStatusToJson,
  )
  VehicleOptionStatus get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get sentAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this VehicleOptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VehicleOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VehicleOptionModelCopyWith<VehicleOptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VehicleOptionModelCopyWith<$Res> {
  factory $VehicleOptionModelCopyWith(
    VehicleOptionModel value,
    $Res Function(VehicleOptionModel) then,
  ) = _$VehicleOptionModelCopyWithImpl<$Res, VehicleOptionModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String agentId,
    String? lotNumber,
    String? source,
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
    VehicleOptionStatus status,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? confirmedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,
  });
}

/// @nodoc
class _$VehicleOptionModelCopyWithImpl<$Res, $Val extends VehicleOptionModel>
    implements $VehicleOptionModelCopyWith<$Res> {
  _$VehicleOptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VehicleOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? agentId = null,
    Object? lotNumber = freezed,
    Object? source = freezed,
    Object? yearMakeModel = freezed,
    Object? year = freezed,
    Object? make = freezed,
    Object? model = freezed,
    Object? trim = freezed,
    Object? mileage = freezed,
    Object? condition = freezed,
    Object? conditionLabel = freezed,
    Object? damageDescription = freezed,
    Object? photoUrl = freezed,
    Object? photoUrlsJson = freezed,
    Object? auctionDate = freezed,
    Object? auctionLocation = freezed,
    Object? vin = freezed,
    Object? colour = freezed,
    Object? engine = freezed,
    Object? transmission = freezed,
    Object? auctionPriceUsd = freezed,
    Object? buyersPremiumPct = freezed,
    Object? buyersPremiumUsd = freezed,
    Object? towingStorageUsd = freezed,
    Object? shippingUsd = freezed,
    Object? marineInsuranceUsd = freezed,
    Object? exchangeRate = freezed,
    Object? dutyGhs = freezed,
    Object? clearanceGhs = freezed,
    Object? repairEstimateGhs = freezed,
    Object? serviceFeeGhs = freezed,
    Object? totalLandedGhs = freezed,
    Object? agentNote = freezed,
    Object? status = null,
    Object? confirmedAt = freezed,
    Object? sentAt = freezed,
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
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            lotNumber: freezed == lotNumber
                ? _value.lotNumber
                : lotNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String?,
            yearMakeModel: freezed == yearMakeModel
                ? _value.yearMakeModel
                : yearMakeModel // ignore: cast_nullable_to_non_nullable
                      as String?,
            year: freezed == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int?,
            make: freezed == make
                ? _value.make
                : make // ignore: cast_nullable_to_non_nullable
                      as String?,
            model: freezed == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                      as String?,
            trim: freezed == trim
                ? _value.trim
                : trim // ignore: cast_nullable_to_non_nullable
                      as String?,
            mileage: freezed == mileage
                ? _value.mileage
                : mileage // ignore: cast_nullable_to_non_nullable
                      as int?,
            condition: freezed == condition
                ? _value.condition
                : condition // ignore: cast_nullable_to_non_nullable
                      as String?,
            conditionLabel: freezed == conditionLabel
                ? _value.conditionLabel
                : conditionLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            damageDescription: freezed == damageDescription
                ? _value.damageDescription
                : damageDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrlsJson: freezed == photoUrlsJson
                ? _value.photoUrlsJson
                : photoUrlsJson // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            auctionDate: freezed == auctionDate
                ? _value.auctionDate
                : auctionDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            auctionLocation: freezed == auctionLocation
                ? _value.auctionLocation
                : auctionLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            vin: freezed == vin
                ? _value.vin
                : vin // ignore: cast_nullable_to_non_nullable
                      as String?,
            colour: freezed == colour
                ? _value.colour
                : colour // ignore: cast_nullable_to_non_nullable
                      as String?,
            engine: freezed == engine
                ? _value.engine
                : engine // ignore: cast_nullable_to_non_nullable
                      as String?,
            transmission: freezed == transmission
                ? _value.transmission
                : transmission // ignore: cast_nullable_to_non_nullable
                      as String?,
            auctionPriceUsd: freezed == auctionPriceUsd
                ? _value.auctionPriceUsd
                : auctionPriceUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            buyersPremiumPct: freezed == buyersPremiumPct
                ? _value.buyersPremiumPct
                : buyersPremiumPct // ignore: cast_nullable_to_non_nullable
                      as double?,
            buyersPremiumUsd: freezed == buyersPremiumUsd
                ? _value.buyersPremiumUsd
                : buyersPremiumUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            towingStorageUsd: freezed == towingStorageUsd
                ? _value.towingStorageUsd
                : towingStorageUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            shippingUsd: freezed == shippingUsd
                ? _value.shippingUsd
                : shippingUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            marineInsuranceUsd: freezed == marineInsuranceUsd
                ? _value.marineInsuranceUsd
                : marineInsuranceUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            exchangeRate: freezed == exchangeRate
                ? _value.exchangeRate
                : exchangeRate // ignore: cast_nullable_to_non_nullable
                      as double?,
            dutyGhs: freezed == dutyGhs
                ? _value.dutyGhs
                : dutyGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            clearanceGhs: freezed == clearanceGhs
                ? _value.clearanceGhs
                : clearanceGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            repairEstimateGhs: freezed == repairEstimateGhs
                ? _value.repairEstimateGhs
                : repairEstimateGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            serviceFeeGhs: freezed == serviceFeeGhs
                ? _value.serviceFeeGhs
                : serviceFeeGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalLandedGhs: freezed == totalLandedGhs
                ? _value.totalLandedGhs
                : totalLandedGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            agentNote: freezed == agentNote
                ? _value.agentNote
                : agentNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as VehicleOptionStatus,
            confirmedAt: freezed == confirmedAt
                ? _value.confirmedAt
                : confirmedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sentAt: freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$VehicleOptionModelImplCopyWith<$Res>
    implements $VehicleOptionModelCopyWith<$Res> {
  factory _$$VehicleOptionModelImplCopyWith(
    _$VehicleOptionModelImpl value,
    $Res Function(_$VehicleOptionModelImpl) then,
  ) = __$$VehicleOptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String agentId,
    String? lotNumber,
    String? source,
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
    VehicleOptionStatus status,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? confirmedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$VehicleOptionModelImplCopyWithImpl<$Res>
    extends _$VehicleOptionModelCopyWithImpl<$Res, _$VehicleOptionModelImpl>
    implements _$$VehicleOptionModelImplCopyWith<$Res> {
  __$$VehicleOptionModelImplCopyWithImpl(
    _$VehicleOptionModelImpl _value,
    $Res Function(_$VehicleOptionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VehicleOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? agentId = null,
    Object? lotNumber = freezed,
    Object? source = freezed,
    Object? yearMakeModel = freezed,
    Object? year = freezed,
    Object? make = freezed,
    Object? model = freezed,
    Object? trim = freezed,
    Object? mileage = freezed,
    Object? condition = freezed,
    Object? conditionLabel = freezed,
    Object? damageDescription = freezed,
    Object? photoUrl = freezed,
    Object? photoUrlsJson = freezed,
    Object? auctionDate = freezed,
    Object? auctionLocation = freezed,
    Object? vin = freezed,
    Object? colour = freezed,
    Object? engine = freezed,
    Object? transmission = freezed,
    Object? auctionPriceUsd = freezed,
    Object? buyersPremiumPct = freezed,
    Object? buyersPremiumUsd = freezed,
    Object? towingStorageUsd = freezed,
    Object? shippingUsd = freezed,
    Object? marineInsuranceUsd = freezed,
    Object? exchangeRate = freezed,
    Object? dutyGhs = freezed,
    Object? clearanceGhs = freezed,
    Object? repairEstimateGhs = freezed,
    Object? serviceFeeGhs = freezed,
    Object? totalLandedGhs = freezed,
    Object? agentNote = freezed,
    Object? status = null,
    Object? confirmedAt = freezed,
    Object? sentAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$VehicleOptionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        lotNumber: freezed == lotNumber
            ? _value.lotNumber
            : lotNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String?,
        yearMakeModel: freezed == yearMakeModel
            ? _value.yearMakeModel
            : yearMakeModel // ignore: cast_nullable_to_non_nullable
                  as String?,
        year: freezed == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int?,
        make: freezed == make
            ? _value.make
            : make // ignore: cast_nullable_to_non_nullable
                  as String?,
        model: freezed == model
            ? _value.model
            : model // ignore: cast_nullable_to_non_nullable
                  as String?,
        trim: freezed == trim
            ? _value.trim
            : trim // ignore: cast_nullable_to_non_nullable
                  as String?,
        mileage: freezed == mileage
            ? _value.mileage
            : mileage // ignore: cast_nullable_to_non_nullable
                  as int?,
        condition: freezed == condition
            ? _value.condition
            : condition // ignore: cast_nullable_to_non_nullable
                  as String?,
        conditionLabel: freezed == conditionLabel
            ? _value.conditionLabel
            : conditionLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        damageDescription: freezed == damageDescription
            ? _value.damageDescription
            : damageDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrlsJson: freezed == photoUrlsJson
            ? _value._photoUrlsJson
            : photoUrlsJson // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        auctionDate: freezed == auctionDate
            ? _value.auctionDate
            : auctionDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        auctionLocation: freezed == auctionLocation
            ? _value.auctionLocation
            : auctionLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        vin: freezed == vin
            ? _value.vin
            : vin // ignore: cast_nullable_to_non_nullable
                  as String?,
        colour: freezed == colour
            ? _value.colour
            : colour // ignore: cast_nullable_to_non_nullable
                  as String?,
        engine: freezed == engine
            ? _value.engine
            : engine // ignore: cast_nullable_to_non_nullable
                  as String?,
        transmission: freezed == transmission
            ? _value.transmission
            : transmission // ignore: cast_nullable_to_non_nullable
                  as String?,
        auctionPriceUsd: freezed == auctionPriceUsd
            ? _value.auctionPriceUsd
            : auctionPriceUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        buyersPremiumPct: freezed == buyersPremiumPct
            ? _value.buyersPremiumPct
            : buyersPremiumPct // ignore: cast_nullable_to_non_nullable
                  as double?,
        buyersPremiumUsd: freezed == buyersPremiumUsd
            ? _value.buyersPremiumUsd
            : buyersPremiumUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        towingStorageUsd: freezed == towingStorageUsd
            ? _value.towingStorageUsd
            : towingStorageUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        shippingUsd: freezed == shippingUsd
            ? _value.shippingUsd
            : shippingUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        marineInsuranceUsd: freezed == marineInsuranceUsd
            ? _value.marineInsuranceUsd
            : marineInsuranceUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        exchangeRate: freezed == exchangeRate
            ? _value.exchangeRate
            : exchangeRate // ignore: cast_nullable_to_non_nullable
                  as double?,
        dutyGhs: freezed == dutyGhs
            ? _value.dutyGhs
            : dutyGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        clearanceGhs: freezed == clearanceGhs
            ? _value.clearanceGhs
            : clearanceGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        repairEstimateGhs: freezed == repairEstimateGhs
            ? _value.repairEstimateGhs
            : repairEstimateGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        serviceFeeGhs: freezed == serviceFeeGhs
            ? _value.serviceFeeGhs
            : serviceFeeGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalLandedGhs: freezed == totalLandedGhs
            ? _value.totalLandedGhs
            : totalLandedGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        agentNote: freezed == agentNote
            ? _value.agentNote
            : agentNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as VehicleOptionStatus,
        confirmedAt: freezed == confirmedAt
            ? _value.confirmedAt
            : confirmedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sentAt: freezed == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$VehicleOptionModelImpl implements _VehicleOptionModel {
  const _$VehicleOptionModelImpl({
    required this.id,
    required this.orderId,
    required this.agentId,
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
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? photoUrlsJson,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
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
    @JsonKey(
      fromJson: _vehicleOptionStatusFromJson,
      toJson: _vehicleOptionStatusToJson,
    )
    this.status = VehicleOptionStatus.draft,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    this.confirmedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) this.sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    this.createdAt,
  }) : _photoUrlsJson = photoUrlsJson;

  factory _$VehicleOptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleOptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String agentId;
  @override
  final String? lotNumber;
  @override
  final String? source;
  // 'copart' | 'iaa'
  @override
  final String? yearMakeModel;
  @override
  final int? year;
  @override
  final String? make;
  @override
  final String? model;
  @override
  final String? trim;
  @override
  final int? mileage;
  @override
  final String? condition;
  @override
  final String? conditionLabel;
  @override
  final String? damageDescription;
  @override
  final String? photoUrl;
  final List<String>? _photoUrlsJson;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get photoUrlsJson {
    final value = _photoUrlsJson;
    if (value == null) return null;
    if (_photoUrlsJson is EqualUnmodifiableListView) return _photoUrlsJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? auctionDate;
  @override
  final String? auctionLocation;
  @override
  final String? vin;
  @override
  final String? colour;
  @override
  final String? engine;
  @override
  final String? transmission;
  @override
  final double? auctionPriceUsd;
  @override
  final double? buyersPremiumPct;
  @override
  final double? buyersPremiumUsd;
  @override
  final double? towingStorageUsd;
  @override
  final double? shippingUsd;
  @override
  final double? marineInsuranceUsd;
  @override
  final double? exchangeRate;
  @override
  final double? dutyGhs;
  @override
  final double? clearanceGhs;
  @override
  final double? repairEstimateGhs;
  @override
  final double? serviceFeeGhs;
  @override
  final double? totalLandedGhs;
  @override
  final String? agentNote;
  @override
  @JsonKey(
    fromJson: _vehicleOptionStatusFromJson,
    toJson: _vehicleOptionStatusToJson,
  )
  final VehicleOptionStatus status;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? confirmedAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? sentAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  @override
  String toString() {
    return 'VehicleOptionModel(id: $id, orderId: $orderId, agentId: $agentId, lotNumber: $lotNumber, source: $source, yearMakeModel: $yearMakeModel, year: $year, make: $make, model: $model, trim: $trim, mileage: $mileage, condition: $condition, conditionLabel: $conditionLabel, damageDescription: $damageDescription, photoUrl: $photoUrl, photoUrlsJson: $photoUrlsJson, auctionDate: $auctionDate, auctionLocation: $auctionLocation, vin: $vin, colour: $colour, engine: $engine, transmission: $transmission, auctionPriceUsd: $auctionPriceUsd, buyersPremiumPct: $buyersPremiumPct, buyersPremiumUsd: $buyersPremiumUsd, towingStorageUsd: $towingStorageUsd, shippingUsd: $shippingUsd, marineInsuranceUsd: $marineInsuranceUsd, exchangeRate: $exchangeRate, dutyGhs: $dutyGhs, clearanceGhs: $clearanceGhs, repairEstimateGhs: $repairEstimateGhs, serviceFeeGhs: $serviceFeeGhs, totalLandedGhs: $totalLandedGhs, agentNote: $agentNote, status: $status, confirmedAt: $confirmedAt, sentAt: $sentAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleOptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.lotNumber, lotNumber) ||
                other.lotNumber == lotNumber) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.yearMakeModel, yearMakeModel) ||
                other.yearMakeModel == yearMakeModel) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.make, make) || other.make == make) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.trim, trim) || other.trim == trim) &&
            (identical(other.mileage, mileage) || other.mileage == mileage) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.conditionLabel, conditionLabel) ||
                other.conditionLabel == conditionLabel) &&
            (identical(other.damageDescription, damageDescription) ||
                other.damageDescription == damageDescription) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            const DeepCollectionEquality().equals(
              other._photoUrlsJson,
              _photoUrlsJson,
            ) &&
            (identical(other.auctionDate, auctionDate) ||
                other.auctionDate == auctionDate) &&
            (identical(other.auctionLocation, auctionLocation) ||
                other.auctionLocation == auctionLocation) &&
            (identical(other.vin, vin) || other.vin == vin) &&
            (identical(other.colour, colour) || other.colour == colour) &&
            (identical(other.engine, engine) || other.engine == engine) &&
            (identical(other.transmission, transmission) ||
                other.transmission == transmission) &&
            (identical(other.auctionPriceUsd, auctionPriceUsd) ||
                other.auctionPriceUsd == auctionPriceUsd) &&
            (identical(other.buyersPremiumPct, buyersPremiumPct) ||
                other.buyersPremiumPct == buyersPremiumPct) &&
            (identical(other.buyersPremiumUsd, buyersPremiumUsd) ||
                other.buyersPremiumUsd == buyersPremiumUsd) &&
            (identical(other.towingStorageUsd, towingStorageUsd) ||
                other.towingStorageUsd == towingStorageUsd) &&
            (identical(other.shippingUsd, shippingUsd) ||
                other.shippingUsd == shippingUsd) &&
            (identical(other.marineInsuranceUsd, marineInsuranceUsd) ||
                other.marineInsuranceUsd == marineInsuranceUsd) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.dutyGhs, dutyGhs) || other.dutyGhs == dutyGhs) &&
            (identical(other.clearanceGhs, clearanceGhs) ||
                other.clearanceGhs == clearanceGhs) &&
            (identical(other.repairEstimateGhs, repairEstimateGhs) ||
                other.repairEstimateGhs == repairEstimateGhs) &&
            (identical(other.serviceFeeGhs, serviceFeeGhs) ||
                other.serviceFeeGhs == serviceFeeGhs) &&
            (identical(other.totalLandedGhs, totalLandedGhs) ||
                other.totalLandedGhs == totalLandedGhs) &&
            (identical(other.agentNote, agentNote) ||
                other.agentNote == agentNote) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    agentId,
    lotNumber,
    source,
    yearMakeModel,
    year,
    make,
    model,
    trim,
    mileage,
    condition,
    conditionLabel,
    damageDescription,
    photoUrl,
    const DeepCollectionEquality().hash(_photoUrlsJson),
    auctionDate,
    auctionLocation,
    vin,
    colour,
    engine,
    transmission,
    auctionPriceUsd,
    buyersPremiumPct,
    buyersPremiumUsd,
    towingStorageUsd,
    shippingUsd,
    marineInsuranceUsd,
    exchangeRate,
    dutyGhs,
    clearanceGhs,
    repairEstimateGhs,
    serviceFeeGhs,
    totalLandedGhs,
    agentNote,
    status,
    confirmedAt,
    sentAt,
    createdAt,
  ]);

  /// Create a copy of VehicleOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VehicleOptionModelImplCopyWith<_$VehicleOptionModelImpl> get copyWith =>
      __$$VehicleOptionModelImplCopyWithImpl<_$VehicleOptionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VehicleOptionModelImplToJson(this);
  }
}

abstract class _VehicleOptionModel implements VehicleOptionModel {
  const factory _VehicleOptionModel({
    required final String id,
    required final String orderId,
    required final String agentId,
    final String? lotNumber,
    final String? source,
    final String? yearMakeModel,
    final int? year,
    final String? make,
    final String? model,
    final String? trim,
    final int? mileage,
    final String? condition,
    final String? conditionLabel,
    final String? damageDescription,
    final String? photoUrl,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? photoUrlsJson,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? auctionDate,
    final String? auctionLocation,
    final String? vin,
    final String? colour,
    final String? engine,
    final String? transmission,
    final double? auctionPriceUsd,
    final double? buyersPremiumPct,
    final double? buyersPremiumUsd,
    final double? towingStorageUsd,
    final double? shippingUsd,
    final double? marineInsuranceUsd,
    final double? exchangeRate,
    final double? dutyGhs,
    final double? clearanceGhs,
    final double? repairEstimateGhs,
    final double? serviceFeeGhs,
    final double? totalLandedGhs,
    final String? agentNote,
    @JsonKey(
      fromJson: _vehicleOptionStatusFromJson,
      toJson: _vehicleOptionStatusToJson,
    )
    final VehicleOptionStatus status,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? confirmedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? createdAt,
  }) = _$VehicleOptionModelImpl;

  factory _VehicleOptionModel.fromJson(Map<String, dynamic> json) =
      _$VehicleOptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get agentId;
  @override
  String? get lotNumber;
  @override
  String? get source; // 'copart' | 'iaa'
  @override
  String? get yearMakeModel;
  @override
  int? get year;
  @override
  String? get make;
  @override
  String? get model;
  @override
  String? get trim;
  @override
  int? get mileage;
  @override
  String? get condition;
  @override
  String? get conditionLabel;
  @override
  String? get damageDescription;
  @override
  String? get photoUrl;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get photoUrlsJson;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get auctionDate;
  @override
  String? get auctionLocation;
  @override
  String? get vin;
  @override
  String? get colour;
  @override
  String? get engine;
  @override
  String? get transmission;
  @override
  double? get auctionPriceUsd;
  @override
  double? get buyersPremiumPct;
  @override
  double? get buyersPremiumUsd;
  @override
  double? get towingStorageUsd;
  @override
  double? get shippingUsd;
  @override
  double? get marineInsuranceUsd;
  @override
  double? get exchangeRate;
  @override
  double? get dutyGhs;
  @override
  double? get clearanceGhs;
  @override
  double? get repairEstimateGhs;
  @override
  double? get serviceFeeGhs;
  @override
  double? get totalLandedGhs;
  @override
  String? get agentNote;
  @override
  @JsonKey(
    fromJson: _vehicleOptionStatusFromJson,
    toJson: _vehicleOptionStatusToJson,
  )
  VehicleOptionStatus get status;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get confirmedAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get sentAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get createdAt;

  /// Create a copy of VehicleOptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VehicleOptionModelImplCopyWith<_$VehicleOptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
