// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeliveryModel _$DeliveryModelFromJson(Map<String, dynamic> json) {
  return _DeliveryModel.fromJson(json);
}

/// @nodoc
mixin _$DeliveryModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get deliveryAddress => throw _privateConstructorUsedError;
  String? get deliveryCity => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get locationLabel => throw _privateConstructorUsedError;
  String? get locationSource => throw _privateConstructorUsedError;
  String? get recipientName => throw _privateConstructorUsedError;
  String? get recipientPhone => throw _privateConstructorUsedError;
  DateTime? get scheduledDate => throw _privateConstructorUsedError;
  DateTime? get actualDeliveryDate => throw _privateConstructorUsedError;
  String? get deliveredBy => throw _privateConstructorUsedError;
  String? get proofOfDeliveryUrl => throw _privateConstructorUsedError;
  bool get buyerConfirmed => throw _privateConstructorUsedError;
  DateTime? get buyerConfirmedAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get paymentConfirmed => throw _privateConstructorUsedError;
  DateTime? get paymentConfirmedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DeliveryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryModelCopyWith<DeliveryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryModelCopyWith<$Res> {
  factory $DeliveryModelCopyWith(
    DeliveryModel value,
    $Res Function(DeliveryModel) then,
  ) = _$DeliveryModelCopyWithImpl<$Res, DeliveryModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
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
    bool buyerConfirmed,
    DateTime? buyerConfirmedAt,
    String status,
    bool paymentConfirmed,
    DateTime? paymentConfirmedAt,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$DeliveryModelCopyWithImpl<$Res, $Val extends DeliveryModel>
    implements $DeliveryModelCopyWith<$Res> {
  _$DeliveryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? deliveryAddress = freezed,
    Object? deliveryCity = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationLabel = freezed,
    Object? locationSource = freezed,
    Object? recipientName = freezed,
    Object? recipientPhone = freezed,
    Object? scheduledDate = freezed,
    Object? actualDeliveryDate = freezed,
    Object? deliveredBy = freezed,
    Object? proofOfDeliveryUrl = freezed,
    Object? buyerConfirmed = null,
    Object? buyerConfirmedAt = freezed,
    Object? status = null,
    Object? paymentConfirmed = null,
    Object? paymentConfirmedAt = freezed,
    Object? notes = freezed,
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
            deliveryAddress: freezed == deliveryAddress
                ? _value.deliveryAddress
                : deliveryAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            deliveryCity: freezed == deliveryCity
                ? _value.deliveryCity
                : deliveryCity // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            locationLabel: freezed == locationLabel
                ? _value.locationLabel
                : locationLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            locationSource: freezed == locationSource
                ? _value.locationSource
                : locationSource // ignore: cast_nullable_to_non_nullable
                      as String?,
            recipientName: freezed == recipientName
                ? _value.recipientName
                : recipientName // ignore: cast_nullable_to_non_nullable
                      as String?,
            recipientPhone: freezed == recipientPhone
                ? _value.recipientPhone
                : recipientPhone // ignore: cast_nullable_to_non_nullable
                      as String?,
            scheduledDate: freezed == scheduledDate
                ? _value.scheduledDate
                : scheduledDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actualDeliveryDate: freezed == actualDeliveryDate
                ? _value.actualDeliveryDate
                : actualDeliveryDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredBy: freezed == deliveredBy
                ? _value.deliveredBy
                : deliveredBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            proofOfDeliveryUrl: freezed == proofOfDeliveryUrl
                ? _value.proofOfDeliveryUrl
                : proofOfDeliveryUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            buyerConfirmed: null == buyerConfirmed
                ? _value.buyerConfirmed
                : buyerConfirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
            buyerConfirmedAt: freezed == buyerConfirmedAt
                ? _value.buyerConfirmedAt
                : buyerConfirmedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentConfirmed: null == paymentConfirmed
                ? _value.paymentConfirmed
                : paymentConfirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
            paymentConfirmedAt: freezed == paymentConfirmedAt
                ? _value.paymentConfirmedAt
                : paymentConfirmedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DeliveryModelImplCopyWith<$Res>
    implements $DeliveryModelCopyWith<$Res> {
  factory _$$DeliveryModelImplCopyWith(
    _$DeliveryModelImpl value,
    $Res Function(_$DeliveryModelImpl) then,
  ) = __$$DeliveryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
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
    bool buyerConfirmed,
    DateTime? buyerConfirmedAt,
    String status,
    bool paymentConfirmed,
    DateTime? paymentConfirmedAt,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$DeliveryModelImplCopyWithImpl<$Res>
    extends _$DeliveryModelCopyWithImpl<$Res, _$DeliveryModelImpl>
    implements _$$DeliveryModelImplCopyWith<$Res> {
  __$$DeliveryModelImplCopyWithImpl(
    _$DeliveryModelImpl _value,
    $Res Function(_$DeliveryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? deliveryAddress = freezed,
    Object? deliveryCity = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationLabel = freezed,
    Object? locationSource = freezed,
    Object? recipientName = freezed,
    Object? recipientPhone = freezed,
    Object? scheduledDate = freezed,
    Object? actualDeliveryDate = freezed,
    Object? deliveredBy = freezed,
    Object? proofOfDeliveryUrl = freezed,
    Object? buyerConfirmed = null,
    Object? buyerConfirmedAt = freezed,
    Object? status = null,
    Object? paymentConfirmed = null,
    Object? paymentConfirmedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DeliveryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        deliveryAddress: freezed == deliveryAddress
            ? _value.deliveryAddress
            : deliveryAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        deliveryCity: freezed == deliveryCity
            ? _value.deliveryCity
            : deliveryCity // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        locationLabel: freezed == locationLabel
            ? _value.locationLabel
            : locationLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        locationSource: freezed == locationSource
            ? _value.locationSource
            : locationSource // ignore: cast_nullable_to_non_nullable
                  as String?,
        recipientName: freezed == recipientName
            ? _value.recipientName
            : recipientName // ignore: cast_nullable_to_non_nullable
                  as String?,
        recipientPhone: freezed == recipientPhone
            ? _value.recipientPhone
            : recipientPhone // ignore: cast_nullable_to_non_nullable
                  as String?,
        scheduledDate: freezed == scheduledDate
            ? _value.scheduledDate
            : scheduledDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actualDeliveryDate: freezed == actualDeliveryDate
            ? _value.actualDeliveryDate
            : actualDeliveryDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredBy: freezed == deliveredBy
            ? _value.deliveredBy
            : deliveredBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        proofOfDeliveryUrl: freezed == proofOfDeliveryUrl
            ? _value.proofOfDeliveryUrl
            : proofOfDeliveryUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        buyerConfirmed: null == buyerConfirmed
            ? _value.buyerConfirmed
            : buyerConfirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
        buyerConfirmedAt: freezed == buyerConfirmedAt
            ? _value.buyerConfirmedAt
            : buyerConfirmedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentConfirmed: null == paymentConfirmed
            ? _value.paymentConfirmed
            : paymentConfirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
        paymentConfirmedAt: freezed == paymentConfirmedAt
            ? _value.paymentConfirmedAt
            : paymentConfirmedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
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
class _$DeliveryModelImpl implements _DeliveryModel {
  const _$DeliveryModelImpl({
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
    this.scheduledDate,
    this.actualDeliveryDate,
    this.deliveredBy,
    this.proofOfDeliveryUrl,
    this.buyerConfirmed = false,
    this.buyerConfirmedAt,
    this.status = 'pending_payment',
    this.paymentConfirmed = false,
    this.paymentConfirmedAt,
    this.notes,
    this.createdAt,
  });

  factory _$DeliveryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? deliveryAddress;
  @override
  final String? deliveryCity;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? locationLabel;
  @override
  final String? locationSource;
  @override
  final String? recipientName;
  @override
  final String? recipientPhone;
  @override
  final DateTime? scheduledDate;
  @override
  final DateTime? actualDeliveryDate;
  @override
  final String? deliveredBy;
  @override
  final String? proofOfDeliveryUrl;
  @override
  @JsonKey()
  final bool buyerConfirmed;
  @override
  final DateTime? buyerConfirmedAt;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool paymentConfirmed;
  @override
  final DateTime? paymentConfirmedAt;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'DeliveryModel(id: $id, orderId: $orderId, deliveryAddress: $deliveryAddress, deliveryCity: $deliveryCity, latitude: $latitude, longitude: $longitude, locationLabel: $locationLabel, locationSource: $locationSource, recipientName: $recipientName, recipientPhone: $recipientPhone, scheduledDate: $scheduledDate, actualDeliveryDate: $actualDeliveryDate, deliveredBy: $deliveredBy, proofOfDeliveryUrl: $proofOfDeliveryUrl, buyerConfirmed: $buyerConfirmed, buyerConfirmedAt: $buyerConfirmedAt, status: $status, paymentConfirmed: $paymentConfirmed, paymentConfirmedAt: $paymentConfirmedAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.deliveryCity, deliveryCity) ||
                other.deliveryCity == deliveryCity) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationLabel, locationLabel) ||
                other.locationLabel == locationLabel) &&
            (identical(other.locationSource, locationSource) ||
                other.locationSource == locationSource) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName) &&
            (identical(other.recipientPhone, recipientPhone) ||
                other.recipientPhone == recipientPhone) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.actualDeliveryDate, actualDeliveryDate) ||
                other.actualDeliveryDate == actualDeliveryDate) &&
            (identical(other.deliveredBy, deliveredBy) ||
                other.deliveredBy == deliveredBy) &&
            (identical(other.proofOfDeliveryUrl, proofOfDeliveryUrl) ||
                other.proofOfDeliveryUrl == proofOfDeliveryUrl) &&
            (identical(other.buyerConfirmed, buyerConfirmed) ||
                other.buyerConfirmed == buyerConfirmed) &&
            (identical(other.buyerConfirmedAt, buyerConfirmedAt) ||
                other.buyerConfirmedAt == buyerConfirmedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.paymentConfirmed, paymentConfirmed) ||
                other.paymentConfirmed == paymentConfirmed) &&
            (identical(other.paymentConfirmedAt, paymentConfirmedAt) ||
                other.paymentConfirmedAt == paymentConfirmedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    deliveryAddress,
    deliveryCity,
    latitude,
    longitude,
    locationLabel,
    locationSource,
    recipientName,
    recipientPhone,
    scheduledDate,
    actualDeliveryDate,
    deliveredBy,
    proofOfDeliveryUrl,
    buyerConfirmed,
    buyerConfirmedAt,
    status,
    paymentConfirmed,
    paymentConfirmedAt,
    notes,
    createdAt,
  ]);

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryModelImplCopyWith<_$DeliveryModelImpl> get copyWith =>
      __$$DeliveryModelImplCopyWithImpl<_$DeliveryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryModelImplToJson(this);
  }
}

abstract class _DeliveryModel implements DeliveryModel {
  const factory _DeliveryModel({
    required final String id,
    required final String orderId,
    final String? deliveryAddress,
    final String? deliveryCity,
    final double? latitude,
    final double? longitude,
    final String? locationLabel,
    final String? locationSource,
    final String? recipientName,
    final String? recipientPhone,
    final DateTime? scheduledDate,
    final DateTime? actualDeliveryDate,
    final String? deliveredBy,
    final String? proofOfDeliveryUrl,
    final bool buyerConfirmed,
    final DateTime? buyerConfirmedAt,
    final String status,
    final bool paymentConfirmed,
    final DateTime? paymentConfirmedAt,
    final String? notes,
    final DateTime? createdAt,
  }) = _$DeliveryModelImpl;

  factory _DeliveryModel.fromJson(Map<String, dynamic> json) =
      _$DeliveryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get deliveryAddress;
  @override
  String? get deliveryCity;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get locationLabel;
  @override
  String? get locationSource;
  @override
  String? get recipientName;
  @override
  String? get recipientPhone;
  @override
  DateTime? get scheduledDate;
  @override
  DateTime? get actualDeliveryDate;
  @override
  String? get deliveredBy;
  @override
  String? get proofOfDeliveryUrl;
  @override
  bool get buyerConfirmed;
  @override
  DateTime? get buyerConfirmedAt;
  @override
  String get status;
  @override
  bool get paymentConfirmed;
  @override
  DateTime? get paymentConfirmedAt;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;

  /// Create a copy of DeliveryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryModelImplCopyWith<_$DeliveryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
