import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/car_make_model.dart';
import '../models/car_model_model.dart';

class CarCatalogueFirestoreDataSource {
  final FirebaseFirestore _firestore;
  const CarCatalogueFirestoreDataSource(this._firestore);

  Future<List<CarMakeModel>> getMakes() async {
    final snap = await _firestore
        .collection(FirestoreCollections.carMakes)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    return snap.docs.map(CarMakeModel.fromFirestore).toList();
  }

  Future<List<CarModelModel>> getModels(String makeSlug) async {
    final snap = await _firestore
        .collection(FirestoreCollections.carMakes)
        .doc(makeSlug)
        .collection(FirestoreCollections.carMakeModels)
        .where('isActive', isEqualTo: true)
        .get();

    final models = snap.docs.map(CarModelModel.fromFirestore).toList();
    models.sort((a, b) => a.name.compareTo(b.name));
    return models;
  }
}
