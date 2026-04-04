import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/preference_submission.dart';

class PreferencesFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const PreferencesFirestoreDataSource(this._firestore);

  Future<Map<String, dynamic>?> getCarPreferences(String orderId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.carPreferences)
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final data = snapshot.docs.first.data();
    final id = snapshot.docs.first.id;
    return {...data, 'id': id};
  }

  Future<void> updateCarPreferences(
      String preferenceId,
      Map<String, dynamic> values,
      ) async {
    await _firestore
        .collection(FirestoreCollections.carPreferences)
        .doc(preferenceId)
        .update({
      ...values,
      'editedBy': 'buyer',
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createPreferenceEditHistory({
    required String orderId,
    required String editedByUserId,
    required String editedByRole,
    required Map<String, dynamic> previousValuesJson,
    required Map<String, dynamic> newValuesJson,
  }) async {
    await _firestore
        .collection(FirestoreCollections.preferenceEditHistory)
        .add({
      'orderId': orderId,
      'editedByUserId': editedByUserId,
      'editedByRole': editedByRole,
      'previousValuesJson': previousValuesJson,
      'newValuesJson': newValuesJson,
      'reason': null,
      'buyerNotified': false,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> createOrderFromPreferences({
    required String buyerId,
    required PreferenceSubmission submission,
  }) async {
    final orderRef =
    _firestore.collection(FirestoreCollections.orders).doc();
    final preferenceRef =
    _firestore.collection(FirestoreCollections.carPreferences).doc();

    final orderCode =
        'ORD-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    // Create order document
    // NOTE: order_timeline documents are NOT created here.
    // The onOrderCreated Cloud Function handles timeline creation
    // exclusively. Creating them here would cause duplicates.
    batch.set(orderRef, {
      'id': orderRef.id,
      'orderRef': orderCode,
      'buyerId': buyerId,
      'agentId': null,
      'status': FirestoreEnumValues.orderStatusOpen,
      'currentStage': 'agent_assigned',
      'stageNumber': 2,
      'firstPaymentMade': false,
      'createdAt': now,
      'updatedAt': now,
    });

    // Create car preferences document
    batch.set(preferenceRef, {
      'id': preferenceRef.id,
      'orderId': orderRef.id,
      'make': submission.make,
      'model': submission.model,
      'yearMin': submission.yearMin,
      'yearMax': submission.yearMax,
      'isSingleYear': submission.yearMin == submission.yearMax,
      'condition': submission.condition,
      'conditionLabel': submission.conditionLabel,
      'maxMileage': submission.maxMileage,
      'repairOptedIn': submission.repairOptedIn,
      'clearanceOptedIn': null,
      'trim': submission.trim,
      'purchaseOrigin': submission.purchaseOrigin,
      'isNewVehicle': submission.isNewVehicle,
      'createdAt': now,
    });

    await batch.commit();
    return orderRef.id;
  }
}