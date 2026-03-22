// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preference_edit_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PreferenceEditHistoryModel _$PreferenceEditHistoryModelFromJson(
  Map<String, dynamic> json,
) {
  return _PreferenceEditHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$PreferenceEditHistoryModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get editedByUserId => throw _privateConstructorUsedError;
  String get editedByRole =>
      throw _privateConstructorUsedError; // 'buyer' | 'agent'
  Map<String, dynamic>? get previousValuesJson =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get newValuesJson => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  bool get buyerNotified => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;

  /// Serializes this PreferenceEditHistoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreferenceEditHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreferenceEditHistoryModelCopyWith<PreferenceEditHistoryModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferenceEditHistoryModelCopyWith<$Res> {
  factory $PreferenceEditHistoryModelCopyWith(
    PreferenceEditHistoryModel value,
    $Res Function(PreferenceEditHistoryModel) then,
  ) =
      _$PreferenceEditHistoryModelCopyWithImpl<
        $Res,
        PreferenceEditHistoryModel
      >;
  @useResult
  $Res call({
    String id,
    String orderId,
    String editedByUserId,
    String editedByRole,
    Map<String, dynamic>? previousValuesJson,
    Map<String, dynamic>? newValuesJson,
    String? reason,
    bool buyerNotified,
    DateTime? editedAt,
  });
}

/// @nodoc
class _$PreferenceEditHistoryModelCopyWithImpl<
  $Res,
  $Val extends PreferenceEditHistoryModel
>
    implements $PreferenceEditHistoryModelCopyWith<$Res> {
  _$PreferenceEditHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreferenceEditHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? editedByUserId = null,
    Object? editedByRole = null,
    Object? previousValuesJson = freezed,
    Object? newValuesJson = freezed,
    Object? reason = freezed,
    Object? buyerNotified = null,
    Object? editedAt = freezed,
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
            editedByUserId: null == editedByUserId
                ? _value.editedByUserId
                : editedByUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            editedByRole: null == editedByRole
                ? _value.editedByRole
                : editedByRole // ignore: cast_nullable_to_non_nullable
                      as String,
            previousValuesJson: freezed == previousValuesJson
                ? _value.previousValuesJson
                : previousValuesJson // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newValuesJson: freezed == newValuesJson
                ? _value.newValuesJson
                : newValuesJson // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            reason: freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                      as String?,
            buyerNotified: null == buyerNotified
                ? _value.buyerNotified
                : buyerNotified // ignore: cast_nullable_to_non_nullable
                      as bool,
            editedAt: freezed == editedAt
                ? _value.editedAt
                : editedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PreferenceEditHistoryModelImplCopyWith<$Res>
    implements $PreferenceEditHistoryModelCopyWith<$Res> {
  factory _$$PreferenceEditHistoryModelImplCopyWith(
    _$PreferenceEditHistoryModelImpl value,
    $Res Function(_$PreferenceEditHistoryModelImpl) then,
  ) = __$$PreferenceEditHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String editedByUserId,
    String editedByRole,
    Map<String, dynamic>? previousValuesJson,
    Map<String, dynamic>? newValuesJson,
    String? reason,
    bool buyerNotified,
    DateTime? editedAt,
  });
}

/// @nodoc
class __$$PreferenceEditHistoryModelImplCopyWithImpl<$Res>
    extends
        _$PreferenceEditHistoryModelCopyWithImpl<
          $Res,
          _$PreferenceEditHistoryModelImpl
        >
    implements _$$PreferenceEditHistoryModelImplCopyWith<$Res> {
  __$$PreferenceEditHistoryModelImplCopyWithImpl(
    _$PreferenceEditHistoryModelImpl _value,
    $Res Function(_$PreferenceEditHistoryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PreferenceEditHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? editedByUserId = null,
    Object? editedByRole = null,
    Object? previousValuesJson = freezed,
    Object? newValuesJson = freezed,
    Object? reason = freezed,
    Object? buyerNotified = null,
    Object? editedAt = freezed,
  }) {
    return _then(
      _$PreferenceEditHistoryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        editedByUserId: null == editedByUserId
            ? _value.editedByUserId
            : editedByUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        editedByRole: null == editedByRole
            ? _value.editedByRole
            : editedByRole // ignore: cast_nullable_to_non_nullable
                  as String,
        previousValuesJson: freezed == previousValuesJson
            ? _value._previousValuesJson
            : previousValuesJson // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newValuesJson: freezed == newValuesJson
            ? _value._newValuesJson
            : newValuesJson // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        reason: freezed == reason
            ? _value.reason
            : reason // ignore: cast_nullable_to_non_nullable
                  as String?,
        buyerNotified: null == buyerNotified
            ? _value.buyerNotified
            : buyerNotified // ignore: cast_nullable_to_non_nullable
                  as bool,
        editedAt: freezed == editedAt
            ? _value.editedAt
            : editedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferenceEditHistoryModelImpl implements _PreferenceEditHistoryModel {
  const _$PreferenceEditHistoryModelImpl({
    required this.id,
    required this.orderId,
    required this.editedByUserId,
    required this.editedByRole,
    final Map<String, dynamic>? previousValuesJson,
    final Map<String, dynamic>? newValuesJson,
    this.reason,
    this.buyerNotified = false,
    this.editedAt,
  }) : _previousValuesJson = previousValuesJson,
       _newValuesJson = newValuesJson;

  factory _$PreferenceEditHistoryModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PreferenceEditHistoryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String editedByUserId;
  @override
  final String editedByRole;
  // 'buyer' | 'agent'
  final Map<String, dynamic>? _previousValuesJson;
  // 'buyer' | 'agent'
  @override
  Map<String, dynamic>? get previousValuesJson {
    final value = _previousValuesJson;
    if (value == null) return null;
    if (_previousValuesJson is EqualUnmodifiableMapView)
      return _previousValuesJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValuesJson;
  @override
  Map<String, dynamic>? get newValuesJson {
    final value = _newValuesJson;
    if (value == null) return null;
    if (_newValuesJson is EqualUnmodifiableMapView) return _newValuesJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? reason;
  @override
  @JsonKey()
  final bool buyerNotified;
  @override
  final DateTime? editedAt;

  @override
  String toString() {
    return 'PreferenceEditHistoryModel(id: $id, orderId: $orderId, editedByUserId: $editedByUserId, editedByRole: $editedByRole, previousValuesJson: $previousValuesJson, newValuesJson: $newValuesJson, reason: $reason, buyerNotified: $buyerNotified, editedAt: $editedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferenceEditHistoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.editedByUserId, editedByUserId) ||
                other.editedByUserId == editedByUserId) &&
            (identical(other.editedByRole, editedByRole) ||
                other.editedByRole == editedByRole) &&
            const DeepCollectionEquality().equals(
              other._previousValuesJson,
              _previousValuesJson,
            ) &&
            const DeepCollectionEquality().equals(
              other._newValuesJson,
              _newValuesJson,
            ) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.buyerNotified, buyerNotified) ||
                other.buyerNotified == buyerNotified) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    editedByUserId,
    editedByRole,
    const DeepCollectionEquality().hash(_previousValuesJson),
    const DeepCollectionEquality().hash(_newValuesJson),
    reason,
    buyerNotified,
    editedAt,
  );

  /// Create a copy of PreferenceEditHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferenceEditHistoryModelImplCopyWith<_$PreferenceEditHistoryModelImpl>
  get copyWith =>
      __$$PreferenceEditHistoryModelImplCopyWithImpl<
        _$PreferenceEditHistoryModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferenceEditHistoryModelImplToJson(this);
  }
}

abstract class _PreferenceEditHistoryModel
    implements PreferenceEditHistoryModel {
  const factory _PreferenceEditHistoryModel({
    required final String id,
    required final String orderId,
    required final String editedByUserId,
    required final String editedByRole,
    final Map<String, dynamic>? previousValuesJson,
    final Map<String, dynamic>? newValuesJson,
    final String? reason,
    final bool buyerNotified,
    final DateTime? editedAt,
  }) = _$PreferenceEditHistoryModelImpl;

  factory _PreferenceEditHistoryModel.fromJson(Map<String, dynamic> json) =
      _$PreferenceEditHistoryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get editedByUserId;
  @override
  String get editedByRole; // 'buyer' | 'agent'
  @override
  Map<String, dynamic>? get previousValuesJson;
  @override
  Map<String, dynamic>? get newValuesJson;
  @override
  String? get reason;
  @override
  bool get buyerNotified;
  @override
  DateTime? get editedAt;

  /// Create a copy of PreferenceEditHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreferenceEditHistoryModelImplCopyWith<_$PreferenceEditHistoryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
