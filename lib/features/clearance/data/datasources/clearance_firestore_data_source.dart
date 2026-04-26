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
        .orderBy('createdAt', descending: true)
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

  /// Resolves clearance fee in USD from a pre-loaded `system_settings` map.
  /// Fallback is [ClearanceConstants.clearanceFeeFallbackUsd] if the key is
  /// missing or invalid.
  double getClearanceServiceFeeUsd(Map<String, dynamic> settings) {
    final v = settings[ClearanceConstants.systemSettingsKeyClearanceFee];
    if (v == null) {
      return ClearanceConstants.clearanceFeeFallbackUsd;
    }
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ??
        ClearanceConstants.clearanceFeeFallbackUsd;
  }

  Future<void> createDutyClearanceAgent({
    required String orderId,
    required double clearanceFeeUsd,
  }) async {
    final ref = _firestore.collection(FirestoreCollections.dutyClearance).doc();
    await ref.set({
      'orderId': orderId,
      'handledBy': FirestoreEnumValues.clearanceHandledByAgent,
      'clearanceFeeUsd': clearanceFeeUsd,
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
    required double clearanceFeeUsd,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.dutyClearance)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return;
    await snapshot.docs.first.reference.update({
      'handledBy': FirestoreEnumValues.clearanceHandledByAgent,
      'clearanceFeeUsd': clearanceFeeUsd,
    });
  }

  Future<void> _updateCarPreferencesClearanceOptedIn(
    String orderId,
    bool optedIn,
  ) async {
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
        .where('stageKey', isEqualTo: 'repair')
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
    required double clearanceFeeUsd,
  }) async {
    await createDutyClearanceAgent(
      orderId: orderId,
      clearanceFeeUsd: clearanceFeeUsd,
    );
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
    required double clearanceFeeUsd,
  }) async {
    await updateDutyClearanceToAgent(
      orderId: orderId,
      clearanceFeeUsd: clearanceFeeUsd,
    );
    await _updateCarPreferencesClearanceOptedIn(orderId, true);
  }
}
