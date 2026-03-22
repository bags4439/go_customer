// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) {
  return _DocumentModel.fromJson(json);
}

/// @nodoc
mixin _$DocumentModel {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get uploadedByUserId => throw _privateConstructorUsedError;
  String? get uploadedByRole => throw _privateConstructorUsedError;
  String get docType => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  String? get fileUrl => throw _privateConstructorUsedError;
  String? get fileType => throw _privateConstructorUsedError;
  int? get fileSizeKb => throw _privateConstructorUsedError;
  String? get vin => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  bool get isAutoPopulated => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get uploadedAt => throw _privateConstructorUsedError;
  DateTime? get verifiedAt => throw _privateConstructorUsedError;

  /// Serializes this DocumentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DocumentModelCopyWith<DocumentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentModelCopyWith<$Res> {
  factory $DocumentModelCopyWith(
    DocumentModel value,
    $Res Function(DocumentModel) then,
  ) = _$DocumentModelCopyWithImpl<$Res, DocumentModel>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String? uploadedByUserId,
    String? uploadedByRole,
    String docType,
    String? label,
    String? fileUrl,
    String? fileType,
    int? fileSizeKb,
    String? vin,
    String status,
    String? rejectionReason,
    bool isAutoPopulated,
    String? notes,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
  });
}

/// @nodoc
class _$DocumentModelCopyWithImpl<$Res, $Val extends DocumentModel>
    implements $DocumentModelCopyWith<$Res> {
  _$DocumentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? uploadedByUserId = freezed,
    Object? uploadedByRole = freezed,
    Object? docType = null,
    Object? label = freezed,
    Object? fileUrl = freezed,
    Object? fileType = freezed,
    Object? fileSizeKb = freezed,
    Object? vin = freezed,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? isAutoPopulated = null,
    Object? notes = freezed,
    Object? uploadedAt = freezed,
    Object? verifiedAt = freezed,
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
            uploadedByUserId: freezed == uploadedByUserId
                ? _value.uploadedByUserId
                : uploadedByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedByRole: freezed == uploadedByRole
                ? _value.uploadedByRole
                : uploadedByRole // ignore: cast_nullable_to_non_nullable
                      as String?,
            docType: null == docType
                ? _value.docType
                : docType // ignore: cast_nullable_to_non_nullable
                      as String,
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileUrl: freezed == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileType: freezed == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSizeKb: freezed == fileSizeKb
                ? _value.fileSizeKb
                : fileSizeKb // ignore: cast_nullable_to_non_nullable
                      as int?,
            vin: freezed == vin
                ? _value.vin
                : vin // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            rejectionReason: freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAutoPopulated: null == isAutoPopulated
                ? _value.isAutoPopulated
                : isAutoPopulated // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            uploadedAt: freezed == uploadedAt
                ? _value.uploadedAt
                : uploadedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            verifiedAt: freezed == verifiedAt
                ? _value.verifiedAt
                : verifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DocumentModelImplCopyWith<$Res>
    implements $DocumentModelCopyWith<$Res> {
  factory _$$DocumentModelImplCopyWith(
    _$DocumentModelImpl value,
    $Res Function(_$DocumentModelImpl) then,
  ) = __$$DocumentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String? uploadedByUserId,
    String? uploadedByRole,
    String docType,
    String? label,
    String? fileUrl,
    String? fileType,
    int? fileSizeKb,
    String? vin,
    String status,
    String? rejectionReason,
    bool isAutoPopulated,
    String? notes,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
  });
}

/// @nodoc
class __$$DocumentModelImplCopyWithImpl<$Res>
    extends _$DocumentModelCopyWithImpl<$Res, _$DocumentModelImpl>
    implements _$$DocumentModelImplCopyWith<$Res> {
  __$$DocumentModelImplCopyWithImpl(
    _$DocumentModelImpl _value,
    $Res Function(_$DocumentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? uploadedByUserId = freezed,
    Object? uploadedByRole = freezed,
    Object? docType = null,
    Object? label = freezed,
    Object? fileUrl = freezed,
    Object? fileType = freezed,
    Object? fileSizeKb = freezed,
    Object? vin = freezed,
    Object? status = null,
    Object? rejectionReason = freezed,
    Object? isAutoPopulated = null,
    Object? notes = freezed,
    Object? uploadedAt = freezed,
    Object? verifiedAt = freezed,
  }) {
    return _then(
      _$DocumentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadedByUserId: freezed == uploadedByUserId
            ? _value.uploadedByUserId
            : uploadedByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedByRole: freezed == uploadedByRole
            ? _value.uploadedByRole
            : uploadedByRole // ignore: cast_nullable_to_non_nullable
                  as String?,
        docType: null == docType
            ? _value.docType
            : docType // ignore: cast_nullable_to_non_nullable
                  as String,
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileUrl: freezed == fileUrl
            ? _value.fileUrl
            : fileUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileType: freezed == fileType
            ? _value.fileType
            : fileType // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSizeKb: freezed == fileSizeKb
            ? _value.fileSizeKb
            : fileSizeKb // ignore: cast_nullable_to_non_nullable
                  as int?,
        vin: freezed == vin
            ? _value.vin
            : vin // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        rejectionReason: freezed == rejectionReason
            ? _value.rejectionReason
            : rejectionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAutoPopulated: null == isAutoPopulated
            ? _value.isAutoPopulated
            : isAutoPopulated // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        uploadedAt: freezed == uploadedAt
            ? _value.uploadedAt
            : uploadedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        verifiedAt: freezed == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentModelImpl implements _DocumentModel {
  const _$DocumentModelImpl({
    required this.id,
    required this.orderId,
    this.uploadedByUserId,
    this.uploadedByRole,
    required this.docType,
    this.label,
    this.fileUrl,
    this.fileType,
    this.fileSizeKb,
    this.vin,
    this.status = 'not_started',
    this.rejectionReason,
    this.isAutoPopulated = false,
    this.notes,
    this.uploadedAt,
    this.verifiedAt,
  });

  factory _$DocumentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String? uploadedByUserId;
  @override
  final String? uploadedByRole;
  @override
  final String docType;
  @override
  final String? label;
  @override
  final String? fileUrl;
  @override
  final String? fileType;
  @override
  final int? fileSizeKb;
  @override
  final String? vin;
  @override
  @JsonKey()
  final String status;
  @override
  final String? rejectionReason;
  @override
  @JsonKey()
  final bool isAutoPopulated;
  @override
  final String? notes;
  @override
  final DateTime? uploadedAt;
  @override
  final DateTime? verifiedAt;

  @override
  String toString() {
    return 'DocumentModel(id: $id, orderId: $orderId, uploadedByUserId: $uploadedByUserId, uploadedByRole: $uploadedByRole, docType: $docType, label: $label, fileUrl: $fileUrl, fileType: $fileType, fileSizeKb: $fileSizeKb, vin: $vin, status: $status, rejectionReason: $rejectionReason, isAutoPopulated: $isAutoPopulated, notes: $notes, uploadedAt: $uploadedAt, verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.uploadedByUserId, uploadedByUserId) ||
                other.uploadedByUserId == uploadedByUserId) &&
            (identical(other.uploadedByRole, uploadedByRole) ||
                other.uploadedByRole == uploadedByRole) &&
            (identical(other.docType, docType) || other.docType == docType) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSizeKb, fileSizeKb) ||
                other.fileSizeKb == fileSizeKb) &&
            (identical(other.vin, vin) || other.vin == vin) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.isAutoPopulated, isAutoPopulated) ||
                other.isAutoPopulated == isAutoPopulated) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.uploadedAt, uploadedAt) ||
                other.uploadedAt == uploadedAt) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderId,
    uploadedByUserId,
    uploadedByRole,
    docType,
    label,
    fileUrl,
    fileType,
    fileSizeKb,
    vin,
    status,
    rejectionReason,
    isAutoPopulated,
    notes,
    uploadedAt,
    verifiedAt,
  );

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      __$$DocumentModelImplCopyWithImpl<_$DocumentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentModelImplToJson(this);
  }
}

abstract class _DocumentModel implements DocumentModel {
  const factory _DocumentModel({
    required final String id,
    required final String orderId,
    final String? uploadedByUserId,
    final String? uploadedByRole,
    required final String docType,
    final String? label,
    final String? fileUrl,
    final String? fileType,
    final int? fileSizeKb,
    final String? vin,
    final String status,
    final String? rejectionReason,
    final bool isAutoPopulated,
    final String? notes,
    final DateTime? uploadedAt,
    final DateTime? verifiedAt,
  }) = _$DocumentModelImpl;

  factory _DocumentModel.fromJson(Map<String, dynamic> json) =
      _$DocumentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String? get uploadedByUserId;
  @override
  String? get uploadedByRole;
  @override
  String get docType;
  @override
  String? get label;
  @override
  String? get fileUrl;
  @override
  String? get fileType;
  @override
  int? get fileSizeKb;
  @override
  String? get vin;
  @override
  String get status;
  @override
  String? get rejectionReason;
  @override
  bool get isAutoPopulated;
  @override
  String? get notes;
  @override
  DateTime? get uploadedAt;
  @override
  DateTime? get verifiedAt;

  /// Create a copy of DocumentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DocumentModelImplCopyWith<_$DocumentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
