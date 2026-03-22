import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';

class OrderFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const OrderFirestoreDataSource(this._firestore);

  /// Fetches firstPaymentMade and status for guard checks.
  Future<Map<String, dynamic>?> getOrderGuard(String orderId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.orders)
        .doc(orderId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    return {
      'firstPaymentMade': (data['firstPaymentMade'] as bool?) ?? false,
      'status': (data['status'] as String?) ?? '',
    };
  }

  Future<void> cancelOrder(String orderId) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection(FirestoreCollections.orders).doc(orderId).update({
      'status': FirestoreEnumValues.orderStatusCancelled,
      'cancelledBy': 'buyer',
      'cancellationReason': 'Buyer requested cancellation',
      'cancelledAt': now,
      'updatedAt': now,
    });
  }
}
