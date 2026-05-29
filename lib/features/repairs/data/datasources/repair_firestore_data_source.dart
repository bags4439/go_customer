import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../orders/core/constants/order_timeline_constants.dart';
import '../../core/constants/repair_constants.dart';
import '../../domain/entities/repair_job.dart';
import '../../domain/entities/garage.dart';
import '../models/repair_job_model.dart';
import '../models/garage_model.dart';

class RepairFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const RepairFirestoreDataSource(this._firestore);

  Stream<RepairJob?> watchRepairJob(String orderId) {
    return _firestore
        .collection(FirestoreCollections.repairJobs)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return repairJobFromDoc(snapshot.docs.first);
    });
  }

  Future<RepairJob?> getRepairJob(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.repairJobs)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return repairJobFromDoc(snapshot.docs.first);
  }

  Future<Garage?> getGarage(String? garageId) async {
    if (garageId == null || garageId.isEmpty) return null;
    final doc = await _firestore
        .collection(FirestoreCollections.garages)
        .doc(garageId)
        .get();
    if (!doc.exists) return null;
    return garageFromDoc(doc);
  }

  Future<double?> getRepairEstimateFromConfirmedVehicle(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.vehicleOptions)
        .where('orderId', isEqualTo: orderId)
        .where('status', isEqualTo: 'confirmed')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    final v = data['repairEstimateGhs'];
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Resolves repair coordination fee in USD from a pre-loaded
  /// system_settings map. Fallback is [RepairConstants.repairFeeFallbackUsd]
  /// if the key is missing or invalid.
  double getRepairServiceFeeUsd(Map<String, dynamic> settings) {
    final v = settings[RepairConstants.systemSettingsKeyRepairFee];
    if (v == null) {
      return RepairConstants.repairFeeFallbackUsd;
    }
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? RepairConstants.repairFeeFallbackUsd;
  }

  Future<void> createRepairJob(
    String orderId, {
    required bool optedIn,
  }) async {
    await _firestore.collection(FirestoreCollections.repairJobs).add({
      'orderId': orderId,
      'optedIn': optedIn,
      'status': FirestoreEnumValues.repairStatusNotStarted,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateCarPreferencesRepairOptedIn(String orderId, bool optedIn) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.carPreferences)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({'repairOptedIn': optedIn});
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(FirestoreCollections.orders).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Creates the repair job document.
  /// Stage advancement is manual only
  /// via Override order stage in the
  /// agent app. No order status or
  /// timeline changes are made here.
  Future<void> confirmRepairsOptIn(
    String orderId,
    bool optedIn,
  ) async {
    await createRepairJob(
      orderId,
      optedIn: optedIn,
    );
  }

  /// Sets buyer approval only. Cloud Function [onRepairQuoteAccepted]
  /// sets repair_jobs.status, quoteApprovedAt, and orders.status.
  Future<void> acceptQuote(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.repairJobs)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'quoteApprovedByBuyer': true,
    });
    await _updateRepairTimelineDetail(
      orderId,
      OrderTimelineConstants.repairTimelineDetailQuoteApproved,
    );
  }

  Future<void> declineQuote(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.repairJobs)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'quoteDeclinedAt': FieldValue.serverTimestamp(),
      'status': FirestoreEnumValues.repairStatusQuoteDeclined,
    });
    await _updateRepairTimelineDetail(
      orderId,
      OrderTimelineConstants.repairTimelineDetailQuoteDeclined,
    );
  }

  Future<void> _updateRepairTimelineDetail(
    String orderId,
    String detail,
  ) async {
    final snap = await _firestore
        .collection(FirestoreCollections.orderTimeline)
        .where('orderId', isEqualTo: orderId)
        .where('stageKey', isEqualTo: 'repair')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return;
    await snap.docs.first.reference.update({
      'detail': detail,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> switchToRepairs(String orderId) async {
    await _updateCarPreferencesRepairOptedIn(orderId, true);
    final snapshot = await _firestore
        .collection(FirestoreCollections.repairJobs)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'optedIn': true,
        'status': FirestoreEnumValues.repairStatusNotStarted,
      });
    }
  }
}
