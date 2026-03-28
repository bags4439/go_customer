import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/shipping.dart';
import '../models/shipping_model.dart';

/// Read-only. Document ID = orderId (one shipping doc per order).
class ShippingFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const ShippingFirestoreDataSource(this._firestore);

  Stream<Shipping?> watchShipping(String orderId) {
    return _firestore
        .collection(FirestoreCollections.shipping)
        .where('orderId', isEqualTo: orderId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : shippingFromDoc(s.docs.first));
  }
}
