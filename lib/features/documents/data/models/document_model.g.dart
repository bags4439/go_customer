// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentModelImpl _$$DocumentModelImplFromJson(Map<String, dynamic> json) =>
    _$DocumentModelImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      uploadedByUserId: json['uploadedByUserId'] as String?,
      uploadedByRole: json['uploadedByRole'] as String?,
      docType: json['docType'] as String,
      label: json['label'] as String?,
      fileUrl: json['fileUrl'] as String?,
      fileType: json['fileType'] as String?,
      fileSizeKb: (json['fileSizeKb'] as num?)?.toInt(),
      vin: json['vin'] as String?,
      status: json['status'] as String? ?? 'not_started',
      rejectionReason: json['rejectionReason'] as String?,
      isAutoPopulated: json['isAutoPopulated'] as bool? ?? false,
      notes: json['notes'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
    );

Map<String, dynamic> _$$DocumentModelImplToJson(_$DocumentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'uploadedByUserId': instance.uploadedByUserId,
      'uploadedByRole': instance.uploadedByRole,
      'docType': instance.docType,
      'label': instance.label,
      'fileUrl': instance.fileUrl,
      'fileType': instance.fileType,
      'fileSizeKb': instance.fileSizeKb,
      'vin': instance.vin,
      'status': instance.status,
      'rejectionReason': instance.rejectionReason,
      'isAutoPopulated': instance.isAutoPopulated,
      'notes': instance.notes,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
    };
