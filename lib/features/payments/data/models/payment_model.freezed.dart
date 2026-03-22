// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) {
  return _PaymentModel.fromJson(json);
}

/// @nodoc
mixin _$PaymentModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get buyerId => throw _privateConstructorUsedError;
  String? get paymentRequestId => throw _privateConstructorUsedError;
  String? get paymentRef => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double get amountGhs => throw _privateConstructorUsedError;
  double? get amountUsd => throw _privateConstructorUsedError;
  double? get exchangeRate => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get method => throw _privateConstructorUsedError;
  String? get provider => throw _privateConstructorUsedError;
  String? get providerRef => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get failureReason => throw _privateConstructorUsedError;
  DateTime? get initiatedAt => throw _privateConstructorUsedError;
  DateTime? get confirmedAt => throw _privateConstructorUsedError;
  DateTime? get refundedAt => throw _privateConstructorUsedError;

  /// Serializes this PaymentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentModelCopyWith<PaymentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentModelCopyWith<$Res> {
  factory $PaymentModelCopyWith(
    PaymentModel value,
    $Res Function(PaymentModel) then,
  ) = _$PaymentModelCopyWithImpl<$Res, PaymentModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String buyerId,
    String? paymentRequestId,
    String? paymentRef,
    String type,
    String? description,
    double amountGhs,
    double? amountUsd,
    double? exchangeRate,
    String currency,
    String? method,
    String? provider,
    String? providerRef,
    String status,
    String? failureReason,
    DateTime? initiatedAt,
    DateTime? confirmedAt,
    DateTime? refundedAt,
  });
}

/// @nodoc
class _$PaymentModelCopyWithImpl<$Res, $Val extends PaymentModel>
    implements $PaymentModelCopyWith<$Res> {
  _$PaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? buyerId = null,
    Object? paymentRequestId = freezed,
    Object? paymentRef = freezed,
    Object? type = null,
    Object? description = freezed,
    Object? amountGhs = null,
    Object? amountUsd = freezed,
    Object? exchangeRate = freezed,
    Object? currency = null,
    Object? method = freezed,
    Object? provider = freezed,
    Object? providerRef = freezed,
    Object? status = null,
    Object? failureReason = freezed,
    Object? initiatedAt = freezed,
    Object? confirmedAt = freezed,
    Object? refundedAt = freezed,
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
            buyerId: null == buyerId
                ? _value.buyerId
                : buyerId // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentRequestId: freezed == paymentRequestId
                ? _value.paymentRequestId
                : paymentRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentRef: freezed == paymentRef
                ? _value.paymentRef
                : paymentRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            amountGhs: null == amountGhs
                ? _value.amountGhs
                : amountGhs // ignore: cast_nullable_to_non_nullable
                      as double,
            amountUsd: freezed == amountUsd
                ? _value.amountUsd
                : amountUsd // ignore: cast_nullable_to_non_nullable
                      as double?,
            exchangeRate: freezed == exchangeRate
                ? _value.exchangeRate
                : exchangeRate // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            method: freezed == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String?,
            provider: freezed == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String?,
            providerRef: freezed == providerRef
                ? _value.providerRef
                : providerRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            failureReason: freezed == failureReason
                ? _value.failureReason
                : failureReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            initiatedAt: freezed == initiatedAt
                ? _value.initiatedAt
                : initiatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            confirmedAt: freezed == confirmedAt
                ? _value.confirmedAt
                : confirmedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            refundedAt: freezed == refundedAt
                ? _value.refundedAt
                : refundedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentModelImplCopyWith<$Res>
    implements $PaymentModelCopyWith<$Res> {
  factory _$$PaymentModelImplCopyWith(
    _$PaymentModelImpl value,
    $Res Function(_$PaymentModelImpl) then,
  ) = __$$PaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String buyerId,
    String? paymentRequestId,
    String? paymentRef,
    String type,
    String? description,
    double amountGhs,
    double? amountUsd,
    double? exchangeRate,
    String currency,
    String? method,
    String? provider,
    String? providerRef,
    String status,
    String? failureReason,
    DateTime? initiatedAt,
    DateTime? confirmedAt,
    DateTime? refundedAt,
  });
}

/// @nodoc
class __$$PaymentModelImplCopyWithImpl<$Res>
    extends _$PaymentModelCopyWithImpl<$Res, _$PaymentModelImpl>
    implements _$$PaymentModelImplCopyWith<$Res> {
  __$$PaymentModelImplCopyWithImpl(
    _$PaymentModelImpl _value,
    $Res Function(_$PaymentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? buyerId = null,
    Object? paymentRequestId = freezed,
    Object? paymentRef = freezed,
    Object? type = null,
    Object? description = freezed,
    Object? amountGhs = null,
    Object? amountUsd = freezed,
    Object? exchangeRate = freezed,
    Object? currency = null,
    Object? method = freezed,
    Object? provider = freezed,
    Object? providerRef = freezed,
    Object? status = null,
    Object? failureReason = freezed,
    Object? initiatedAt = freezed,
    Object? confirmedAt = freezed,
    Object? refundedAt = freezed,
  }) {
    return _then(
      _$PaymentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        buyerId: null == buyerId
            ? _value.buyerId
            : buyerId // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentRequestId: freezed == paymentRequestId
            ? _value.paymentRequestId
            : paymentRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentRef: freezed == paymentRef
            ? _value.paymentRef
            : paymentRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        amountGhs: null == amountGhs
            ? _value.amountGhs
            : amountGhs // ignore: cast_nullable_to_non_nullable
                  as double,
        amountUsd: freezed == amountUsd
            ? _value.amountUsd
            : amountUsd // ignore: cast_nullable_to_non_nullable
                  as double?,
        exchangeRate: freezed == exchangeRate
            ? _value.exchangeRate
            : exchangeRate // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        method: freezed == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String?,
        provider: freezed == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String?,
        providerRef: freezed == providerRef
            ? _value.providerRef
            : providerRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        failureReason: freezed == failureReason
            ? _value.failureReason
            : failureReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        initiatedAt: freezed == initiatedAt
            ? _value.initiatedAt
            : initiatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        confirmedAt: freezed == confirmedAt
            ? _value.confirmedAt
            : confirmedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        refundedAt: freezed == refundedAt
            ? _value.refundedAt
            : refundedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentModelImpl implements _PaymentModel {
  const _$PaymentModelImpl({
    required this.id,
    required this.orderId,
    required this.buyerId,
    this.paymentRequestId,
    this.paymentRef,
    required this.type,
    this.description,
    required this.amountGhs,
    this.amountUsd,
    this.exchangeRate,
    this.currency = 'GHS',
    this.method,
    this.provider,
    this.providerRef,
    this.status = 'pending',
    this.failureReason,
    this.initiatedAt,
    this.confirmedAt,
    this.refundedAt,
  });

  factory _$PaymentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String buyerId;
  @override
  final String? paymentRequestId;
  @override
  final String? paymentRef;
  @override
  final String type;
  @override
  final String? description;
  @override
  final double amountGhs;
  @override
  final double? amountUsd;
  @override
  final double? exchangeRate;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? method;
  @override
  final String? provider;
  @override
  final String? providerRef;
  @override
  @JsonKey()
  final String status;
  @override
  final String? failureReason;
  @override
  final DateTime? initiatedAt;
  @override
  final DateTime? confirmedAt;
  @override
  final DateTime? refundedAt;

  @override
  String toString() {
    return 'PaymentModel(id: $id, orderId: $orderId, buyerId: $buyerId, paymentRequestId: $paymentRequestId, paymentRef: $paymentRef, type: $type, description: $description, amountGhs: $amountGhs, amountUsd: $amountUsd, exchangeRate: $exchangeRate, currency: $currency, method: $method, provider: $provider, providerRef: $providerRef, status: $status, failureReason: $failureReason, initiatedAt: $initiatedAt, confirmedAt: $confirmedAt, refundedAt: $refundedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.buyerId, buyerId) || other.buyerId == buyerId) &&
            (identical(other.paymentRequestId, paymentRequestId) ||
                other.paymentRequestId == paymentRequestId) &&
            (identical(other.paymentRef, paymentRef) ||
                other.paymentRef == paymentRef) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amountGhs, amountGhs) ||
                other.amountGhs == amountGhs) &&
            (identical(other.amountUsd, amountUsd) ||
                other.amountUsd == amountUsd) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.providerRef, providerRef) ||
                other.providerRef == providerRef) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.initiatedAt, initiatedAt) ||
                other.initiatedAt == initiatedAt) &&
            (identical(other.confirmedAt, confirmedAt) ||
                other.confirmedAt == confirmedAt) &&
            (identical(other.refundedAt, refundedAt) ||
                other.refundedAt == refundedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderId,
    buyerId,
    paymentRequestId,
    paymentRef,
    type,
    description,
    amountGhs,
    amountUsd,
    exchangeRate,
    currency,
    method,
    provider,
    providerRef,
    status,
    failureReason,
    initiatedAt,
    confirmedAt,
    refundedAt,
  ]);

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentModelImplCopyWith<_$PaymentModelImpl> get copyWith =>
      __$$PaymentModelImplCopyWithImpl<_$PaymentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentModelImplToJson(this);
  }
}

abstract class _PaymentModel implements PaymentModel {
  const factory _PaymentModel({
    required final String id,
    required final String orderId,
    required final String buyerId,
    final String? paymentRequestId,
    final String? paymentRef,
    required final String type,
    final String? description,
    required final double amountGhs,
    final double? amountUsd,
    final double? exchangeRate,
    final String currency,
    final String? method,
    final String? provider,
    final String? providerRef,
    final String status,
    final String? failureReason,
    final DateTime? initiatedAt,
    final DateTime? confirmedAt,
    final DateTime? refundedAt,
  }) = _$PaymentModelImpl;

  factory _PaymentModel.fromJson(Map<String, dynamic> json) =
      _$PaymentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get buyerId;
  @override
  String? get paymentRequestId;
  @override
  String? get paymentRef;
  @override
  String get type;
  @override
  String? get description;
  @override
  double get amountGhs;
  @override
  double? get amountUsd;
  @override
  double? get exchangeRate;
  @override
  String get currency;
  @override
  String? get method;
  @override
  String? get provider;
  @override
  String? get providerRef;
  @override
  String get status;
  @override
  String? get failureReason;
  @override
  DateTime? get initiatedAt;
  @override
  DateTime? get confirmedAt;
  @override
  DateTime? get refundedAt;

  /// Create a copy of PaymentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentModelImplCopyWith<_$PaymentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
