import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../clearance/data/models/duty_clearance_model.dart';
import '../../../payments/data/models/payment_request_model.dart';
import '../../../repairs/data/models/repair_job_model.dart';
import '../../../shipping/data/models/shipping_model.dart';
import '../../data/models/order_timeline_model.dart';

/// Timeline rows from Firestore, ordered by stageNumber ascending.
final orderTimelineProvider =
    StreamProvider.family<List<OrderTimelineModel>, String>((ref, orderId) {
      final firestore = ref.watch(firestoreProvider);
      return firestore
          .collection(FirestoreCollections.orderTimeline)
          .where('orderId', isEqualTo: orderId)
          .orderBy('stageNumber')
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map(OrderTimelineModel.fromFirestore).toList(),
          );
    });

/// All pending payment requests for the order (newest [sentAt] first).
final pendingPaymentRequestsProvider =
    StreamProvider.family<List<PaymentRequestModel>, String>((ref, orderId) {
      final firestore = ref.watch(firestoreProvider);
      return firestore
          .collection(FirestoreCollections.paymentRequests)
          .where('orderId', isEqualTo: orderId)
          .where(
            'status',
            isEqualTo: FirestoreEnumValues.paymentRequestStatusPending,
          )
          .snapshots()
          .map((snapshot) {
            final list = snapshot.docs
                .map(PaymentRequestModel.fromFirestore)
                .toList();
            list.sort((a, b) {
              final at = a.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bt = b.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bt.compareTo(at);
            });
            return list;
          });
    });

final orderShippingProvider = StreamProvider.family<ShippingModel?, String>((
  ref,
  orderId,
) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.shipping)
      .where('orderId', isEqualTo: orderId)
      .orderBy('createdAt', descending: true)
      .limit(1)
      .snapshots()
      .map(
        (s) =>
            s.docs.isEmpty ? null : ShippingModel.fromFirestore(s.docs.first),
      );
});

final orderClearanceProvider =
    StreamProvider.family<DutyClearanceModel?, String>((ref, orderId) {
      final firestore = ref.watch(firestoreProvider);
      return firestore
          .collection(FirestoreCollections.dutyClearance)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .snapshots()
          .map(
            (s) => s.docs.isEmpty
                ? null
                : DutyClearanceModel.fromFirestore(s.docs.first),
          );
    });

final orderRepairJobProvider = StreamProvider.family<RepairJobModel?, String>((
  ref,
  orderId,
) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.repairJobs)
      .where('orderId', isEqualTo: orderId)
      .limit(1)
      .snapshots()
      .asyncMap((s) async {
        if (s.docs.isEmpty) return null;
        final doc = s.docs.first;
        var model = RepairJobModel.fromFirestore(doc);
        if (!model.depositPaid) {
          await _syncRepairDepositPaidIfNeeded(
            firestore,
            orderId,
            doc.reference,
            model,
          );
          final refreshed = await doc.reference.get();
          if (refreshed.exists) {
            model = RepairJobModel.fromFirestore(refreshed);
          }
        }
        return model;
      });
});

/// Backfills [depositPaid] when deposit was confirmed but never linked on
/// [repair_jobs] (legacy repair_fee payments).
Future<void> _syncRepairDepositPaidIfNeeded(
  FirebaseFirestore firestore,
  String orderId,
  DocumentReference<Map<String, dynamic>> repairRef,
  RepairJobModel job,
) async {
  if (job.depositPaid) return;

  final depositRequestId = job.depositPaymentRequestId;
  if (depositRequestId != null) {
    final pr = await firestore
        .collection(FirestoreCollections.paymentRequests)
        .doc(depositRequestId)
        .get();
    if (pr.data()?['status'] == 'paid') {
      await repairRef.update({
        'depositPaid': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return;
    }
  }

  final paySnap = await firestore
      .collection(FirestoreCollections.payments)
      .where('orderId', isEqualTo: orderId)
      .where('type', isEqualTo: AppConstants.paymentRequestTypeRepairFee)
      .where('status', isEqualTo: 'confirmed')
      .limit(1)
      .get();
  if (paySnap.docs.isEmpty) return;

  final paymentRequestId =
      paySnap.docs.first.data()['paymentRequestId'] as String?;
  await repairRef.update({
    'depositPaid': true,
    if (paymentRequestId != null) 'depositPaymentRequestId': paymentRequestId,
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
