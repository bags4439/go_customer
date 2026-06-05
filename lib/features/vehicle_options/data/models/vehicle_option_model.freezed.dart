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
  String get listingUrl => throw _privateConstructorUsedError;
  String get listingTitle => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
  ListingSource? get source => throw _privateConstructorUsedError;
  String? get agentNote => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  VehicleOptionStatus get status => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
  BuyerVehicleResponse get buyerResponse => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get sentAt => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get buyerRespondedAt => throw _privateConstructorUsedError;
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
    String listingUrl,
    String listingTitle,
    @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
    ListingSource? source,
    String? agentNote,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    VehicleOptionStatus status,
    @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
    BuyerVehicleResponse buyerResponse,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? buyerRespondedAt,
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
    Object? listingUrl = null,
    Object? listingTitle = null,
    Object? source = freezed,
    Object? agentNote = freezed,
    Object? status = null,
    Object? buyerResponse = null,
    Object? sentAt = freezed,
    Object? buyerRespondedAt = freezed,
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
            listingUrl: null == listingUrl
                ? _value.listingUrl
                : listingUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            listingTitle: null == listingTitle
                ? _value.listingTitle
                : listingTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            source: freezed == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as ListingSource?,
            agentNote: freezed == agentNote
                ? _value.agentNote
                : agentNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as VehicleOptionStatus,
            buyerResponse: null == buyerResponse
                ? _value.buyerResponse
                : buyerResponse // ignore: cast_nullable_to_non_nullable
                      as BuyerVehicleResponse,
            sentAt: freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            buyerRespondedAt: freezed == buyerRespondedAt
                ? _value.buyerRespondedAt
                : buyerRespondedAt // ignore: cast_nullable_to_non_nullable
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
    String listingUrl,
    String listingTitle,
    @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
    ListingSource? source,
    String? agentNote,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    VehicleOptionStatus status,
    @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
    BuyerVehicleResponse buyerResponse,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? buyerRespondedAt,
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
    Object? listingUrl = null,
    Object? listingTitle = null,
    Object? source = freezed,
    Object? agentNote = freezed,
    Object? status = null,
    Object? buyerResponse = null,
    Object? sentAt = freezed,
    Object? buyerRespondedAt = freezed,
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
        listingUrl: null == listingUrl
            ? _value.listingUrl
            : listingUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        listingTitle: null == listingTitle
            ? _value.listingTitle
            : listingTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        source: freezed == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as ListingSource?,
        agentNote: freezed == agentNote
            ? _value.agentNote
            : agentNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as VehicleOptionStatus,
        buyerResponse: null == buyerResponse
            ? _value.buyerResponse
            : buyerResponse // ignore: cast_nullable_to_non_nullable
                  as BuyerVehicleResponse,
        sentAt: freezed == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        buyerRespondedAt: freezed == buyerRespondedAt
            ? _value.buyerRespondedAt
            : buyerRespondedAt // ignore: cast_nullable_to_non_nullable
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
class _$VehicleOptionModelImpl extends _VehicleOptionModel {
  const _$VehicleOptionModelImpl({
    required this.id,
    required this.orderId,
    required this.agentId,
    this.listingUrl = '',
    this.listingTitle = '',
    @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson) this.source,
    this.agentNote,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    this.status = VehicleOptionStatus.draft,
    @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
    this.buyerResponse = BuyerVehicleResponse.pending,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) this.sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    this.buyerRespondedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    this.createdAt,
  }) : super._();

  factory _$VehicleOptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VehicleOptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String agentId;
  @override
  @JsonKey()
  final String listingUrl;
  @override
  @JsonKey()
  final String listingTitle;
  @override
  @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
  final ListingSource? source;
  @override
  final String? agentNote;
  @override
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final VehicleOptionStatus status;
  @override
  @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
  final BuyerVehicleResponse buyerResponse;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? sentAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? buyerRespondedAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  @override
  String toString() {
    return 'VehicleOptionModel(id: $id, orderId: $orderId, agentId: $agentId, listingUrl: $listingUrl, listingTitle: $listingTitle, source: $source, agentNote: $agentNote, status: $status, buyerResponse: $buyerResponse, sentAt: $sentAt, buyerRespondedAt: $buyerRespondedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VehicleOptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.listingUrl, listingUrl) ||
                other.listingUrl == listingUrl) &&
            (identical(other.listingTitle, listingTitle) ||
                other.listingTitle == listingTitle) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.agentNote, agentNote) ||
                other.agentNote == agentNote) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.buyerResponse, buyerResponse) ||
                other.buyerResponse == buyerResponse) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.buyerRespondedAt, buyerRespondedAt) ||
                other.buyerRespondedAt == buyerRespondedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    agentId,
    listingUrl,
    listingTitle,
    source,
    agentNote,
    status,
    buyerResponse,
    sentAt,
    buyerRespondedAt,
    createdAt,
  );

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

abstract class _VehicleOptionModel extends VehicleOptionModel {
  const factory _VehicleOptionModel({
    required final String id,
    required final String orderId,
    required final String agentId,
    final String listingUrl,
    final String listingTitle,
    @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
    final ListingSource? source,
    final String? agentNote,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    final VehicleOptionStatus status,
    @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
    final BuyerVehicleResponse buyerResponse,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? sentAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? buyerRespondedAt,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? createdAt,
  }) = _$VehicleOptionModelImpl;
  const _VehicleOptionModel._() : super._();

  factory _VehicleOptionModel.fromJson(Map<String, dynamic> json) =
      _$VehicleOptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get agentId;
  @override
  String get listingUrl;
  @override
  String get listingTitle;
  @override
  @JsonKey(fromJson: _sourceFromJson, toJson: _sourceToJson)
  ListingSource? get source;
  @override
  String? get agentNote;
  @override
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  VehicleOptionStatus get status;
  @override
  @JsonKey(fromJson: _buyerResponseFromJson, toJson: _buyerResponseToJson)
  BuyerVehicleResponse get buyerResponse;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get sentAt;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get buyerRespondedAt;
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
