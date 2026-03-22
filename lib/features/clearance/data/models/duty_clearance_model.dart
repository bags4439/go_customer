// ignore_for_file: invalid_annotation_target

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/duty_clearance.dart';

part 'duty_clearance_model.freezed.dart';
part 'duty_clearance_model.g.dart';

enum GraStatus {
  notStarted,
  submitted,
  assessed,
  paid,
  cleared;

  static GraStatus fromString(String v) {
    const map = <String, GraStatus>{
      'not_started': GraStatus.notStarted,
      'submitted': GraStatus.submitted,
      'assessed': GraStatus.assessed,
      'paid': GraStatus.paid,
      'cleared': GraStatus.cleared,
    };
    return map[v] ?? GraStatus.notStarted;
  }

  String get firestoreValue {
    const map = <GraStatus, String>{
      GraStatus.notStarted: 'not_started',
      GraStatus.submitted: 'submitted',
      GraStatus.assessed: 'assessed',
      GraStatus.paid: 'paid',
      GraStatus.cleared: 'cleared',
    };
    return map[this] ?? 'not_started';
  }
}

GraStatus _graStatusFromJson(Object? json) =>
    GraStatus.fromString(json as String? ?? 'not_started');

String _graStatusToJson(GraStatus s) => s.firestoreValue;

@freezed
class DutyClearanceModel with _$DutyClearanceModel {
  const factory DutyClearanceModel({
    required String id,
    required String orderId,
    @Default('agent') String handledBy, // 'agent' | 'buyer'
    double? clearanceFeeGhs,
    String? icumsRef,
    String? clearingAgentName,
    double? dutyAmountGhs,
    double? vatGhs,
    double? nhilGhs,
    double? otherLeviesGhs,
    double? totalPayableGhs,
    @JsonKey(fromJson: _graStatusFromJson, toJson: _graStatusToJson)
    @Default(GraStatus.notStarted)
    GraStatus graStatus,
    DateTime? submittedAt,
    DateTime? assessedAt,
    DateTime? paidAt,
    DateTime? clearedAt,
    String? notes,
    DateTime? createdAt,
  }) = _DutyClearanceModel;

  factory DutyClearanceModel.fromJson(Map<String, dynamic> json) =>
      _$DutyClearanceModelFromJson(json);

  factory DutyClearanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return DutyClearanceModel(id: doc.id, orderId: '');
    }
    return DutyClearanceModel(
      id: doc.id,
      orderId: data['orderId'] as String? ?? '',
      handledBy: data['handledBy'] as String? ?? 'agent',
      clearanceFeeGhs:
          (data['clearanceFeeGhs'] as num?)?.toDouble(),
      icumsRef: data['icumsRef'] as String?,
      clearingAgentName: data['clearingAgentName'] as String?,
      dutyAmountGhs: (data['dutyAmountGhs'] as num?)?.toDouble(),
      vatGhs: (data['vatGhs'] as num?)?.toDouble(),
      nhilGhs: (data['nhilGhs'] as num?)?.toDouble(),
      otherLeviesGhs:
          (data['otherLeviesGhs'] as num?)?.toDouble(),
      totalPayableGhs:
          (data['totalPayableGhs'] as num?)?.toDouble(),
      graStatus: GraStatus.fromString(
        data['graStatus'] as String? ?? 'not_started',
      ),
      submittedAt: (data['submittedAt'] as Timestamp?)?.toDate(),
      assessedAt: (data['assessedAt'] as Timestamp?)?.toDate(),
      paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      clearedAt: (data['clearedAt'] as Timestamp?)?.toDate(),
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

DutyClearance dutyClearanceFromDoc(DocumentSnapshot doc) {
  final m = DutyClearanceModel.fromFirestore(doc);
  return DutyClearance(
    id: m.id,
    orderId: m.orderId,
    handledBy: m.handledBy,
    clearanceFeeGhs: m.clearanceFeeGhs,
    icumsRef: m.icumsRef,
    clearingAgentName: m.clearingAgentName,
    dutyAmountGhs: m.dutyAmountGhs,
    vatGhs: m.vatGhs,
    nhilGhs: m.nhilGhs,
    otherLeviesGhs: m.otherLeviesGhs,
    totalPayableGhs: m.totalPayableGhs,
    graStatus: m.graStatus.firestoreValue,
    submittedAt: m.submittedAt,
    assessedAt: m.assessedAt,
    paidAt: m.paidAt,
    clearedAt: m.clearedAt,
    notes: m.notes,
    createdAt: m.createdAt,
  );
}
