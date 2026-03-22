// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shipping_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ShippingModel _$ShippingModelFromJson(Map<String, dynamic> json) {
  return _ShippingModel.fromJson(json);
}

/// @nodoc
mixin _$ShippingModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get vesselName => throw _privateConstructorUsedError;
  String? get shippingLine => throw _privateConstructorUsedError;
  String? get blNumber => throw _privateConstructorUsedError;
  String? get containerNumber => throw _privateConstructorUsedError;
  String? get originPort => throw _privateConstructorUsedError;
  String get destinationPort => throw _privateConstructorUsedError;
  String? get trackingUrl => throw _privateConstructorUsedError;
  DateTime? get estimatedDeparture => throw _privateConstructorUsedError;
  DateTime? get actualDeparture => throw _privateConstructorUsedError;
  DateTime? get estimatedArrival => throw _privateConstructorUsedError;
  DateTime? get actualArrival => throw _privateConstructorUsedError;
  double? get journeyProgressPct => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
  ShippingStatus get status => throw _privateConstructorUsedError;
  String? get agentNotes => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ShippingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingModelCopyWith<ShippingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingModelCopyWith<$Res> {
  factory $ShippingModelCopyWith(
    ShippingModel value,
    $Res Function(ShippingModel) then,
  ) = _$ShippingModelCopyWithImpl<$Res, ShippingModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String? vesselName,
    String? shippingLine,
    String? blNumber,
    String? containerNumber,
    String? originPort,
    String destinationPort,
    String? trackingUrl,
    DateTime? estimatedDeparture,
    DateTime? actualDeparture,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    double? journeyProgressPct,
    @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
    ShippingStatus status,
    String? agentNotes,
    DateTime? updatedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$ShippingModelCopyWithImpl<$Res, $Val extends ShippingModel>
    implements $ShippingModelCopyWith<$Res> {
  _$ShippingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vesselName = freezed,
    Object? shippingLine = freezed,
    Object? blNumber = freezed,
    Object? containerNumber = freezed,
    Object? originPort = freezed,
    Object? destinationPort = null,
    Object? trackingUrl = freezed,
    Object? estimatedDeparture = freezed,
    Object? actualDeparture = freezed,
    Object? estimatedArrival = freezed,
    Object? actualArrival = freezed,
    Object? journeyProgressPct = freezed,
    Object? status = null,
    Object? agentNotes = freezed,
    Object? updatedAt = freezed,
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
            vesselName: freezed == vesselName
                ? _value.vesselName
                : vesselName // ignore: cast_nullable_to_non_nullable
                      as String?,
            shippingLine: freezed == shippingLine
                ? _value.shippingLine
                : shippingLine // ignore: cast_nullable_to_non_nullable
                      as String?,
            blNumber: freezed == blNumber
                ? _value.blNumber
                : blNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            containerNumber: freezed == containerNumber
                ? _value.containerNumber
                : containerNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            originPort: freezed == originPort
                ? _value.originPort
                : originPort // ignore: cast_nullable_to_non_nullable
                      as String?,
            destinationPort: null == destinationPort
                ? _value.destinationPort
                : destinationPort // ignore: cast_nullable_to_non_nullable
                      as String,
            trackingUrl: freezed == trackingUrl
                ? _value.trackingUrl
                : trackingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            estimatedDeparture: freezed == estimatedDeparture
                ? _value.estimatedDeparture
                : estimatedDeparture // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actualDeparture: freezed == actualDeparture
                ? _value.actualDeparture
                : actualDeparture // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            estimatedArrival: freezed == estimatedArrival
                ? _value.estimatedArrival
                : estimatedArrival // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actualArrival: freezed == actualArrival
                ? _value.actualArrival
                : actualArrival // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            journeyProgressPct: freezed == journeyProgressPct
                ? _value.journeyProgressPct
                : journeyProgressPct // ignore: cast_nullable_to_non_nullable
                      as double?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ShippingStatus,
            agentNotes: freezed == agentNotes
                ? _value.agentNotes
                : agentNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ShippingModelImplCopyWith<$Res>
    implements $ShippingModelCopyWith<$Res> {
  factory _$$ShippingModelImplCopyWith(
    _$ShippingModelImpl value,
    $Res Function(_$ShippingModelImpl) then,
  ) = __$$ShippingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String? vesselName,
    String? shippingLine,
    String? blNumber,
    String? containerNumber,
    String? originPort,
    String destinationPort,
    String? trackingUrl,
    DateTime? estimatedDeparture,
    DateTime? actualDeparture,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    double? journeyProgressPct,
    @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
    ShippingStatus status,
    String? agentNotes,
    DateTime? updatedAt,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$ShippingModelImplCopyWithImpl<$Res>
    extends _$ShippingModelCopyWithImpl<$Res, _$ShippingModelImpl>
    implements _$$ShippingModelImplCopyWith<$Res> {
  __$$ShippingModelImplCopyWithImpl(
    _$ShippingModelImpl _value,
    $Res Function(_$ShippingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vesselName = freezed,
    Object? shippingLine = freezed,
    Object? blNumber = freezed,
    Object? containerNumber = freezed,
    Object? originPort = freezed,
    Object? destinationPort = null,
    Object? trackingUrl = freezed,
    Object? estimatedDeparture = freezed,
    Object? actualDeparture = freezed,
    Object? estimatedArrival = freezed,
    Object? actualArrival = freezed,
    Object? journeyProgressPct = freezed,
    Object? status = null,
    Object? agentNotes = freezed,
    Object? updatedAt = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ShippingModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        vesselName: freezed == vesselName
            ? _value.vesselName
            : vesselName // ignore: cast_nullable_to_non_nullable
                  as String?,
        shippingLine: freezed == shippingLine
            ? _value.shippingLine
            : shippingLine // ignore: cast_nullable_to_non_nullable
                  as String?,
        blNumber: freezed == blNumber
            ? _value.blNumber
            : blNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        containerNumber: freezed == containerNumber
            ? _value.containerNumber
            : containerNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        originPort: freezed == originPort
            ? _value.originPort
            : originPort // ignore: cast_nullable_to_non_nullable
                  as String?,
        destinationPort: null == destinationPort
            ? _value.destinationPort
            : destinationPort // ignore: cast_nullable_to_non_nullable
                  as String,
        trackingUrl: freezed == trackingUrl
            ? _value.trackingUrl
            : trackingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        estimatedDeparture: freezed == estimatedDeparture
            ? _value.estimatedDeparture
            : estimatedDeparture // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actualDeparture: freezed == actualDeparture
            ? _value.actualDeparture
            : actualDeparture // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        estimatedArrival: freezed == estimatedArrival
            ? _value.estimatedArrival
            : estimatedArrival // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actualArrival: freezed == actualArrival
            ? _value.actualArrival
            : actualArrival // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        journeyProgressPct: freezed == journeyProgressPct
            ? _value.journeyProgressPct
            : journeyProgressPct // ignore: cast_nullable_to_non_nullable
                  as double?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ShippingStatus,
        agentNotes: freezed == agentNotes
            ? _value.agentNotes
            : agentNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
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
class _$ShippingModelImpl implements _ShippingModel {
  const _$ShippingModelImpl({
    required this.id,
    required this.orderId,
    this.vesselName,
    this.shippingLine,
    this.blNumber,
    this.containerNumber,
    this.originPort,
    this.destinationPort = 'Tema, Ghana',
    this.trackingUrl,
    this.estimatedDeparture,
    this.actualDeparture,
    this.estimatedArrival,
    this.actualArrival,
    this.journeyProgressPct,
    @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
    this.status = ShippingStatus.pending,
    this.agentNotes,
    this.updatedAt,
    this.createdAt,
  });

  factory _$ShippingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? vesselName;
  @override
  final String? shippingLine;
  @override
  final String? blNumber;
  @override
  final String? containerNumber;
  @override
  final String? originPort;
  @override
  @JsonKey()
  final String destinationPort;
  @override
  final String? trackingUrl;
  @override
  final DateTime? estimatedDeparture;
  @override
  final DateTime? actualDeparture;
  @override
  final DateTime? estimatedArrival;
  @override
  final DateTime? actualArrival;
  @override
  final double? journeyProgressPct;
  @override
  @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
  final ShippingStatus status;
  @override
  final String? agentNotes;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ShippingModel(id: $id, orderId: $orderId, vesselName: $vesselName, shippingLine: $shippingLine, blNumber: $blNumber, containerNumber: $containerNumber, originPort: $originPort, destinationPort: $destinationPort, trackingUrl: $trackingUrl, estimatedDeparture: $estimatedDeparture, actualDeparture: $actualDeparture, estimatedArrival: $estimatedArrival, actualArrival: $actualArrival, journeyProgressPct: $journeyProgressPct, status: $status, agentNotes: $agentNotes, updatedAt: $updatedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.vesselName, vesselName) ||
                other.vesselName == vesselName) &&
            (identical(other.shippingLine, shippingLine) ||
                other.shippingLine == shippingLine) &&
            (identical(other.blNumber, blNumber) ||
                other.blNumber == blNumber) &&
            (identical(other.containerNumber, containerNumber) ||
                other.containerNumber == containerNumber) &&
            (identical(other.originPort, originPort) ||
                other.originPort == originPort) &&
            (identical(other.destinationPort, destinationPort) ||
                other.destinationPort == destinationPort) &&
            (identical(other.trackingUrl, trackingUrl) ||
                other.trackingUrl == trackingUrl) &&
            (identical(other.estimatedDeparture, estimatedDeparture) ||
                other.estimatedDeparture == estimatedDeparture) &&
            (identical(other.actualDeparture, actualDeparture) ||
                other.actualDeparture == actualDeparture) &&
            (identical(other.estimatedArrival, estimatedArrival) ||
                other.estimatedArrival == estimatedArrival) &&
            (identical(other.actualArrival, actualArrival) ||
                other.actualArrival == actualArrival) &&
            (identical(other.journeyProgressPct, journeyProgressPct) ||
                other.journeyProgressPct == journeyProgressPct) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.agentNotes, agentNotes) ||
                other.agentNotes == agentNotes) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    vesselName,
    shippingLine,
    blNumber,
    containerNumber,
    originPort,
    destinationPort,
    trackingUrl,
    estimatedDeparture,
    actualDeparture,
    estimatedArrival,
    actualArrival,
    journeyProgressPct,
    status,
    agentNotes,
    updatedAt,
    createdAt,
  );

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingModelImplCopyWith<_$ShippingModelImpl> get copyWith =>
      __$$ShippingModelImplCopyWithImpl<_$ShippingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingModelImplToJson(this);
  }
}

abstract class _ShippingModel implements ShippingModel {
  const factory _ShippingModel({
    required final String id,
    required final String orderId,
    final String? vesselName,
    final String? shippingLine,
    final String? blNumber,
    final String? containerNumber,
    final String? originPort,
    final String destinationPort,
    final String? trackingUrl,
    final DateTime? estimatedDeparture,
    final DateTime? actualDeparture,
    final DateTime? estimatedArrival,
    final DateTime? actualArrival,
    final double? journeyProgressPct,
    @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
    final ShippingStatus status,
    final String? agentNotes,
    final DateTime? updatedAt,
    final DateTime? createdAt,
  }) = _$ShippingModelImpl;

  factory _ShippingModel.fromJson(Map<String, dynamic> json) =
      _$ShippingModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get vesselName;
  @override
  String? get shippingLine;
  @override
  String? get blNumber;
  @override
  String? get containerNumber;
  @override
  String? get originPort;
  @override
  String get destinationPort;
  @override
  String? get trackingUrl;
  @override
  DateTime? get estimatedDeparture;
  @override
  DateTime? get actualDeparture;
  @override
  DateTime? get estimatedArrival;
  @override
  DateTime? get actualArrival;
  @override
  double? get journeyProgressPct;
  @override
  @JsonKey(fromJson: _shippingStatusFromJson, toJson: _shippingStatusToJson)
  ShippingStatus get status;
  @override
  String? get agentNotes;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get createdAt;

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingModelImplCopyWith<_$ShippingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
