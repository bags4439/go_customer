// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'duty_clearance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DutyClearanceModel _$DutyClearanceModelFromJson(Map<String, dynamic> json) {
  return _DutyClearanceModel.fromJson(json);
}

/// @nodoc
mixin _$DutyClearanceModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get handledBy =>
      throw _privateConstructorUsedError; // 'agent' | 'buyer'
  double? get clearanceFeeGhs => throw _privateConstructorUsedError;
  String? get icumsRef => throw _privateConstructorUsedError;
  String? get clearingAgentName => throw _privateConstructorUsedError;
  double? get dutyAmountGhs => throw _privateConstructorUsedError;
  double? get vatGhs => throw _privateConstructorUsedError;
  double? get nhilGhs => throw _privateConstructorUsedError;
  double? get otherLeviesGhs => throw _privateConstructorUsedError;
  double? get totalPayableGhs => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
  GraStatus get graStatus => throw _privateConstructorUsedError;
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  DateTime? get assessedAt => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  DateTime? get clearedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DutyClearanceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DutyClearanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DutyClearanceModelCopyWith<DutyClearanceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DutyClearanceModelCopyWith<$Res> {
  factory $DutyClearanceModelCopyWith(
    DutyClearanceModel value,
    $Res Function(DutyClearanceModel) then,
  ) = _$DutyClearanceModelCopyWithImpl<$Res, DutyClearanceModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String handledBy,
    double? clearanceFeeGhs,
    String? icumsRef,
    String? clearingAgentName,
    double? dutyAmountGhs,
    double? vatGhs,
    double? nhilGhs,
    double? otherLeviesGhs,
    double? totalPayableGhs,
    @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
    GraStatus graStatus,
    DateTime? submittedAt,
    DateTime? assessedAt,
    DateTime? paidAt,
    DateTime? clearedAt,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class _$DutyClearanceModelCopyWithImpl<$Res, $Val extends DutyClearanceModel>
    implements $DutyClearanceModelCopyWith<$Res> {
  _$DutyClearanceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DutyClearanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? handledBy = null,
    Object? clearanceFeeGhs = freezed,
    Object? icumsRef = freezed,
    Object? clearingAgentName = freezed,
    Object? dutyAmountGhs = freezed,
    Object? vatGhs = freezed,
    Object? nhilGhs = freezed,
    Object? otherLeviesGhs = freezed,
    Object? totalPayableGhs = freezed,
    Object? graStatus = null,
    Object? submittedAt = freezed,
    Object? assessedAt = freezed,
    Object? paidAt = freezed,
    Object? clearedAt = freezed,
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
            handledBy: null == handledBy
                ? _value.handledBy
                : handledBy // ignore: cast_nullable_to_non_nullable
                      as String,
            clearanceFeeGhs: freezed == clearanceFeeGhs
                ? _value.clearanceFeeGhs
                : clearanceFeeGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            icumsRef: freezed == icumsRef
                ? _value.icumsRef
                : icumsRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            clearingAgentName: freezed == clearingAgentName
                ? _value.clearingAgentName
                : clearingAgentName // ignore: cast_nullable_to_non_nullable
                      as String?,
            dutyAmountGhs: freezed == dutyAmountGhs
                ? _value.dutyAmountGhs
                : dutyAmountGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            vatGhs: freezed == vatGhs
                ? _value.vatGhs
                : vatGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            nhilGhs: freezed == nhilGhs
                ? _value.nhilGhs
                : nhilGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            otherLeviesGhs: freezed == otherLeviesGhs
                ? _value.otherLeviesGhs
                : otherLeviesGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            totalPayableGhs: freezed == totalPayableGhs
                ? _value.totalPayableGhs
                : totalPayableGhs // ignore: cast_nullable_to_non_nullable
                      as double?,
            graStatus: null == graStatus
                ? _value.graStatus
                : graStatus // ignore: cast_nullable_to_non_nullable
                      as GraStatus,
            submittedAt: freezed == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            assessedAt: freezed == assessedAt
                ? _value.assessedAt
                : assessedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            paidAt: freezed == paidAt
                ? _value.paidAt
                : paidAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            clearedAt: freezed == clearedAt
                ? _value.clearedAt
                : clearedAt // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DutyClearanceModelImplCopyWith<$Res>
    implements $DutyClearanceModelCopyWith<$Res> {
  factory _$$DutyClearanceModelImplCopyWith(
    _$DutyClearanceModelImpl value,
    $Res Function(_$DutyClearanceModelImpl) then,
  ) = __$$DutyClearanceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String handledBy,
    double? clearanceFeeGhs,
    String? icumsRef,
    String? clearingAgentName,
    double? dutyAmountGhs,
    double? vatGhs,
    double? nhilGhs,
    double? otherLeviesGhs,
    double? totalPayableGhs,
    @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
    GraStatus graStatus,
    DateTime? submittedAt,
    DateTime? assessedAt,
    DateTime? paidAt,
    DateTime? clearedAt,
    String? notes,
    DateTime? createdAt,
  });
}

/// @nodoc
class __$$DutyClearanceModelImplCopyWithImpl<$Res>
    extends _$DutyClearanceModelCopyWithImpl<$Res, _$DutyClearanceModelImpl>
    implements _$$DutyClearanceModelImplCopyWith<$Res> {
  __$$DutyClearanceModelImplCopyWithImpl(
    _$DutyClearanceModelImpl _value,
    $Res Function(_$DutyClearanceModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DutyClearanceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? handledBy = null,
    Object? clearanceFeeGhs = freezed,
    Object? icumsRef = freezed,
    Object? clearingAgentName = freezed,
    Object? dutyAmountGhs = freezed,
    Object? vatGhs = freezed,
    Object? nhilGhs = freezed,
    Object? otherLeviesGhs = freezed,
    Object? totalPayableGhs = freezed,
    Object? graStatus = null,
    Object? submittedAt = freezed,
    Object? assessedAt = freezed,
    Object? paidAt = freezed,
    Object? clearedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$DutyClearanceModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        handledBy: null == handledBy
            ? _value.handledBy
            : handledBy // ignore: cast_nullable_to_non_nullable
                  as String,
        clearanceFeeGhs: freezed == clearanceFeeGhs
            ? _value.clearanceFeeGhs
            : clearanceFeeGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        icumsRef: freezed == icumsRef
            ? _value.icumsRef
            : icumsRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        clearingAgentName: freezed == clearingAgentName
            ? _value.clearingAgentName
            : clearingAgentName // ignore: cast_nullable_to_non_nullable
                  as String?,
        dutyAmountGhs: freezed == dutyAmountGhs
            ? _value.dutyAmountGhs
            : dutyAmountGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        vatGhs: freezed == vatGhs
            ? _value.vatGhs
            : vatGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        nhilGhs: freezed == nhilGhs
            ? _value.nhilGhs
            : nhilGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        otherLeviesGhs: freezed == otherLeviesGhs
            ? _value.otherLeviesGhs
            : otherLeviesGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        totalPayableGhs: freezed == totalPayableGhs
            ? _value.totalPayableGhs
            : totalPayableGhs // ignore: cast_nullable_to_non_nullable
                  as double?,
        graStatus: null == graStatus
            ? _value.graStatus
            : graStatus // ignore: cast_nullable_to_non_nullable
                  as GraStatus,
        submittedAt: freezed == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        assessedAt: freezed == assessedAt
            ? _value.assessedAt
            : assessedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        paidAt: freezed == paidAt
            ? _value.paidAt
            : paidAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        clearedAt: freezed == clearedAt
            ? _value.clearedAt
            : clearedAt // ignore: cast_nullable_to_non_nullable
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
class _$DutyClearanceModelImpl implements _DutyClearanceModel {
  const _$DutyClearanceModelImpl({
    required this.id,
    required this.orderId,
    this.handledBy = 'agent',
    this.clearanceFeeGhs,
    this.icumsRef,
    this.clearingAgentName,
    this.dutyAmountGhs,
    this.vatGhs,
    this.nhilGhs,
    this.otherLeviesGhs,
    this.totalPayableGhs,
    @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
    this.graStatus = GraStatus.notStarted,
    this.submittedAt,
    this.assessedAt,
    this.paidAt,
    this.clearedAt,
    this.notes,
    this.createdAt,
  });

  factory _$DutyClearanceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DutyClearanceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  @JsonKey()
  final String handledBy;
  // 'agent' | 'buyer'
  @override
  final double? clearanceFeeGhs;
  @override
  final String? icumsRef;
  @override
  final String? clearingAgentName;
  @override
  final double? dutyAmountGhs;
  @override
  final double? vatGhs;
  @override
  final double? nhilGhs;
  @override
  final double? otherLeviesGhs;
  @override
  final double? totalPayableGhs;
  @override
  @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
  final GraStatus graStatus;
  @override
  final DateTime? submittedAt;
  @override
  final DateTime? assessedAt;
  @override
  final DateTime? paidAt;
  @override
  final DateTime? clearedAt;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'DutyClearanceModel(id: $id, orderId: $orderId, handledBy: $handledBy, clearanceFeeGhs: $clearanceFeeGhs, icumsRef: $icumsRef, clearingAgentName: $clearingAgentName, dutyAmountGhs: $dutyAmountGhs, vatGhs: $vatGhs, nhilGhs: $nhilGhs, otherLeviesGhs: $otherLeviesGhs, totalPayableGhs: $totalPayableGhs, graStatus: $graStatus, submittedAt: $submittedAt, assessedAt: $assessedAt, paidAt: $paidAt, clearedAt: $clearedAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DutyClearanceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.handledBy, handledBy) ||
                other.handledBy == handledBy) &&
            (identical(other.clearanceFeeGhs, clearanceFeeGhs) ||
                other.clearanceFeeGhs == clearanceFeeGhs) &&
            (identical(other.icumsRef, icumsRef) ||
                other.icumsRef == icumsRef) &&
            (identical(other.clearingAgentName, clearingAgentName) ||
                other.clearingAgentName == clearingAgentName) &&
            (identical(other.dutyAmountGhs, dutyAmountGhs) ||
                other.dutyAmountGhs == dutyAmountGhs) &&
            (identical(other.vatGhs, vatGhs) || other.vatGhs == vatGhs) &&
            (identical(other.nhilGhs, nhilGhs) || other.nhilGhs == nhilGhs) &&
            (identical(other.otherLeviesGhs, otherLeviesGhs) ||
                other.otherLeviesGhs == otherLeviesGhs) &&
            (identical(other.totalPayableGhs, totalPayableGhs) ||
                other.totalPayableGhs == totalPayableGhs) &&
            (identical(other.graStatus, graStatus) ||
                other.graStatus == graStatus) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.assessedAt, assessedAt) ||
                other.assessedAt == assessedAt) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.clearedAt, clearedAt) ||
                other.clearedAt == clearedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    handledBy,
    clearanceFeeGhs,
    icumsRef,
    clearingAgentName,
    dutyAmountGhs,
    vatGhs,
    nhilGhs,
    otherLeviesGhs,
    totalPayableGhs,
    graStatus,
    submittedAt,
    assessedAt,
    paidAt,
    clearedAt,
    notes,
    createdAt,
  );

  /// Create a copy of DutyClearanceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DutyClearanceModelImplCopyWith<_$DutyClearanceModelImpl> get copyWith =>
      __$$DutyClearanceModelImplCopyWithImpl<_$DutyClearanceModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DutyClearanceModelImplToJson(this);
  }
}

abstract class _DutyClearanceModel implements DutyClearanceModel {
  const factory _DutyClearanceModel({
    required final String id,
    required final String orderId,
    final String handledBy,
    final double? clearanceFeeGhs,
    final String? icumsRef,
    final String? clearingAgentName,
    final double? dutyAmountGhs,
    final double? vatGhs,
    final double? nhilGhs,
    final double? otherLeviesGhs,
    final double? totalPayableGhs,
    @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
    final GraStatus graStatus,
    final DateTime? submittedAt,
    final DateTime? assessedAt,
    final DateTime? paidAt,
    final DateTime? clearedAt,
    final String? notes,
    final DateTime? createdAt,
  }) = _$DutyClearanceModelImpl;

  factory _DutyClearanceModel.fromJson(Map<String, dynamic> json) =
      _$DutyClearanceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get handledBy; // 'agent' | 'buyer'
  @override
  double? get clearanceFeeGhs;
  @override
  String? get icumsRef;
  @override
  String? get clearingAgentName;
  @override
  double? get dutyAmountGhs;
  @override
  double? get vatGhs;
  @override
  double? get nhilGhs;
  @override
  double? get otherLeviesGhs;
  @override
  double? get totalPayableGhs;
  @override
  @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
  GraStatus get graStatus;
  @override
  DateTime? get submittedAt;
  @override
  DateTime? get assessedAt;
  @override
  DateTime? get paidAt;
  @override
  DateTime? get clearedAt;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;

  /// Create a copy of DutyClearanceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DutyClearanceModelImplCopyWith<_$DutyClearanceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
