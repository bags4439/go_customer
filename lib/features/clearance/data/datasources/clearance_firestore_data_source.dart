import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../core/constants/clearance_constants.dart';
import '../../domain/entities/duty_clearance.dart';
import '../models/duty_clearance_model.dart';

/// Duty clearance and related Firestore operations.
/// One document per order: use orderId as document ID for duty_clearance.
class ClearanceFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const ClearanceFirestoreDataSource(this._firestore);

  Stream<DutyClearance?> watchDutyClearance(String orderId) {
    return _firestore
        .collection(FirestoreCollections.dutyClearance)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return dutyClearanceFromDoc(snapshot.docs.first);
    });
  }

  /// Returns the duty_clearance document if it exists (for guard against double-submit).
  Future<DutyClearance?> getDutyClearance(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.dutyClearance)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return dutyClearanceFromDoc(snapshot.docs.first);
  }

  /// Fetches system_settings clearanceServiceFeeGhs. Fallback 3200.0 on missing/error.
  Future<double> getClearanceServiceFeeGhs() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.systemSettings)
          .where('key', isEqualTo: ClearanceConstants.systemSettingsKeyClearanceFee)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return ClearanceConstants.clearanceFeeFallbackGhs;
      final data = snapshot.docs.first.data();
      final value = data['value'];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? ClearanceConstants.clearanceFeeFallbackGhs;
      return ClearanceConstants.clearanceFeeFallbackGhs;
    } catch (_) {
      return ClearanceConstants.clearanceFeeFallbackGhs;
    }
  }

  Future<void> createDutyClearanceAgent({
    required String orderId,
    required double clearanceFeeGhs,
  }) async {
    final ref = _firestore.collection(FirestoreCollections.dutyClearance).doc();
    await ref.set({
      'orderId': orderId,
      'handledBy': FirestoreEnumValues.clearanceHandledByAgent,
      'clearanceFeeGhs': clearanceFeeGhs,
      'graStatus': FirestoreEnumValues.graStatusNotStarted,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createDutyClearanceBuyer(String orderId) async {
    final ref = _firestore.collection(FirestoreCollections.dutyClearance).doc();
    await ref.set({
      'orderId': orderId,
      'handledBy': FirestoreEnumValues.clearanceHandledByBuyer,
      'graStatus': FirestoreEnumValues.graStatusNotStarted,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDutyClearanceToAgent({
    required String orderId,
    required double clearanceFeeGhs,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.dutyClearance)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'handledBy': FirestoreEnumValues.clearanceHandledByAgent,
      'clearanceFeeGhs': clearanceFeeGhs,
    });
  }

  Future<void> _updateCarPreferencesClearanceOptedIn(String orderId, bool optedIn) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.carPreferences)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({'clearanceOptedIn': optedIn});
  }

  Future<void> setClearanceTimelineActive(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.orderTimeline)
        .where('orderId', isEqualTo: orderId)
        .where('stageKey', isEqualTo: 'clearance_repairs')
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'isActive': true,
      'activatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> confirmAgentClearance({
    required String orderId,
    required double clearanceFeeGhs,
  }) async {
    await createDutyClearanceAgent(orderId: orderId, clearanceFeeGhs: clearanceFeeGhs);
    await _updateCarPreferencesClearanceOptedIn(orderId, true);
    await setClearanceTimelineActive(orderId);
  }

  Future<void> confirmSelfClearance(String orderId) async {
    await createDutyClearanceBuyer(orderId);
    await _updateCarPreferencesClearanceOptedIn(orderId, false);
    await setClearanceTimelineActive(orderId);
  }

  Future<void> switchToAgentClearance({
    required String orderId,
    required double clearanceFeeGhs,
  }) async {
    await updateDutyClearanceToAgent(orderId: orderId, clearanceFeeGhs: clearanceFeeGhs);
    await _updateCarPreferencesClearanceOptedIn(orderId, true);
  }
}
