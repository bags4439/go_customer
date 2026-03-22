// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'garage_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GarageModel _$GarageModelFromJson(Map<String, dynamic> json) {
  return _GarageModel.fromJson(json);
}

/// @nodoc
mixin _$GarageModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool get isVetted => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get totalJobs => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get specialisations => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get addedAt => throw _privateConstructorUsedError;

  /// Serializes this GarageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GarageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GarageModelCopyWith<GarageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GarageModelCopyWith<$Res> {
  factory $GarageModelCopyWith(
    GarageModel value,
    $Res Function(GarageModel) then,
  ) = _$GarageModelCopyWithImpl<$Res, GarageModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? location,
    String? city,
    String? phone,
    String? email,
    bool isVetted,
    double rating,
    int totalJobs,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? specialisations,
    bool isActive,
    DateTime? addedAt,
  });
}

/// @nodoc
class _$GarageModelCopyWithImpl<$Res, $Val extends GarageModel>
    implements $GarageModelCopyWith<$Res> {
  _$GarageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GarageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? city = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isVetted = null,
    Object? rating = null,
    Object? totalJobs = null,
    Object? specialisations = freezed,
    Object? isActive = null,
    Object? addedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            isVetted: null == isVetted
                ? _value.isVetted
                : isVetted // ignore: cast_nullable_to_non_nullable
                      as bool,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            totalJobs: null == totalJobs
                ? _value.totalJobs
                : totalJobs // ignore: cast_nullable_to_non_nullable
                      as int,
            specialisations: freezed == specialisations
                ? _value.specialisations
                : specialisations // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            addedAt: freezed == addedAt
                ? _value.addedAt
                : addedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GarageModelImplCopyWith<$Res>
    implements $GarageModelCopyWith<$Res> {
  factory _$$GarageModelImplCopyWith(
    _$GarageModelImpl value,
    $Res Function(_$GarageModelImpl) then,
  ) = __$$GarageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? location,
    String? city,
    String? phone,
    String? email,
    bool isVetted,
    double rating,
    int totalJobs,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    List<String>? specialisations,
    bool isActive,
    DateTime? addedAt,
  });
}

/// @nodoc
class __$$GarageModelImplCopyWithImpl<$Res>
    extends _$GarageModelCopyWithImpl<$Res, _$GarageModelImpl>
    implements _$$GarageModelImplCopyWith<$Res> {
  __$$GarageModelImplCopyWithImpl(
    _$GarageModelImpl _value,
    $Res Function(_$GarageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GarageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? location = freezed,
    Object? city = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? isVetted = null,
    Object? rating = null,
    Object? totalJobs = null,
    Object? specialisations = freezed,
    Object? isActive = null,
    Object? addedAt = freezed,
  }) {
    return _then(
      _$GarageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        isVetted: null == isVetted
            ? _value.isVetted
            : isVetted // ignore: cast_nullable_to_non_nullable
                  as bool,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        totalJobs: null == totalJobs
            ? _value.totalJobs
            : totalJobs // ignore: cast_nullable_to_non_nullable
                  as int,
        specialisations: freezed == specialisations
            ? _value._specialisations
            : specialisations // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        addedAt: freezed == addedAt
            ? _value.addedAt
            : addedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GarageModelImpl implements _GarageModel {
  const _$GarageModelImpl({
    required this.id,
    required this.name,
    this.location,
    this.city,
    this.phone,
    this.email,
    this.isVetted = false,
    this.rating = 0.0,
    this.totalJobs = 0,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? specialisations,
    this.isActive = true,
    this.addedAt,
  }) : _specialisations = specialisations;

  factory _$GarageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GarageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? location;
  @override
  final String? city;
  @override
  final String? phone;
  @override
  final String? email;
  @override
  @JsonKey()
  final bool isVetted;
  @override
  @JsonKey()
  final double rating;
  @override
  @JsonKey()
  final int totalJobs;
  final List<String>? _specialisations;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get specialisations {
    final value = _specialisations;
    if (value == null) return null;
    if (_specialisations is EqualUnmodifiableListView) return _specialisations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? addedAt;

  @override
  String toString() {
    return 'GarageModel(id: $id, name: $name, location: $location, city: $city, phone: $phone, email: $email, isVetted: $isVetted, rating: $rating, totalJobs: $totalJobs, specialisations: $specialisations, isActive: $isActive, addedAt: $addedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GarageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isVetted, isVetted) ||
                other.isVetted == isVetted) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.totalJobs, totalJobs) ||
                other.totalJobs == totalJobs) &&
            const DeepCollectionEquality().equals(
              other._specialisations,
              _specialisations,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.addedAt, addedAt) || other.addedAt == addedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    location,
    city,
    phone,
    email,
    isVetted,
    rating,
    totalJobs,
    const DeepCollectionEquality().hash(_specialisations),
    isActive,
    addedAt,
  );

  /// Create a copy of GarageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GarageModelImplCopyWith<_$GarageModelImpl> get copyWith =>
      __$$GarageModelImplCopyWithImpl<_$GarageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GarageModelImplToJson(this);
  }
}

abstract class _GarageModel implements GarageModel {
  const factory _GarageModel({
    required final String id,
    required final String name,
    final String? location,
    final String? city,
    final String? phone,
    final String? email,
    final bool isVetted,
    final double rating,
    final int totalJobs,
    @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
    final List<String>? specialisations,
    final bool isActive,
    final DateTime? addedAt,
  }) = _$GarageModelImpl;

  factory _GarageModel.fromJson(Map<String, dynamic> json) =
      _$GarageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get location;
  @override
  String? get city;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  bool get isVetted;
  @override
  double get rating;
  @override
  int get totalJobs;
  @override
  @JsonKey(fromJson: _stringListFromJson, toJson: _stringListToJson)
  List<String>? get specialisations;
  @override
  bool get isActive;
  @override
  DateTime? get addedAt;

  /// Create a copy of GarageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GarageModelImplCopyWith<_$GarageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
