// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/repair_job.dart';

part 'repair_job_model.freezed.dart';
part 'repair_job_model.g.dart';

enum RepairStatus {
  notStarted,
  quoteSent,
  quoteApproved,
  quoteDeclined,
  inProgress,
  completed;

  static RepairStatus fromString(String v) {
    const map = <String, RepairStatus>{
      'not_started': RepairStatus.notStarted,
      'quote_sent': RepairStatus.quoteSent,
      'quote_approved': RepairStatus.quoteApproved,
      'quote_declined': RepairStatus.quoteDeclined,
      'in_progress': RepairStatus.inProgress,
      'completed': RepairStatus.completed,
    };
    return map[v] ?? RepairStatus.notStarted;
  }

  String get firestoreValue {
    const map = <RepairStatus, String>{
      RepairStatus.notStarted: 'not_started',
      RepairStatus.quoteSent: 'quote_sent',
      RepairStatus.quoteApproved: 'quote_approved',
      RepairStatus.quoteDeclined: 'quote_declined',
      RepairStatus.inProgress: 'in_progress',
      RepairStatus.completed: 'completed',
    };
    return map[this] ?? 'not_started';
  }
}

RepairStatus _repairStatusFromJson(Object? json) =>
    RepairStatus.fromString(json as String? ?? 'not_started');

String _repairStatusToJson(RepairStatus s) => s.firestoreValue;

List<String>? _stringListFromJson(Object? json) {
  if (json == null) return null;
  if (json is List) {
    return json.map((e) => e.toString()).toList();
  }
  return null;
}

Object? _stringListToJson(List<String>? list) => list;

DateTime? _dateTimeFromJson(Object? v) {
  if (v == null) return null;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

Object? _dateTimeToJson(DateTime? d) => d?.toIso8601String();

@freezed
class RepairJobModel with _$RepairJobModel {
  const factory RepairJobModel({
    required String id,
    required String orderId,
    @Default(true) bool optedIn,
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
    @Default(false) bool quoteApprovedByBuyer,
    DateTime? quoteApprovedAt,
    DateTime? quoteDeclinedAt,
    String? depositPaymentRequestId,
    String? balancePaymentRequestId,
    @Default(false) bool depositPaid,
    @Default(false) bool balancePaid,
    @JsonKey(fromJson: _repairStatusFromJson, toJson: _repairStatusToJson)
    @Default(RepairStatus.notStarted)
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
  }) = _RepairJobModel;

  factory RepairJobModel.fromJson(Map<String, dynamic> json) =>
      _$RepairJobModelFromJson(json);

  factory RepairJobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return RepairJobModel(id: doc.id, orderId: '');
    }
    List<String>? parsePhotos(dynamic raw) {
      if (raw == null) return null;
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return null;
    }

    return RepairJobModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      optedIn: data['optedIn'] as bool? ?? false,
      garageId: data['garageId'] as String?,
      garageNameCustom: data['garageNameCustom'] as String?,
      garageLocation: data['garageLocation'] as String?,
      workDescription: data['workDescription'] as String?,
      invoiceImageUrl: data['invoiceImageUrl'] as String?,
      invoiceRefNumber: data['invoiceRefNumber'] as String?,
      invoiceDate:
          (data['invoiceDate'] as Timestamp?)?.toDate(),
      totalInvoiceGhs:
          (data['totalInvoiceGhs'] as num?)?.toDouble(),
      partsDepositGhs:
          (data['partsDepositGhs'] as num?)?.toDouble(),
      workmanshipBalanceGhs:
          (data['workmanshipBalanceGhs'] as num?)?.toDouble(),
      platformFeeGhs:
          (data['platformFeeGhs'] as num?)?.toDouble(),
      quoteGhs: (data['quoteGhs'] as num?)?.toDouble(),
      platformServiceFeeGhs:
          (data['platformServiceFeeGhs'] as num?)?.toDouble(),
      totalQuotedGhs:
          (data['totalQuotedGhs'] as num?)?.toDouble(),
      finalCostGhs: (data['finalCostGhs'] as num?)?.toDouble(),
      quoteApprovedByBuyer:
          data['quoteApprovedByBuyer'] as bool? ?? false,
      quoteApprovedAt:
          (data['quoteApprovedAt'] as Timestamp?)?.toDate(),
      quoteDeclinedAt:
          (data['quoteDeclinedAt'] as Timestamp?)?.toDate(),
      depositPaymentRequestId:
          data['depositPaymentRequestId'] as String?,
      balancePaymentRequestId:
          data['balancePaymentRequestId'] as String?,
      depositPaid: data['depositPaid'] as bool? ?? false,
      balancePaid: data['balancePaid'] as bool? ?? false,
      status: RepairStatus.fromString(
        data['status'] as String? ?? 'not_started',
      ),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      estimatedCompletion:
          (data['estimatedCompletion'] as Timestamp?)?.toDate(),
      actualCompletion:
          (data['actualCompletion'] as Timestamp?)?.toDate(),
      beforePhotoUrlsJson:
          parsePhotos(data['beforePhotoUrlsJson']),
      afterPhotoUrlsJson:
          parsePhotos(data['afterPhotoUrlsJson']),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

RepairJob repairJobFromDoc(DocumentSnapshot doc) {
  final m = RepairJobModel.fromFirestore(doc);
  return RepairJob(
    id: m.id,
    orderId: m.orderId,
    optedIn: m.optedIn,
    garageId: m.garageId,
    garageNameCustom: m.garageNameCustom,
    garageLocation: m.garageLocation,
    workDescription: m.workDescription,
    totalInvoiceGhs: m.totalInvoiceGhs,
    partsDepositGhs: m.partsDepositGhs,
    workmanshipBalanceGhs: m.workmanshipBalanceGhs,
    platformFeeGhs: m.platformFeeGhs,
    quoteGhs: m.quoteGhs,
    platformServiceFeeGhs: m.platformServiceFeeGhs,
    totalQuotedGhs: m.totalQuotedGhs,
    finalCostGhs: m.finalCostGhs,
    quoteApprovedByBuyer: m.quoteApprovedByBuyer,
    quoteApprovedAt: m.quoteApprovedAt,
    quoteDeclinedAt: m.quoteDeclinedAt,
    depositPaymentRequestId: m.depositPaymentRequestId,
    balancePaymentRequestId: m.balancePaymentRequestId,
    depositPaid: m.depositPaid,
    balancePaid: m.balancePaid,
    status: m.status.firestoreValue,
    startDate: m.startDate,
    estimatedCompletion: m.estimatedCompletion,
    actualCompletion: m.actualCompletion,
    beforePhotoUrls: m.beforePhotoUrlsJson ?? const [],
    afterPhotoUrls: m.afterPhotoUrlsJson ?? const [],
    notes: m.notes,
    createdAt: m.createdAt,
  );
}
