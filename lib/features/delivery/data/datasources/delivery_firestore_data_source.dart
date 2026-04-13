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

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection(FirestoreCollections.orders);

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

  /// Streams the buyer review for a
  /// given order and buyer. Returns null
  /// if no review has been submitted yet.
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
      createdAt: m.createdAt,
    );
  }

  Future<void> saveDeliveryLocation({
    required String orderId,
    required String address,
    required String city,
    required String locationSource,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) async {
    final snap = await _delivery
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    final payload = <String, dynamic>{
      'orderId': orderId,
      'deliveryAddress': address,
      'deliveryCity': city,
      'locationSource': locationSource,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationLabel != null) 'locationLabel': locationLabel,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update(payload);
    } else {
      await _delivery.add({
        ...payload,
        'buyerConfirmed': false,
        'paymentConfirmed': false,
        'status': 'pending_payment',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> confirmDelivery(String orderId) async {
    final snap = await _delivery
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    final batch = _firestore.batch();

    if (snap.docs.isNotEmpty) {
      batch.update(snap.docs.first.reference, {
        'buyerConfirmed': true,
        'buyerConfirmedAt': FieldValue.serverTimestamp(),
        'status': 'delivery_confirmed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      final ref = _delivery.doc();
      batch.set(ref, {
        'orderId': orderId,
        'buyerConfirmed': true,
        'buyerConfirmedAt': FieldValue.serverTimestamp(),
        'status': 'delivery_confirmed',
        'paymentConfirmed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    batch.update(_orders.doc(orderId), {
      'status': AppConstants.statusDeliveryConfirmed,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> submitReviewAndClose({
    required String orderId,
    required String buyerId,
    required String agentId,
    required double overallRating,
    required double agentRating,
    required double communicationRating,
    required double speedRating,
    String? comment,
  }) async {
    final batch = _firestore.batch();

    // Use a fixed doc ID so re-submissions
    // overwrite rather than duplicate.
    // Format: orderId_buyerId
    final reviewRef =
        _reviews.doc('${orderId}_$buyerId');
    batch.set(reviewRef, {
      'orderId': orderId,
      'buyerId': buyerId,
      'agentId': agentId,
      'overallRating': overallRating,
      'agentRating': agentRating,
      'communicationRating': communicationRating,
      'speedRating': speedRating,
      if (comment != null && comment.trim().isNotEmpty)
        'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_orders.doc(orderId), {
      'status': AppConstants.statusDelivered,
      'deliveredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
