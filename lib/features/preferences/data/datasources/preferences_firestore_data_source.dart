import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/preference_submission.dart';

class PreferencesFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  PreferencesFirestoreDataSource(
    this._firestore, [
    FirebaseFunctions? functions,
  ]) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

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

  Future<String> createOrderFromPreferences({
    required String buyerId,
    required PreferenceSubmission submission,
    required String idempotencyKey,
    String? assistedCustomerPhone,
  }) async {
    final result = await _functions
        .httpsCallable('createCustomerOrder')
        .call<Map<String, dynamic>>({
          'mode': assistedCustomerPhone == null ? 'self' : 'assisted',
          if (assistedCustomerPhone != null)
            'customerPhone': assistedCustomerPhone,
          'idempotencyKey': idempotencyKey,
          'preferences': {
            'make': submission.make,
            'model': submission.model,
            'yearMin': submission.yearMin,
            'yearMax': submission.yearMax,
            'isSingleYear': submission.yearMin == submission.yearMax,
            'condition': submission.condition,
            'conditionLabel': submission.conditionLabel,
            'maxMileage': submission.maxMileage,
            'trim': submission.trim,
            'purchaseOrigin': submission.purchaseOrigin,
            'isNewVehicle': submission.isNewVehicle,
            if (submission.maxBudgetUsd != null)
              'maxBudgetUsd': submission.maxBudgetUsd,
            if (submission.maxBudgetGhs != null)
              'maxBudgetGhs': submission.maxBudgetGhs,
          },
        });
    return result.data['orderId'] as String;
  }
}
