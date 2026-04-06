import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/country.dart';

class CountriesFirestoreDataSource {
  const CountriesFirestoreDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<Country>> getAll() async {
    final snap = await _firestore
        .collection(FirestoreCollections.countries)
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .get();

    return snap.docs.map((doc) {
      final d = doc.data();
      return Country(
        isoCode: d['isoCode'] as String? ?? doc.id,
        name: d['name'] as String? ?? '',
        flag: d['flag'] as String? ?? '',
        dialCode: d['dialCode'] as String? ?? '',
      );
    }).toList();
  }
}
