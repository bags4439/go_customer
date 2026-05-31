import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../orders/data/models/buyer_review_model.dart';
import '../../domain/entities/delivery.dart';
import '../models/delivery_model.dart';

class DeliveryFirestoreDataSource {
  DeliveryFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _delivery =>
      _firestore.collection(FirestoreCollections.delivery);

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection(FirestoreCollections.buyerReviews);

  Stream<Delivery?> watchDelivery(String orderId) {
    return _delivery
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return _mapDelivery(snap.docs.first);
    });
  }

  Stream<BuyerReviewModel?> watchReview({
    required String orderId,
    required String buyerId,
  }) {
    return _reviews
        .where('orderId', isEqualTo: orderId)
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      return BuyerReviewModel.fromFirestore(snap.docs.first);
    });
  }

  Delivery _mapDelivery(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = DeliveryModel.fromFirestore(doc);
    return Delivery(
      id: m.id,
      orderId: m.orderId,
      handledBy: m.handledBy,
      paymentsCleared: m.paymentsCleared,
      deliveryAddress: m.deliveryAddress,
      deliveryCity: m.deliveryCity,
      latitude: m.latitude,
      longitude: m.longitude,
      locationLabel: m.locationLabel,
      locationSource: m.locationSource,
      recipientName: m.recipientName,
      recipientPhone: m.recipientPhone,
      buyerConfirmed: m.buyerConfirmed,
      buyerConfirmedAt: m.buyerConfirmedAt,
      status: m.status,
      paymentConfirmed: m.paymentConfirmed,
      notes: m.notes,
      collectionAddress: m.collectionAddress,
      collectionLatitude: m.collectionLatitude,
      collectionLongitude: m.collectionLongitude,
      collectionNotes: m.collectionNotes,
      createdAt: m.createdAt,
    );
  }
}
