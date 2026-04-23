// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BreakdownItem _$BreakdownItemFromJson(Map<String, dynamic> json) {
  return _BreakdownItem.fromJson(json);
}

/// @nodoc
mixin _$BreakdownItem {
  String get label => throw _privateConstructorUsedError;
  double get amountUsd => throw _privateConstructorUsedError;
  bool get isDeduction => throw _privateConstructorUsedError;

  /// Serializes this BreakdownItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BreakdownItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BreakdownItemCopyWith<BreakdownItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BreakdownItemCopyWith<$Res> {
  factory $BreakdownItemCopyWith(
    BreakdownItem value,
    $Res Function(BreakdownItem) then,
  ) = _$BreakdownItemCopyWithImpl<$Res, BreakdownItem>;
  @useResult
  $Res call({String label, double amountUsd, bool isDeduction});
}

/// @nodoc
class _$BreakdownItemCopyWithImpl<$Res, $Val extends BreakdownItem>
    implements $BreakdownItemCopyWith<$Res> {
  _$BreakdownItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BreakdownItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? amountUsd = null,
    Object? isDeduction = null,
  }) {
    return _then(
      _value.copyWith(
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            amountUsd: null == amountUsd
                ? _value.amountUsd
                : amountUsd // ignore: cast_nullable_to_non_nullable
                      as double,
            isDeduction: null == isDeduction
                ? _value.isDeduction
                : isDeduction // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BreakdownItemImplCopyWith<$Res>
    implements $BreakdownItemCopyWith<$Res> {
  factory _$$BreakdownItemImplCopyWith(
    _$BreakdownItemImpl value,
    $Res Function(_$BreakdownItemImpl) then,
  ) = __$$BreakdownItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, double amountUsd, bool isDeduction});
}

/// @nodoc
class __$$BreakdownItemImplCopyWithImpl<$Res>
    extends _$BreakdownItemCopyWithImpl<$Res, _$BreakdownItemImpl>
    implements _$$BreakdownItemImplCopyWith<$Res> {
  __$$BreakdownItemImplCopyWithImpl(
    _$BreakdownItemImpl _value,
    $Res Function(_$BreakdownItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BreakdownItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? amountUsd = null,
    Object? isDeduction = null,
  }) {
    return _then(
      _$BreakdownItemImpl(
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        amountUsd: null == amountUsd
            ? _value.amountUsd
            : amountUsd // ignore: cast_nullable_to_non_nullable
                  as double,
        isDeduction: null == isDeduction
            ? _value.isDeduction
            : isDeduction // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BreakdownItemImpl implements _BreakdownItem {
  const _$BreakdownItemImpl({
    required this.label,
    required this.amountUsd,
    this.isDeduction = false,
  });

  factory _$BreakdownItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BreakdownItemImplFromJson(json);

  @override
  final String label;
  @override
  final double amountUsd;
  @override
  @JsonKey()
  final bool isDeduction;

  @override
  String toString() {
    return 'BreakdownItem(label: $label, amountUsd: $amountUsd, isDeduction: $isDeduction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BreakdownItemImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.amountUsd, amountUsd) ||
                other.amountUsd == amountUsd) &&
            (identical(other.isDeduction, isDeduction) ||
                other.isDeduction == isDeduction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, amountUsd, isDeduction);

  /// Create a copy of BreakdownItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BreakdownItemImplCopyWith<_$BreakdownItemImpl> get copyWith =>
      __$$BreakdownItemImplCopyWithImpl<_$BreakdownItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BreakdownItemImplToJson(this);
  }
}

abstract class _BreakdownItem implements BreakdownItem {
  const factory _BreakdownItem({
    required final String label,
    required final double amountUsd,
    final bool isDeduction,
  }) = _$BreakdownItemImpl;

  factory _BreakdownItem.fromJson(Map<String, dynamic> json) =
      _$BreakdownItemImpl.fromJson;

  @override
  String get label;
  @override
  double get amountUsd;
  @override
  bool get isDeduction;

  /// Create a copy of BreakdownItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BreakdownItemImplCopyWith<_$BreakdownItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentRequestModel _$PaymentRequestModelFromJson(Map<String, dynamic> json) {
  return _PaymentRequestModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentRequestModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get createdByAgentId => throw _privateConstructorUsedError;
  String? get paymentId => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _paymentRequestTypeFromJson,
    toJson: _paymentRequestTypeToJson,
  )
  PaymentRequestType get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
  List<BreakdownItem> get breakdown => throw _privateConstructorUsedError;
  double get amountUsd => throw _privateConstructorUsedError;
  double? get exchangeRateAtRequest => throw _privateConstructorUsedError;
  double? get depositDeductedUsd => throw _privateConstructorUsedError;
  String? get timelineStageKey => throw _privateConstructorUsedError;
  String? get invoiceImageUrl => throw _privateConstructorUsedError;
  DateTime? get deadlineAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get sentAt => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  DateTime? get expiredAt => throw _privateConstructorUsedError;
  DateTime? get cancelledAt => throw _privateConstructorUsedError;

  /// Serializes this PaymentRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentRequestModelCopyWith<PaymentRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentRequestModelCopyWith<$Res> {
  factory $PaymentRequestModelCopyWith(
    PaymentRequestModel value,
    $Res Function(PaymentRequestModel) then,
  ) = _$PaymentRequestModelCopyWithImpl<$Res, PaymentRequestModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String? createdByAgentId,
    String? paymentId,
    @JsonKey(
      fromJson: _paymentRequestTypeFromJson,
      toJson: _paymentRequestTypeToJson,
    )
    PaymentRequestType type,
    String? description,
    @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
    List<BreakdownItem> breakdown,
    double amountUsd,
    double? exchangeRateAtRequest,
    double? depositDeductedUsd,
    String? timelineStageKey,
    String? invoiceImageUrl,
    DateTime? deadlineAt,
    String status,
    DateTime? sentAt,
    DateTime? paidAt,
    DateTime? expiredAt,
    DateTime? cancelledAt,
  });
}

/// @nodoc
class _$PaymentRequestModelCopyWithImpl<$Res, $Val extends PaymentRequestModel>
    implements $PaymentRequestModelCopyWith<$Res> {
  _$PaymentRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? createdByAgentId = freezed,
    Object? paymentId = freezed,
    Object? type = null,
    Object? description = freezed,
    Object? breakdown = null,
    Object? amountUsd = null,
    Object? exchangeRateAtRequest = freezed,
    Object? depositDeductedUsd = freezed,
    Object? timelineStageKey = freezed,
    Object? invoiceImageUrl = freezed,
    Object? deadlineAt = freezed,
    Object? status = null,
    Object? sentAt = freezed,
    Object? paidAt = freezed,
    Object? expiredAt = freezed,
    Object? cancelledAt = freezed,
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
            createdByAgentId: freezed == createdByAgentId
                ? _value.createdByAgentId
                : createdByAgentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentId: freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as PaymentRequestType,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            breakdown: null == breakdown
                ? _value.breakdown
                : breakdown // ignore: cast_nullable_to_non_nullable
                      as List<BreakdownItem>,
            amountUsd: null == amountUsd
                ? _value.amountUsd
                : amountUsd // ignore: cast_nullable_to_non_nullable
                      as double,
            exchangeRateAtRequest: freezed == exchangeRateAtRequest
                ? _value.exchangeRateAtRequest
                : exchangeRateAtRequest // ignore: cast_nullable_to_non_nullable
                      as double?,
            depositDeductedUsd: freezed == depositDeductedUsd
                ? _value.depositDeductedUsd
                : depositDeductedUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            timelineStageKey: freezed == timelineStageKey
                ? _value.timelineStageKey
                : timelineStageKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceImageUrl: freezed == invoiceImageUrl
                ? _value.invoiceImageUrl
                : invoiceImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            deadlineAt: freezed == deadlineAt
                ? _value.deadlineAt
                : deadlineAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            sentAt: freezed == sentAt
                ? _value.sentAt
                : sentAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiredAt: freezed == expiredAt
                ? _value.expiredAt
                : expiredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            cancelledAt: freezed == cancelledAt
                ? _value.cancelledAt
                : cancelledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentRequestModelImplCopyWith<$Res>
    implements $PaymentRequestModelCopyWith<$Res> {
  factory _$$PaymentRequestModelImplCopyWith(
    _$PaymentRequestModelImpl value,
    $Res Function(_$PaymentRequestModelImpl) then,
  ) = __$$PaymentRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String? createdByAgentId,
    String? paymentId,
    @JsonKey(
      fromJson: _paymentRequestTypeFromJson,
      toJson: _paymentRequestTypeToJson,
    )
    PaymentRequestType type,
    String? description,
    @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
    List<BreakdownItem> breakdown,
    double amountUsd,
    double? exchangeRateAtRequest,
    double? depositDeductedUsd,
    String? timelineStageKey,
    String? invoiceImageUrl,
    DateTime? deadlineAt,
    String status,
    DateTime? sentAt,
    DateTime? paidAt,
    DateTime? expiredAt,
    DateTime? cancelledAt,
  });
}

/// @nodoc
class __$$PaymentRequestModelImplCopyWithImpl<$Res>
    extends _$PaymentRequestModelCopyWithImpl<$Res, _$PaymentRequestModelImpl>
    implements _$$PaymentRequestModelImplCopyWith<$Res> {
  __$$PaymentRequestModelImplCopyWithImpl(
    _$PaymentRequestModelImpl _value,
    $Res Function(_$PaymentRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? createdByAgentId = freezed,
    Object? paymentId = freezed,
    Object? type = null,
    Object? description = freezed,
    Object? breakdown = null,
    Object? amountUsd = null,
    Object? exchangeRateAtRequest = freezed,
    Object? depositDeductedUsd = freezed,
    Object? timelineStageKey = freezed,
    Object? invoiceImageUrl = freezed,
    Object? deadlineAt = freezed,
    Object? status = null,
    Object? sentAt = freezed,
    Object? paidAt = freezed,
    Object? expiredAt = freezed,
    Object? cancelledAt = freezed,
  }) {
    return _then(
      _$PaymentRequestModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByAgentId: freezed == createdByAgentId
            ? _value.createdByAgentId
            : createdByAgentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentId: freezed == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as PaymentRequestType,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        breakdown: null == breakdown
            ? _value._breakdown
            : breakdown // ignore: cast_nullable_to_non_nullable
                  as List<BreakdownItem>,
        amountUsd: null == amountUsd
            ? _value.amountUsd
            : amountUsd // ignore: cast_nullable_to_non_nullable
                  as double,
        exchangeRateAtRequest: freezed == exchangeRateAtRequest
            ? _value.exchangeRateAtRequest
            : exchangeRateAtRequest // ignore: cast_nullable_to_non_nullable
                  as double?,
        depositDeductedUsd: freezed == depositDeductedUsd
            ? _value.depositDeductedUsd
            : depositDeductedUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        timelineStageKey: freezed == timelineStageKey
            ? _value.timelineStageKey
            : timelineStageKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceImageUrl: freezed == invoiceImageUrl
            ? _value.invoiceImageUrl
            : invoiceImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        deadlineAt: freezed == deadlineAt
            ? _value.deadlineAt
            : deadlineAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        sentAt: freezed == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiredAt: freezed == expiredAt
            ? _value.expiredAt
            : expiredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        cancelledAt: freezed == cancelledAt
            ? _value.cancelledAt
            : cancelledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentRequestModelImpl implements _PaymentRequestModel {
  const _$PaymentRequestModelImpl({
    required this.id,
    required this.orderId,
    this.createdByAgentId,
    this.paymentId,
    @JsonKey(
      fromJson: _paymentRequestTypeFromJson,
      toJson: _paymentRequestTypeToJson,
    )
    required this.type,
    this.description,
    @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
    final List<BreakdownItem> breakdown = const [],
    required this.amountUsd,
    this.exchangeRateAtRequest,
    this.depositDeductedUsd,
    this.timelineStageKey,
    this.invoiceImageUrl,
    this.deadlineAt,
    this.status = 'pending',
    this.sentAt,
    this.paidAt,
    this.expiredAt,
    this.cancelledAt,
  }) : _breakdown = breakdown;

  factory _$PaymentRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentRequestModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? createdByAgentId;
  @override
  final String? paymentId;
  @override
  @JsonKey(
    fromJson: _paymentRequestTypeFromJson,
    toJson: _paymentRequestTypeToJson,
  )
  final PaymentRequestType type;
  @override
  final String? description;
  final List<BreakdownItem> _breakdown;
  @override
  @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
  List<BreakdownItem> get breakdown {
    if (_breakdown is EqualUnmodifiableListView) return _breakdown;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breakdown);
  }

  @override
  final double amountUsd;
  @override
  final double? exchangeRateAtRequest;
  @override
  final double? depositDeductedUsd;
  @override
  final String? timelineStageKey;
  @override
  final String? invoiceImageUrl;
  @override
  final DateTime? deadlineAt;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? sentAt;
  @override
  final DateTime? paidAt;
  @override
  final DateTime? expiredAt;
  @override
  final DateTime? cancelledAt;

  @override
  String toString() {
    return 'PaymentRequestModel(id: $id, orderId: $orderId, createdByAgentId: $createdByAgentId, paymentId: $paymentId, type: $type, description: $description, breakdown: $breakdown, amountUsd: $amountUsd, exchangeRateAtRequest: $exchangeRateAtRequest, depositDeductedUsd: $depositDeductedUsd, timelineStageKey: $timelineStageKey, invoiceImageUrl: $invoiceImageUrl, deadlineAt: $deadlineAt, status: $status, sentAt: $sentAt, paidAt: $paidAt, expiredAt: $expiredAt, cancelledAt: $cancelledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentRequestModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.createdByAgentId, createdByAgentId) ||
                other.createdByAgentId == createdByAgentId) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._breakdown,
              _breakdown,
            ) &&
            (identical(other.amountUsd, amountUsd) ||
                other.amountUsd == amountUsd) &&
            (identical(other.exchangeRateAtRequest, exchangeRateAtRequest) ||
                other.exchangeRateAtRequest == exchangeRateAtRequest) &&
            (identical(other.depositDeductedUsd, depositDeductedUsd) ||
                other.depositDeductedUsd == depositDeductedUsd) &&
            (identical(other.timelineStageKey, timelineStageKey) ||
                other.timelineStageKey == timelineStageKey) &&
            (identical(other.invoiceImageUrl, invoiceImageUrl) ||
                other.invoiceImageUrl == invoiceImageUrl) &&
            (identical(other.deadlineAt, deadlineAt) ||
                other.deadlineAt == deadlineAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    createdByAgentId,
    paymentId,
    type,
    description,
    const DeepCollectionEquality().hash(_breakdown),
    amountUsd,
    exchangeRateAtRequest,
    depositDeductedUsd,
    timelineStageKey,
    invoiceImageUrl,
    deadlineAt,
    status,
    sentAt,
    paidAt,
    expiredAt,
    cancelledAt,
  );

  /// Create a copy of PaymentRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentRequestModelImplCopyWith<_$PaymentRequestModelImpl> get copyWith =>
      __$$PaymentRequestModelImplCopyWithImpl<_$PaymentRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentRequestModelImplToJson(this);
  }
}

abstract class _PaymentRequestModel implements PaymentRequestModel {
  const factory _PaymentRequestModel({
    required final String id,
    required final String orderId,
    final String? createdByAgentId,
    final String? paymentId,
    @JsonKey(
      fromJson: _paymentRequestTypeFromJson,
      toJson: _paymentRequestTypeToJson,
    )
    required final PaymentRequestType type,
    final String? description,
    @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
    final List<BreakdownItem> breakdown,
    required final double amountUsd,
    final double? exchangeRateAtRequest,
    final double? depositDeductedUsd,
    final String? timelineStageKey,
    final String? invoiceImageUrl,
    final DateTime? deadlineAt,
    final String status,
    final DateTime? sentAt,
    final DateTime? paidAt,
    final DateTime? expiredAt,
    final DateTime? cancelledAt,
  }) = _$PaymentRequestModelImpl;

  factory _PaymentRequestModel.fromJson(Map<String, dynamic> json) =
      _$PaymentRequestModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get createdByAgentId;
  @override
  String? get paymentId;
  @override
  @JsonKey(
    fromJson: _paymentRequestTypeFromJson,
    toJson: _paymentRequestTypeToJson,
  )
  PaymentRequestType get type;
  @override
  String? get description;
  @override
  @JsonKey(fromJson: _breakdownFromJson, toJson: _breakdownToJson)
  List<BreakdownItem> get breakdown;
  @override
  double get amountUsd;
  @override
  double? get exchangeRateAtRequest;
  @override
  double? get depositDeductedUsd;
  @override
  String? get timelineStageKey;
  @override
  String? get invoiceImageUrl;
  @override
  DateTime? get deadlineAt;
  @override
  String get status;
  @override
  DateTime? get sentAt;
  @override
  DateTime? get paidAt;
  @override
  DateTime? get expiredAt;
  @override
  DateTime? get cancelledAt;

  /// Create a copy of PaymentRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentRequestModelImplCopyWith<_$PaymentRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
