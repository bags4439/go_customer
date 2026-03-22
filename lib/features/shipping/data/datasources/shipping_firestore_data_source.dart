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
        .doc(orderId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return shippingFromDoc(doc);
    });
  }
}
