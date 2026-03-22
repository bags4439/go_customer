import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/document_entity.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

@freezed
class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String id,
    required String orderId,
    String? uploadedByUserId,
    String? uploadedByRole,
    required String docType,
    String? label,
    String? fileUrl,
    String? fileType,
    int? fileSizeKb,
    String? vin,
    @Default('not_started') String status,
    String? rejectionReason,
    @Default(false) bool isAutoPopulated,
    String? notes,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
  }) = _DocumentModel;

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return DocumentModel(
        id: doc.id,
        orderId: '',
        docType: 'other',
      );
    }
    return DocumentModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      uploadedByUserId: data['uploadedByUserId'] as String?,
      uploadedByRole: data['uploadedByRole'] as String?,
      docType: data['docType'] as String? ?? 'other',
      label: data['label'] as String?,
      fileUrl: data['fileUrl'] as String?,
      fileType: data['fileType'] as String?,
      fileSizeKb: data['fileSizeKb'] as int?,
      vin: data['vin'] as String?,
      status: data['status'] as String? ?? 'not_started',
      rejectionReason: data['rejectionReason'] as String?,
      isAutoPopulated: data['isAutoPopulated'] as bool? ?? false,
      notes: data['notes'] as String?,
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate(),
      verifiedAt: (data['verifiedAt'] as Timestamp?)?.toDate(),
    );
  }
}

DocumentEntity documentFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final m = DocumentModel.fromFirestore(doc);
  return DocumentEntity(
    id: m.id,
    orderId: m.orderId,
    uploadedByUserId: m.uploadedByUserId ?? '',
    uploadedByRole: m.uploadedByRole ?? 'buyer',
    docType: m.docType,
    label: m.label ?? '',
    fileUrl: m.fileUrl,
    fileType: m.fileType,
    fileSizeKb: m.fileSizeKb,
    vin: m.vin,
    status: m.status,
    rejectionReason: m.rejectionReason,
    isAutoPopulated: m.isAutoPopulated,
    notes: m.notes,
    uploadedAt: m.uploadedAt,
    verifiedAt: m.verifiedAt,
  );
}
