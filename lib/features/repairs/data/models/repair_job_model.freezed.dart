// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'repair_job_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RepairJobModel _$RepairJobModelFromJson(Map<String, dynamic> json) {
  return _RepairJobModel.fromJson(json);
}

/// @nodoc
mixin _$RepairJobModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get garageId => throw _privateConstructorUsedError;
  String? get garageNameCustom => throw _privateConstructorUsedError;
  String? get garageLocation => throw _privateConstructorUsedError;
  String? get workDescription => throw _privateConstructorUsedError;
  String? get invoiceImageUrl => throw _privateConstructorUsedError;
  String? get invoiceRefNumber => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get invoiceDate => throw _privateConstructorUsedError;
  double? get totalInvoiceGhs => throw _privateConstructorUsedError;
  double? get partsDepositGhs => throw _privateConstructorUsedError;
  double? get workmanshipBalanceGhs => throw _privateConstructorUsedError;
  double? get platformFeeGhs => throw _privateConstructorUsedError;
  double? get quoteGhs => throw _privateConstructorUsedError;
  double? get platformServiceFeeGhs => throw _privateConstructorUsedError;
  double? get totalQuotedGhs => throw _privateConstructorUsedError;
  double? get finalCostGhs => throw _privateConstructorUsedError;
  bool get quoteApprovedByBuyer => throw _privateConstructorUsedError;
  DateTime? get quoteApprovedAt => throw _privateConstructorUsedError;
  DateTime? get quoteDeclinedAt => throw _privateConstructorUsedError;
  String? get depositPaymentRequestId => throw _privateConstructorUsedError;
  String? get balancePaymentRequestId => throw _privateConstructorUsedError;
  bool get depositPaid => throw _privateConstructorUsedError;
  bool get balancePaid => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
  RepairStatus get status => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get estimatedCompletion => throw _privateConstructorUsedError;
  DateTime? get actualCompletion => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get beforePhotoUrlsJson => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get afterPhotoUrlsJson => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RepairJobModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RepairJobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RepairJobModelCopyWith<RepairJobModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RepairJobModelCopyWith<$Res> {
  factory $RepairJobModelCopyWith(
    RepairJobModel value,
    $Res Function(RepairJobModel) then,
  ) = _$RepairJobModelCopyWithImpl<$Res, RepairJobModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String? garageId,
    String? garageNameCustom,
    String? garageLocation,
    String? workDescription,
    String? invoiceImageUrl,
    String? invoiceRefNumber,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? invoiceDate,
    double? totalInvoiceGhs,
    double? partsDepositGhs,
    double? workmanshipBalanceGhs,
    double? platformFeeGhs,
    double? quoteGhs,
    double? platformServiceFeeGhs,
    double? totalQuotedGhs,
    double? finalCostGhs,
    bool quoteApprovedByBuyer,
    DateTime? quoteApprovedAt,
    DateTime? quoteDeclinedAt,
    String? depositPaymentRequestId,
    String? balancePaymentRequestId,
    bool depositPaid,
    bool balancePaid,
    @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
    RepairStatus status,
    DateTime? startDate,
    DateTime? estimatedCompletion,
    DateTime? actualCompletion,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? beforePhotoUrlsJson,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? afterPhotoUrlsJson,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$RepairJobModelCopyWithImpl<$Res, $Val extends RepairJobModel>
    implements $RepairJobModelCopyWith<$Res> {
  _$RepairJobModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RepairJobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? garageId = freezed,
    Object? garageNameCustom = freezed,
    Object? garageLocation = freezed,
    Object? workDescription = freezed,
    Object? invoiceImageUrl = freezed,
    Object? invoiceRefNumber = freezed,
    Object? invoiceDate = freezed,
    Object? totalInvoiceGhs = freezed,
    Object? partsDepositGhs = freezed,
    Object? workmanshipBalanceGhs = freezed,
    Object? platformFeeGhs = freezed,
    Object? quoteGhs = freezed,
    Object? platformServiceFeeGhs = freezed,
    Object? totalQuotedGhs = freezed,
    Object? finalCostGhs = freezed,
    Object? quoteApprovedByBuyer = null,
    Object? quoteApprovedAt = freezed,
    Object? quoteDeclinedAt = freezed,
    Object? depositPaymentRequestId = freezed,
    Object? balancePaymentRequestId = freezed,
    Object? depositPaid = null,
    Object? balancePaid = null,
    Object? status = null,
    Object? startDate = freezed,
    Object? estimatedCompletion = freezed,
    Object? actualCompletion = freezed,
    Object? beforePhotoUrlsJson = freezed,
    Object? afterPhotoUrlsJson = freezed,
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
            garageId: freezed == garageId
                ? _value.garageId
                : garageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            garageNameCustom: freezed == garageNameCustom
                ? _value.garageNameCustom
                : garageNameCustom // ignore: cast_nullable_to_non_nullable
                      as String?,
            garageLocation: freezed == garageLocation
                ? _value.garageLocation
                : garageLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            workDescription: freezed == workDescription
                ? _value.workDescription
                : workDescription // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceImageUrl: freezed == invoiceImageUrl
                ? _value.invoiceImageUrl
                : invoiceImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceRefNumber: freezed == invoiceRefNumber
                ? _value.invoiceRefNumber
                : invoiceRefNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            invoiceDate: freezed == invoiceDate
                ? _value.invoiceDate
                : invoiceDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalInvoiceGhs: freezed == totalInvoiceGhs
                ? _value.totalInvoiceGhs
                : totalInvoiceGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            partsDepositGhs: freezed == partsDepositGhs
                ? _value.partsDepositGhs
                : partsDepositGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            workmanshipBalanceGhs: freezed == workmanshipBalanceGhs
                ? _value.workmanshipBalanceGhs
                : workmanshipBalanceGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            platformFeeGhs: freezed == platformFeeGhs
                ? _value.platformFeeGhs
                : platformFeeGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            quoteGhs: freezed == quoteGhs
                ? _value.quoteGhs
                : quoteGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            platformServiceFeeGhs: freezed == platformServiceFeeGhs
                ? _value.platformServiceFeeGhs
                : platformServiceFeeGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalQuotedGhs: freezed == totalQuotedGhs
                ? _value.totalQuotedGhs
                : totalQuotedGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            finalCostGhs: freezed == finalCostGhs
                ? _value.finalCostGhs
                : finalCostGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            quoteApprovedByBuyer: null == quoteApprovedByBuyer
                ? _value.quoteApprovedByBuyer
                : quoteApprovedByBuyer // ignore: cast_nullable_to_non_nullable
                      as bool,
            quoteApprovedAt: freezed == quoteApprovedAt
                ? _value.quoteApprovedAt
                : quoteApprovedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            quoteDeclinedAt: freezed == quoteDeclinedAt
                ? _value.quoteDeclinedAt
                : quoteDeclinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            depositPaymentRequestId: freezed == depositPaymentRequestId
                ? _value.depositPaymentRequestId
                : depositPaymentRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            balancePaymentRequestId: freezed == balancePaymentRequestId
                ? _value.balancePaymentRequestId
                : balancePaymentRequestId // ignore: cast_nullable_to_non_nullable
                      as String?,
            depositPaid: null == depositPaid
                ? _value.depositPaid
                : depositPaid // ignore: cast_nullable_to_non_nullable
                      as bool,
            balancePaid: null == balancePaid
                ? _value.balancePaid
                : balancePaid // ignore: cast_nullable_to_non_nullable
                      as bool,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as RepairStatus,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            estimatedCompletion: freezed == estimatedCompletion
                ? _value.estimatedCompletion
                : estimatedCompletion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actualCompletion: freezed == actualCompletion
                ? _value.actualCompletion
                : actualCompletion // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            beforePhotoUrlsJson: freezed == beforePhotoUrlsJson
                ? _value.beforePhotoUrlsJson
                : beforePhotoUrlsJson // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            afterPhotoUrlsJson: freezed == afterPhotoUrlsJson
                ? _value.afterPhotoUrlsJson
                : afterPhotoUrlsJson // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
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
abstract class _$$RepairJobModelImplCopyWith<$Res>
    implements $RepairJobModelCopyWith<$Res> {
  factory _$$RepairJobModelImplCopyWith(
    _$RepairJobModelImpl value,
    $Res Function(_$RepairJobModelImpl) then,
  ) = __$$RepairJobModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String? garageId,
    String? garageNameCustom,
    String? garageLocation,
    String? workDescription,
    String? invoiceImageUrl,
    String? invoiceRefNumber,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? invoiceDate,
    double? totalInvoiceGhs,
    double? partsDepositGhs,
    double? workmanshipBalanceGhs,
    double? platformFeeGhs,
    double? quoteGhs,
    double? platformServiceFeeGhs,
    double? totalQuotedGhs,
    double? finalCostGhs,
    bool quoteApprovedByBuyer,
    DateTime? quoteApprovedAt,
    DateTime? quoteDeclinedAt,
    String? depositPaymentRequestId,
    String? balancePaymentRequestId,
    bool depositPaid,
    bool balancePaid,
    @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
    RepairStatus status,
    DateTime? startDate,
    DateTime? estimatedCompletion,
    DateTime? actualCompletion,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? beforePhotoUrlsJson,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? afterPhotoUrlsJson,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$RepairJobModelImplCopyWithImpl<$Res>
    extends _$RepairJobModelCopyWithImpl<$Res, _$RepairJobModelImpl>
    implements _$$RepairJobModelImplCopyWith<$Res> {
  __$$RepairJobModelImplCopyWithImpl(
    _$RepairJobModelImpl _value,
    $Res Function(_$RepairJobModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RepairJobModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? garageId = freezed,
    Object? garageNameCustom = freezed,
    Object? garageLocation = freezed,
    Object? workDescription = freezed,
    Object? invoiceImageUrl = freezed,
    Object? invoiceRefNumber = freezed,
    Object? invoiceDate = freezed,
    Object? totalInvoiceGhs = freezed,
    Object? partsDepositGhs = freezed,
    Object? workmanshipBalanceGhs = freezed,
    Object? platformFeeGhs = freezed,
    Object? quoteGhs = freezed,
    Object? platformServiceFeeGhs = freezed,
    Object? totalQuotedGhs = freezed,
    Object? finalCostGhs = freezed,
    Object? quoteApprovedByBuyer = null,
    Object? quoteApprovedAt = freezed,
    Object? quoteDeclinedAt = freezed,
    Object? depositPaymentRequestId = freezed,
    Object? balancePaymentRequestId = freezed,
    Object? depositPaid = null,
    Object? balancePaid = null,
    Object? status = null,
    Object? startDate = freezed,
    Object? estimatedCompletion = freezed,
    Object? actualCompletion = freezed,
    Object? beforePhotoUrlsJson = freezed,
    Object? afterPhotoUrlsJson = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$RepairJobModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        garageId: freezed == garageId
            ? _value.garageId
            : garageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        garageNameCustom: freezed == garageNameCustom
            ? _value.garageNameCustom
            : garageNameCustom // ignore: cast_nullable_to_non_nullable
                  as String?,
        garageLocation: freezed == garageLocation
            ? _value.garageLocation
            : garageLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        workDescription: freezed == workDescription
            ? _value.workDescription
            : workDescription // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceImageUrl: freezed == invoiceImageUrl
            ? _value.invoiceImageUrl
            : invoiceImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceRefNumber: freezed == invoiceRefNumber
            ? _value.invoiceRefNumber
            : invoiceRefNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        invoiceDate: freezed == invoiceDate
            ? _value.invoiceDate
            : invoiceDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalInvoiceGhs: freezed == totalInvoiceGhs
            ? _value.totalInvoiceGhs
            : totalInvoiceGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        partsDepositGhs: freezed == partsDepositGhs
            ? _value.partsDepositGhs
            : partsDepositGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        workmanshipBalanceGhs: freezed == workmanshipBalanceGhs
            ? _value.workmanshipBalanceGhs
            : workmanshipBalanceGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        platformFeeGhs: freezed == platformFeeGhs
            ? _value.platformFeeGhs
            : platformFeeGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        quoteGhs: freezed == quoteGhs
            ? _value.quoteGhs
            : quoteGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        platformServiceFeeGhs: freezed == platformServiceFeeGhs
            ? _value.platformServiceFeeGhs
            : platformServiceFeeGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalQuotedGhs: freezed == totalQuotedGhs
            ? _value.totalQuotedGhs
            : totalQuotedGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        finalCostGhs: freezed == finalCostGhs
            ? _value.finalCostGhs
            : finalCostGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        quoteApprovedByBuyer: null == quoteApprovedByBuyer
            ? _value.quoteApprovedByBuyer
            : quoteApprovedByBuyer // ignore: cast_nullable_to_non_nullable
                  as bool,
        quoteApprovedAt: freezed == quoteApprovedAt
            ? _value.quoteApprovedAt
            : quoteApprovedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        quoteDeclinedAt: freezed == quoteDeclinedAt
            ? _value.quoteDeclinedAt
            : quoteDeclinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        depositPaymentRequestId: freezed == depositPaymentRequestId
            ? _value.depositPaymentRequestId
            : depositPaymentRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        balancePaymentRequestId: freezed == balancePaymentRequestId
            ? _value.balancePaymentRequestId
            : balancePaymentRequestId // ignore: cast_nullable_to_non_nullable
                  as String?,
        depositPaid: null == depositPaid
            ? _value.depositPaid
            : depositPaid // ignore: cast_nullable_to_non_nullable
                  as bool,
        balancePaid: null == balancePaid
            ? _value.balancePaid
            : balancePaid // ignore: cast_nullable_to_non_nullable
                  as bool,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as RepairStatus,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        estimatedCompletion: freezed == estimatedCompletion
            ? _value.estimatedCompletion
            : estimatedCompletion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actualCompletion: freezed == actualCompletion
            ? _value.actualCompletion
            : actualCompletion // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        beforePhotoUrlsJson: freezed == beforePhotoUrlsJson
            ? _value._beforePhotoUrlsJson
            : beforePhotoUrlsJson // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        afterPhotoUrlsJson: freezed == afterPhotoUrlsJson
            ? _value._afterPhotoUrlsJson
            : afterPhotoUrlsJson // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
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
class _$RepairJobModelImpl implements _RepairJobModel {
  const _$RepairJobModelImpl({
    required this.id,
    required this.orderId,
    this.garageId,
    this.garageNameCustom,
    this.garageLocation,
    this.workDescription,
    this.invoiceImageUrl,
    this.invoiceRefNumber,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    this.invoiceDate,
    this.totalInvoiceGhs,
    this.partsDepositGhs,
    this.workmanshipBalanceGhs,
    this.platformFeeGhs,
    this.quoteGhs,
    this.platformServiceFeeGhs,
    this.totalQuotedGhs,
    this.finalCostGhs,
    this.quoteApprovedByBuyer = false,
    this.quoteApprovedAt,
    this.quoteDeclinedAt,
    this.depositPaymentRequestId,
    this.balancePaymentRequestId,
    this.depositPaid = false,
    this.balancePaid = false,
    @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
    this.status = RepairStatus.notStarted,
    this.startDate,
    this.estimatedCompletion,
    this.actualCompletion,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? beforePhotoUrlsJson,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? afterPhotoUrlsJson,
    this.notes,
    this.createdAt,
  }) : _beforePhotoUrlsJson = beforePhotoUrlsJson,
       _afterPhotoUrlsJson = afterPhotoUrlsJson;

  factory _$RepairJobModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RepairJobModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? garageId;
  @override
  final String? garageNameCustom;
  @override
  final String? garageLocation;
  @override
  final String? workDescription;
  @override
  final String? invoiceImageUrl;
  @override
  final String? invoiceRefNumber;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? invoiceDate;
  @override
  final double? totalInvoiceGhs;
  @override
  final double? partsDepositGhs;
  @override
  final double? workmanshipBalanceGhs;
  @override
  final double? platformFeeGhs;
  @override
  final double? quoteGhs;
  @override
  final double? platformServiceFeeGhs;
  @override
  final double? totalQuotedGhs;
  @override
  final double? finalCostGhs;
  @override
  @JsonKey()
  final bool quoteApprovedByBuyer;
  @override
  final DateTime? quoteApprovedAt;
  @override
  final DateTime? quoteDeclinedAt;
  @override
  final String? depositPaymentRequestId;
  @override
  final String? balancePaymentRequestId;
  @override
  @JsonKey()
  final bool depositPaid;
  @override
  @JsonKey()
  final bool balancePaid;
  @override
  @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
  final RepairStatus status;
  @override
  final DateTime? startDate;
  @override
  final DateTime? estimatedCompletion;
  @override
  final DateTime? actualCompletion;
  final List<String>? _beforePhotoUrlsJson;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get beforePhotoUrlsJson {
    final value = _beforePhotoUrlsJson;
    if (value == null) return null;
    if (_beforePhotoUrlsJson is EqualUnmodifiableListView)
      return _beforePhotoUrlsJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _afterPhotoUrlsJson;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get afterPhotoUrlsJson {
    final value = _afterPhotoUrlsJson;
    if (value == null) return null;
    if (_afterPhotoUrlsJson is EqualUnmodifiableListView)
      return _afterPhotoUrlsJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? notes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'RepairJobModel(id: $id, orderId: $orderId, garageId: $garageId, garageNameCustom: $garageNameCustom, garageLocation: $garageLocation, workDescription: $workDescription, invoiceImageUrl: $invoiceImageUrl, invoiceRefNumber: $invoiceRefNumber, invoiceDate: $invoiceDate, totalInvoiceGhs: $totalInvoiceGhs, partsDepositGhs: $partsDepositGhs, workmanshipBalanceGhs: $workmanshipBalanceGhs, platformFeeGhs: $platformFeeGhs, quoteGhs: $quoteGhs, platformServiceFeeGhs: $platformServiceFeeGhs, totalQuotedGhs: $totalQuotedGhs, finalCostGhs: $finalCostGhs, quoteApprovedByBuyer: $quoteApprovedByBuyer, quoteApprovedAt: $quoteApprovedAt, quoteDeclinedAt: $quoteDeclinedAt, depositPaymentRequestId: $depositPaymentRequestId, balancePaymentRequestId: $balancePaymentRequestId, depositPaid: $depositPaid, balancePaid: $balancePaid, status: $status, startDate: $startDate, estimatedCompletion: $estimatedCompletion, actualCompletion: $actualCompletion, beforePhotoUrlsJson: $beforePhotoUrlsJson, afterPhotoUrlsJson: $afterPhotoUrlsJson, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RepairJobModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.garageId, garageId) ||
                other.garageId == garageId) &&
            (identical(other.garageNameCustom, garageNameCustom) ||
                other.garageNameCustom == garageNameCustom) &&
            (identical(other.garageLocation, garageLocation) ||
                other.garageLocation == garageLocation) &&
            (identical(other.workDescription, workDescription) ||
                other.workDescription == workDescription) &&
            (identical(other.invoiceImageUrl, invoiceImageUrl) ||
                other.invoiceImageUrl == invoiceImageUrl) &&
            (identical(other.invoiceRefNumber, invoiceRefNumber) ||
                other.invoiceRefNumber == invoiceRefNumber) &&
            (identical(other.invoiceDate, invoiceDate) ||
                other.invoiceDate == invoiceDate) &&
            (identical(other.totalInvoiceGhs, totalInvoiceGhs) ||
                other.totalInvoiceGhs == totalInvoiceGhs) &&
            (identical(other.partsDepositGhs, partsDepositGhs) ||
                other.partsDepositGhs == partsDepositGhs) &&
            (identical(other.workmanshipBalanceGhs, workmanshipBalanceGhs) ||
                other.workmanshipBalanceGhs == workmanshipBalanceGhs) &&
            (identical(other.platformFeeGhs, platformFeeGhs) ||
                other.platformFeeGhs == platformFeeGhs) &&
            (identical(other.quoteGhs, quoteGhs) ||
                other.quoteGhs == quoteGhs) &&
            (identical(other.platformServiceFeeGhs, platformServiceFeeGhs) ||
                other.platformServiceFeeGhs == platformServiceFeeGhs) &&
            (identical(other.totalQuotedGhs, totalQuotedGhs) ||
                other.totalQuotedGhs == totalQuotedGhs) &&
            (identical(other.finalCostGhs, finalCostGhs) ||
                other.finalCostGhs == finalCostGhs) &&
            (identical(other.quoteApprovedByBuyer, quoteApprovedByBuyer) ||
                other.quoteApprovedByBuyer == quoteApprovedByBuyer) &&
            (identical(other.quoteApprovedAt, quoteApprovedAt) ||
                other.quoteApprovedAt == quoteApprovedAt) &&
            (identical(other.quoteDeclinedAt, quoteDeclinedAt) ||
                other.quoteDeclinedAt == quoteDeclinedAt) &&
            (identical(
                  other.depositPaymentRequestId,
                  depositPaymentRequestId,
                ) ||
                other.depositPaymentRequestId == depositPaymentRequestId) &&
            (identical(
                  other.balancePaymentRequestId,
                  balancePaymentRequestId,
                ) ||
                other.balancePaymentRequestId == balancePaymentRequestId) &&
            (identical(other.depositPaid, depositPaid) ||
                other.depositPaid == depositPaid) &&
            (identical(other.balancePaid, balancePaid) ||
                other.balancePaid == balancePaid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.estimatedCompletion, estimatedCompletion) ||
                other.estimatedCompletion == estimatedCompletion) &&
            (identical(other.actualCompletion, actualCompletion) ||
                other.actualCompletion == actualCompletion) &&
            const DeepCollectionEquality().equals(
              other._beforePhotoUrlsJson,
              _beforePhotoUrlsJson,
            ) &&
            const DeepCollectionEquality().equals(
              other._afterPhotoUrlsJson,
              _afterPhotoUrlsJson,
            ) &&
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
    garageId,
    garageNameCustom,
    garageLocation,
    workDescription,
    invoiceImageUrl,
    invoiceRefNumber,
    invoiceDate,
    totalInvoiceGhs,
    partsDepositGhs,
    workmanshipBalanceGhs,
    platformFeeGhs,
    quoteGhs,
    platformServiceFeeGhs,
    totalQuotedGhs,
    finalCostGhs,
    quoteApprovedByBuyer,
    quoteApprovedAt,
    quoteDeclinedAt,
    depositPaymentRequestId,
    balancePaymentRequestId,
    depositPaid,
    balancePaid,
    status,
    startDate,
    estimatedCompletion,
    actualCompletion,
    const DeepCollectionEquality().hash(_beforePhotoUrlsJson),
    const DeepCollectionEquality().hash(_afterPhotoUrlsJson),
    notes,
    createdAt,
  ]);

  /// Create a copy of RepairJobModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RepairJobModelImplCopyWith<_$RepairJobModelImpl> get copyWith =>
      __$$RepairJobModelImplCopyWithImpl<_$RepairJobModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RepairJobModelImplToJson(this);
  }
}

abstract class _RepairJobModel implements RepairJobModel {
  const factory _RepairJobModel({
    required final String id,
    required final String orderId,
    final String? garageId,
    final String? garageNameCustom,
    final String? garageLocation,
    final String? workDescription,
    final String? invoiceImageUrl,
    final String? invoiceRefNumber,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? invoiceDate,
    final double? totalInvoiceGhs,
    final double? partsDepositGhs,
    final double? workmanshipBalanceGhs,
    final double? platformFeeGhs,
    final double? quoteGhs,
    final double? platformServiceFeeGhs,
    final double? totalQuotedGhs,
    final double? finalCostGhs,
    final bool quoteApprovedByBuyer,
    final DateTime? quoteApprovedAt,
    final DateTime? quoteDeclinedAt,
    final String? depositPaymentRequestId,
    final String? balancePaymentRequestId,
    final bool depositPaid,
    final bool balancePaid,
    @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
    final RepairStatus status,
    final DateTime? startDate,
    final DateTime? estimatedCompletion,
    final DateTime? actualCompletion,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? beforePhotoUrlsJson,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? afterPhotoUrlsJson,
    final String? notes,
    final DateTime? createdAt,
  }) = _$RepairJobModelImpl;

  factory _RepairJobModel.fromJson(Map<String, dynamic> json) =
      _$RepairJobModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get garageId;
  @override
  String? get garageNameCustom;
  @override
  String? get garageLocation;
  @override
  String? get workDescription;
  @override
  String? get invoiceImageUrl;
  @override
  String? get invoiceRefNumber;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get invoiceDate;
  @override
  double? get totalInvoiceGhs;
  @override
  double? get partsDepositGhs;
  @override
  double? get workmanshipBalanceGhs;
  @override
  double? get platformFeeGhs;
  @override
  double? get quoteGhs;
  @override
  double? get platformServiceFeeGhs;
  @override
  double? get totalQuotedGhs;
  @override
  double? get finalCostGhs;
  @override
  bool get quoteApprovedByBuyer;
  @override
  DateTime? get quoteApprovedAt;
  @override
  DateTime? get quoteDeclinedAt;
  @override
  String? get depositPaymentRequestId;
  @override
  String? get balancePaymentRequestId;
  @override
  bool get depositPaid;
  @override
  bool get balancePaid;
  @override
  @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
  RepairStatus get status;
  @override
  DateTime? get startDate;
  @override
  DateTime? get estimatedCompletion;
  @override
  DateTime? get actualCompletion;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get beforePhotoUrlsJson;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get afterPhotoUrlsJson;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;

  /// Create a copy of RepairJobModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RepairJobModelImplCopyWith<_$RepairJobModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
