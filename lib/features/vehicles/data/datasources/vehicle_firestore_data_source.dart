import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../vehicle_options/data/models/max_bid_model.dart';
import '../../../vehicle_options/data/models/vehicle_option_model.dart';

class VehicleFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const VehicleFirestoreDataSource(this._firestore);

  Future<VehicleOptionModel?> getVehicleOption(String vehicleOptionId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.vehicleOptions)
        .doc(vehicleOptionId)
        .get();
    if (!doc.exists) return null;
    return VehicleOptionModel.fromFirestore(doc);
  }

  Future<MaxBidModel?> getExistingMaxBid({
    required String vehicleOptionId,
    required String buyerId,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.maxBids)
        .where('vehicleOptionId', isEqualTo: vehicleOptionId)
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return MaxBidModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> createMaxBid({
    required String orderId,
    required String vehicleOptionId,
    required String buyerId,
    required double maxBidUsd,
    required double maxBidGhs,
    required double exchangeRate,
  }) async {
    await _firestore.collection(FirestoreCollections.maxBids).add({
      'orderId': orderId,
      'vehicleOptionId': vehicleOptionId,
      'buyerId': buyerId,
      'maxBidUsd': maxBidUsd,
      'maxBidGhs': maxBidGhs,
      'exchangeRate': exchangeRate,
      'confirmedAt': FieldValue.serverTimestamp(),
      'agentNotified': false,
      'agentNotifiedAt': null,
    });
  }

  Future<void> updateVehicleOptionConfirmed(
    String vehicleOptionId,
  ) async {
    await _firestore
        .collection(FirestoreCollections.vehicleOptions)
        .doc(vehicleOptionId)
        .update({
      'status': FirestoreEnumValues.vehicleOptionStatusConfirmed,
      'confirmedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOrderBidPlaced(String orderId) async {
    await _firestore.collection(FirestoreCollections.orders).doc(orderId).update({
      'status': FirestoreEnumValues.orderStatusBidPlaced,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
