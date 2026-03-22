// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inactivity_reminder_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InactivityReminderModel _$InactivityReminderModelFromJson(
  Map<String, dynamic> json,
) {
  return _InactivityReminderModel.fromJson(json);
}

/// @nodoc
mixin _$InactivityReminderModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get agentId => throw _privateConstructorUsedError;
  int get reminderLevel => throw _privateConstructorUsedError;
  DateTime? get triggeredAt => throw _privateConstructorUsedError;
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  String get actionTaken => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this InactivityReminderModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InactivityReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InactivityReminderModelCopyWith<InactivityReminderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InactivityReminderModelCopyWith<$Res> {
  factory $InactivityReminderModelCopyWith(
    InactivityReminderModel value,
    $Res Function(InactivityReminderModel) then,
  ) = _$InactivityReminderModelCopyWithImpl<$Res, InactivityReminderModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String agentId,
    int reminderLevel,
    DateTime? triggeredAt,
    DateTime? resolvedAt,
    String actionTaken,
    String? notes,
  });
}

/// @nodoc
class _$InactivityReminderModelCopyWithImpl<
  $Res,
  $Val extends InactivityReminderModel
>
    implements $InactivityReminderModelCopyWith<$Res> {
  _$InactivityReminderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InactivityReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? agentId = null,
    Object? reminderLevel = null,
    Object? triggeredAt = freezed,
    Object? resolvedAt = freezed,
    Object? actionTaken = null,
    Object? notes = freezed,
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
            reminderLevel: null == reminderLevel
                ? _value.reminderLevel
                : reminderLevel // ignore: cast_nullable_to_non_nullable
                      as int,
            triggeredAt: freezed == triggeredAt
                ? _value.triggeredAt
                : triggeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            resolvedAt: freezed == resolvedAt
                ? _value.resolvedAt
                : resolvedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            actionTaken: null == actionTaken
                ? _value.actionTaken
                : actionTaken // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InactivityReminderModelImplCopyWith<$Res>
    implements $InactivityReminderModelCopyWith<$Res> {
  factory _$$InactivityReminderModelImplCopyWith(
    _$InactivityReminderModelImpl value,
    $Res Function(_$InactivityReminderModelImpl) then,
  ) = __$$InactivityReminderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String agentId,
    int reminderLevel,
    DateTime? triggeredAt,
    DateTime? resolvedAt,
    String actionTaken,
    String? notes,
  });
}

/// @nodoc
class __$$InactivityReminderModelImplCopyWithImpl<$Res>
    extends
        _$InactivityReminderModelCopyWithImpl<
          $Res,
          _$InactivityReminderModelImpl
        >
    implements _$$InactivityReminderModelImplCopyWith<$Res> {
  __$$InactivityReminderModelImplCopyWithImpl(
    _$InactivityReminderModelImpl _value,
    $Res Function(_$InactivityReminderModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InactivityReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? agentId = null,
    Object? reminderLevel = null,
    Object? triggeredAt = freezed,
    Object? resolvedAt = freezed,
    Object? actionTaken = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$InactivityReminderModelImpl(
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
        reminderLevel: null == reminderLevel
            ? _value.reminderLevel
            : reminderLevel // ignore: cast_nullable_to_non_nullable
                  as int,
        triggeredAt: freezed == triggeredAt
            ? _value.triggeredAt
            : triggeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resolvedAt: freezed == resolvedAt
            ? _value.resolvedAt
            : resolvedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        actionTaken: null == actionTaken
            ? _value.actionTaken
            : actionTaken // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InactivityReminderModelImpl implements _InactivityReminderModel {
  const _$InactivityReminderModelImpl({
    required this.id,
    required this.orderId,
    required this.agentId,
    required this.reminderLevel,
    this.triggeredAt,
    this.resolvedAt,
    this.actionTaken = 'none',
    this.notes,
  });

  factory _$InactivityReminderModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InactivityReminderModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String agentId;
  @override
  final int reminderLevel;
  @override
  final DateTime? triggeredAt;
  @override
  final DateTime? resolvedAt;
  @override
  @JsonKey()
  final String actionTaken;
  @override
  final String? notes;

  @override
  String toString() {
    return 'InactivityReminderModel(id: $id, orderId: $orderId, agentId: $agentId, reminderLevel: $reminderLevel, triggeredAt: $triggeredAt, resolvedAt: $resolvedAt, actionTaken: $actionTaken, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InactivityReminderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.agentId, agentId) || other.agentId == agentId) &&
            (identical(other.reminderLevel, reminderLevel) ||
                other.reminderLevel == reminderLevel) &&
            (identical(other.triggeredAt, triggeredAt) ||
                other.triggeredAt == triggeredAt) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.actionTaken, actionTaken) ||
                other.actionTaken == actionTaken) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    agentId,
    reminderLevel,
    triggeredAt,
    resolvedAt,
    actionTaken,
    notes,
  );

  /// Create a copy of InactivityReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InactivityReminderModelImplCopyWith<_$InactivityReminderModelImpl>
  get copyWith =>
      __$$InactivityReminderModelImplCopyWithImpl<
        _$InactivityReminderModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InactivityReminderModelImplToJson(this);
  }
}

abstract class _InactivityReminderModel implements InactivityReminderModel {
  const factory _InactivityReminderModel({
    required final String id,
    required final String orderId,
    required final String agentId,
    required final int reminderLevel,
    final DateTime? triggeredAt,
    final DateTime? resolvedAt,
    final String actionTaken,
    final String? notes,
  }) = _$InactivityReminderModelImpl;

  factory _InactivityReminderModel.fromJson(Map<String, dynamic> json) =
      _$InactivityReminderModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get agentId;
  @override
  int get reminderLevel;
  @override
  DateTime? get triggeredAt;
  @override
  DateTime? get resolvedAt;
  @override
  String get actionTaken;
  @override
  String? get notes;

  /// Create a copy of InactivityReminderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InactivityReminderModelImplCopyWith<_$InactivityReminderModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
