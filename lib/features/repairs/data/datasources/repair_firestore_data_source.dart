import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
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

  Future<bool?> getCarPreferencesRepairOptedIn(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.carPreferences)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data()['repairOptedIn'] as bool?;
  }

  Future<void> createRepairJob(String orderId) async {
    await _firestore.collection(FirestoreCollections.repairJobs).add({
      'orderId': orderId,
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

  Future<void> _setRepairTimelineActive(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.orderTimeline)
        .where('orderId', isEqualTo: orderId)
        .where('stageKey', isEqualTo: 'repairs')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'isActive': true,
      'activatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _setRepairCompleteAndDeliveryActive(String orderId) async {
    final timelineSnapshot = await _firestore
        .collection(FirestoreCollections.orderTimeline)
        .where('orderId', isEqualTo: orderId)
        .get();
    final now = FieldValue.serverTimestamp();
    final batch = _firestore.batch();
    for (final doc in timelineSnapshot.docs) {
      final data = doc.data();
      final stageKey = data['stageKey'] as String?;
      if (stageKey == 'repair') {
        batch.update(doc.reference, {
          'isComplete': true,
          'completedAt': now,
        });
      } else if (stageKey == 'delivery') {
        batch.update(doc.reference, {
          'isActive': true,
          'activatedAt': now,
        });
      }
    }
    await batch.commit();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(FirestoreCollections.orders).doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmRepairsOptIn(String orderId, bool optedIn) async {
    await createRepairJob(orderId);
    await _updateCarPreferencesRepairOptedIn(orderId, optedIn);
    if (optedIn) {
      await _setRepairTimelineActive(orderId);
    } else {
      await updateOrderStatus(orderId, FirestoreEnumValues.orderStatusRepairComplete);
      await _setRepairCompleteAndDeliveryActive(orderId);
    }
  }

  Future<void> acceptQuote(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.repairJobs)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'quoteApprovedByBuyer': true,
      'quoteApprovedAt': FieldValue.serverTimestamp(),
      'status': FirestoreEnumValues.repairStatusQuoteApproved,
    });
    await updateOrderStatus(orderId, FirestoreEnumValues.orderStatusRepairInProgress);
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
        'status': FirestoreEnumValues.repairStatusNotStarted,
      });
    }
  }
}
