// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bid_outcome_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BidOutcomeModel _$BidOutcomeModelFromJson(Map<String, dynamic> json) {
  return _BidOutcomeModel.fromJson(json);
}

/// @nodoc
mixin _$BidOutcomeModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get vehicleOptionId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  String get outcome => throw _privateConstructorUsedError; // 'won' | 'lost'
  double? get maxBidUsd => throw _privateConstructorUsedError;
  double? get finalPriceUsd => throw _privateConstructorUsedError;
  double? get savingUsd => throw _privateConstructorUsedError;
  double? get finalPriceGhs => throw _privateConstructorUsedError;
  String? get lossReason => throw _privateConstructorUsedError;
  double? get lossPriceUsd => throw _privateConstructorUsedError;
  String? get nextStep => throw _privateConstructorUsedError;
  String? get noteToBuyer => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
  DateTime? get bidDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
  DateTime? get loggedAt => throw _privateConstructorUsedError;

  /// Serializes this BidOutcomeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BidOutcomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BidOutcomeModelCopyWith<BidOutcomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BidOutcomeModelCopyWith<$Res> {
  factory $BidOutcomeModelCopyWith(
    BidOutcomeModel value,
    $Res Function(BidOutcomeModel) then,
  ) = _$BidOutcomeModelCopyWithImpl<$Res, BidOutcomeModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String? vehicleOptionId,
    String agentId,
    String outcome,
    double? maxBidUsd,
    double? finalPriceUsd,
    double? savingUsd,
    double? finalPriceGhs,
    String? lossReason,
    double? lossPriceUsd,
    String? nextStep,
    String? noteToBuyer,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    DateTime? bidDate,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    DateTime? loggedAt,
  });
}

/// @nodoc
class _$BidOutcomeModelCopyWithImpl<$Res, $Val extends BidOutcomeModel>
    implements $BidOutcomeModelCopyWith<$Res> {
  _$BidOutcomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BidOutcomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vehicleOptionId = freezed,
    Object? agentId = null,
    Object? outcome = null,
    Object? maxBidUsd = freezed,
    Object? finalPriceUsd = freezed,
    Object? savingUsd = freezed,
    Object? finalPriceGhs = freezed,
    Object? lossReason = freezed,
    Object? lossPriceUsd = freezed,
    Object? nextStep = freezed,
    Object? noteToBuyer = freezed,
    Object? bidDate = freezed,
    Object? loggedAt = freezed,
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
            vehicleOptionId: freezed == vehicleOptionId
                ? _value.vehicleOptionId
                : vehicleOptionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            agentId: null == agentId
                ? _value.agentId
                : agentId // ignore: cast_nullable_to_non_nullable
                      as String,
            outcome: null == outcome
                ? _value.outcome
                : outcome // ignore: cast_nullable_to_non_nullable
                      as String,
            maxBidUsd: freezed == maxBidUsd
                ? _value.maxBidUsd
                : maxBidUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalPriceUsd: freezed == finalPriceUsd
                ? _value.finalPriceUsd
                : finalPriceUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            savingUsd: freezed == savingUsd
                ? _value.savingUsd
                : savingUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalPriceGhs: freezed == finalPriceGhs
                ? _value.finalPriceGhs
                : finalPriceGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            lossReason: freezed == lossReason
                ? _value.lossReason
                : lossReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            lossPriceUsd: freezed == lossPriceUsd
                ? _value.lossPriceUsd
                : lossPriceUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            nextStep: freezed == nextStep
                ? _value.nextStep
                : nextStep // ignore: cast_nullable_to_non_nullable
                      as String?,
            noteToBuyer: freezed == noteToBuyer
                ? _value.noteToBuyer
                : noteToBuyer // ignore: cast_nullable_to_non_nullable
                      as String?,
            bidDate: freezed == bidDate
                ? _value.bidDate
                : bidDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            loggedAt: freezed == loggedAt
                ? _value.loggedAt
                : loggedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BidOutcomeModelImplCopyWith<$Res>
    implements $BidOutcomeModelCopyWith<$Res> {
  factory _$$BidOutcomeModelImplCopyWith(
    _$BidOutcomeModelImpl value,
    $Res Function(_$BidOutcomeModelImpl) then,
  ) = __$$BidOutcomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String? vehicleOptionId,
    String agentId,
    String outcome,
    double? maxBidUsd,
    double? finalPriceUsd,
    double? savingUsd,
    double? finalPriceGhs,
    String? lossReason,
    double? lossPriceUsd,
    String? nextStep,
    String? noteToBuyer,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    DateTime? bidDate,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    DateTime? loggedAt,
  });
}

/// @nodoc
class __$$BidOutcomeModelImplCopyWithImpl<$Res>
    extends _$BidOutcomeModelCopyWithImpl<$Res, _$BidOutcomeModelImpl>
    implements _$$BidOutcomeModelImplCopyWith<$Res> {
  __$$BidOutcomeModelImplCopyWithImpl(
    _$BidOutcomeModelImpl _value,
    $Res Function(_$BidOutcomeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BidOutcomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? vehicleOptionId = freezed,
    Object? agentId = null,
    Object? outcome = null,
    Object? maxBidUsd = freezed,
    Object? finalPriceUsd = freezed,
    Object? savingUsd = freezed,
    Object? finalPriceGhs = freezed,
    Object? lossReason = freezed,
    Object? lossPriceUsd = freezed,
    Object? nextStep = freezed,
    Object? noteToBuyer = freezed,
    Object? bidDate = freezed,
    Object? loggedAt = freezed,
  }) {
    return _then(
      _$BidOutcomeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        vehicleOptionId: freezed == vehicleOptionId
            ? _value.vehicleOptionId
            : vehicleOptionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        agentId: null == agentId
            ? _value.agentId
            : agentId // ignore: cast_nullable_to_non_nullable
                  as String,
        outcome: null == outcome
            ? _value.outcome
            : outcome // ignore: cast_nullable_to_non_nullable
                  as String,
        maxBidUsd: freezed == maxBidUsd
            ? _value.maxBidUsd
            : maxBidUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalPriceUsd: freezed == finalPriceUsd
            ? _value.finalPriceUsd
            : finalPriceUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        savingUsd: freezed == savingUsd
            ? _value.savingUsd
            : savingUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalPriceGhs: freezed == finalPriceGhs
            ? _value.finalPriceGhs
            : finalPriceGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        lossReason: freezed == lossReason
            ? _value.lossReason
            : lossReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        lossPriceUsd: freezed == lossPriceUsd
            ? _value.lossPriceUsd
            : lossPriceUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        nextStep: freezed == nextStep
            ? _value.nextStep
            : nextStep // ignore: cast_nullable_to_non_nullable
                  as String?,
        noteToBuyer: freezed == noteToBuyer
            ? _value.noteToBuyer
            : noteToBuyer // ignore: cast_nullable_to_non_nullable
                  as String?,
        bidDate: freezed == bidDate
            ? _value.bidDate
            : bidDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        loggedAt: freezed == loggedAt
            ? _value.loggedAt
            : loggedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BidOutcomeModelImpl implements _BidOutcomeModel {
  const _$BidOutcomeModelImpl({
    required this.id,
    required this.orderId,
    this.vehicleOptionId,
    required this.agentId,
    required this.outcome,
    this.maxBidUsd,
    this.finalPriceUsd,
    this.savingUsd,
    this.finalPriceGhs,
    this.lossReason,
    this.lossPriceUsd,
    this.nextStep,
    this.noteToBuyer,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    this.bidDate,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    this.loggedAt,
  });

  factory _$BidOutcomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BidOutcomeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? vehicleOptionId;
  @override
  final String agentId;
  @override
  final String outcome;
  // 'won' | 'lost'
  @override
  final double? maxBidUsd;
  @override
  final double? finalPriceUsd;
  @override
  final double? savingUsd;
  @override
  final double? finalPriceGhs;
  @override
  final String? lossReason;
  @override
  final double? lossPriceUsd;
  @override
  final String? nextStep;
  @override
  final String? noteToBuyer;
  @override
  @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
  final DateTime? bidDate;
  @override
  @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
  final DateTime? loggedAt;

  @override
  String toString() {
    return 'BidOutcomeModel(id: $id, orderId: $orderId, vehicleOptionId: $vehicleOptionId, agentId: $agentId, outcome: $outcome, maxBidUsd: $maxBidUsd, finalPriceUsd: $finalPriceUsd, savingUsd: $savingUsd, finalPriceGhs: $finalPriceGhs, lossReason: $lossReason, lossPriceUsd: $lossPriceUsd, nextStep: $nextStep, noteToBuyer: $noteToBuyer, bidDate: $bidDate, loggedAt: $loggedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BidOutcomeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.vehicleOptionId, vehicleOptionId) ||
                other.vehicleOptionId == vehicleOptionId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.outcome, outcome) || other.outcome == outcome) &&
            (identical(other.maxBidUsd, maxBidUsd) ||
                other.maxBidUsd == maxBidUsd) &&
            (identical(other.finalPriceUsd, finalPriceUsd) ||
                other.finalPriceUsd == finalPriceUsd) &&
            (identical(other.savingUsd, savingUsd) ||
                other.savingUsd == savingUsd) &&
            (identical(other.finalPriceGhs, finalPriceGhs) ||
                other.finalPriceGhs == finalPriceGhs) &&
            (identical(other.lossReason, lossReason) ||
                other.lossReason == lossReason) &&
            (identical(other.lossPriceUsd, lossPriceUsd) ||
                other.lossPriceUsd == lossPriceUsd) &&
            (identical(other.nextStep, nextStep) ||
                other.nextStep == nextStep) &&
            (identical(other.noteToBuyer, noteToBuyer) ||
                other.noteToBuyer == noteToBuyer) &&
            (identical(other.bidDate, bidDate) || other.bidDate == bidDate) &&
            (identical(other.loggedAt, loggedAt) ||
                other.loggedAt == loggedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    vehicleOptionId,
    agentId,
    outcome,
    maxBidUsd,
    finalPriceUsd,
    savingUsd,
    finalPriceGhs,
    lossReason,
    lossPriceUsd,
    nextStep,
    noteToBuyer,
    bidDate,
    loggedAt,
  );

  /// Create a copy of BidOutcomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BidOutcomeModelImplCopyWith<_$BidOutcomeModelImpl> get copyWith =>
      __$$BidOutcomeModelImplCopyWithImpl<_$BidOutcomeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BidOutcomeModelImplToJson(this);
  }
}

abstract class _BidOutcomeModel implements BidOutcomeModel {
  const factory _BidOutcomeModel({
    required final String id,
    required final String orderId,
    final String? vehicleOptionId,
    required final String agentId,
    required final String outcome,
    final double? maxBidUsd,
    final double? finalPriceUsd,
    final double? savingUsd,
    final double? finalPriceGhs,
    final String? lossReason,
    final double? lossPriceUsd,
    final String? nextStep,
    final String? noteToBuyer,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    final DateTime? bidDate,
    @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
    final DateTime? loggedAt,
  }) = _$BidOutcomeModelImpl;

  factory _BidOutcomeModel.fromJson(Map<String, dynamic> json) =
      _$BidOutcomeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get vehicleOptionId;
  @override
  String get agentId;
  @override
  String get outcome; // 'won' | 'lost'
  @override
  double? get maxBidUsd;
  @override
  double? get finalPriceUsd;
  @override
  double? get savingUsd;
  @override
  double? get finalPriceGhs;
  @override
  String? get lossReason;
  @override
  double? get lossPriceUsd;
  @override
  String? get nextStep;
  @override
  String? get noteToBuyer;
  @override
  @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
  DateTime? get bidDate;
  @override
  @JsonKey(fromJson: _bidDateTimeFromJson, toJson: _bidDateTimeToJson)
  DateTime? get loggedAt;

  /// Create a copy of BidOutcomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BidOutcomeModelImplCopyWith<_$BidOutcomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
