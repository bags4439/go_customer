import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/vehicle_option_model.dart';

class VehicleOptionFirestoreDataSource {
  const VehicleOptionFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<VehicleOptionModel>> watchSentOptionsForOrder(String orderId) {
    return _firestore
        .collection(FirestoreCollections.vehicleOptions)
        .where('orderId', isEqualTo: orderId)
        .where('status', isEqualTo: FirestoreEnumValues.vehicleOptionStatusSent)
        .snapshots()
        .map((snapshot) {
          final models = snapshot.docs
              .map(VehicleOptionModel.fromFirestore)
              .toList(growable: false);
          models.sort((a, b) {
            final aDate = a.sentAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.sentAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
          return models;
        });
  }

  Stream<VehicleOptionModel?> watchVehicleOption(String vehicleOptionId) {
    return _firestore
        .collection(FirestoreCollections.vehicleOptions)
        .doc(vehicleOptionId)
        .snapshots()
        .map(
          (doc) => doc.exists ? VehicleOptionModel.fromFirestore(doc) : null,
        );
  }
}
