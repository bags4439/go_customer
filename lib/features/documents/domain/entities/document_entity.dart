/// A single document in the order documents vault.
/// Read from Firestore; fileUrl is a Storage path for download URL fetch.
class DocumentEntity {
  final String id;
  final String orderId;
  final String uploadedByUserId;
  final String uploadedByRole;
  final String docType;
  final String label;
  final String? fileUrl;
  final String? fileType;
  final int? fileSizeKb;
  final String? vin;
  final String status;
  final String? rejectionReason;
  final bool isAutoPopulated;
  final String? notes;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;

  const DocumentEntity({
    required this.id,
    required this.orderId,
    required this.uploadedByUserId,
    required this.uploadedByRole,
    required this.docType,
    required this.label,
    this.fileUrl,
    this.fileType,
    this.fileSizeKb,
    this.vin,
    required this.status,
    this.rejectionReason,
    required this.isAutoPopulated,
    this.notes,
    this.uploadedAt,
    this.verifiedAt,
  });

  bool get isVerified => status == 'verified';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isNotStarted => status == 'not_started';
}
