import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
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
}
