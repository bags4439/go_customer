import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/storage/id_document_storage.dart';

class ProfileFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  late final IdDocumentStorage _idDocumentStorage;

  ProfileFirestoreDataSource(this._firestore, this._storage) {
    _idDocumentStorage = IdDocumentStorage(_storage);
  }

  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          return UserModel.fromFirestore(doc);
        });
  }

  Future<void> updateFullName(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'fullName': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateLocation(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'location': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePhone(String userId, String phone) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'phone': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSmsPhone(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'smsPhone': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateWhatsappPhone(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'whatsappPhone': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEmail(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'email': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateNotificationPreference(
    String userId,
    String key,
    bool value,
  ) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'notificationPreferences.$key': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePreferredCurrency(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'preferredCurrency': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCountry(String userId, String isoCode) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'country': isoCode,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePreferredLanguage(String userId, String value) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'preferredLanguage': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGhanaIdAfterUpload(
    String userId,
    String photoUrl,
  ) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'ghanaCardPhotoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadIdDocument({
    required String userId,
    required String localFilePath,
    required String extension,
    void Function(double)? onProgress,
  }) async {
    // Progress callbacks are not wired for putData uploads; kept for API stability.
    return _idDocumentStorage.upload(
      userId: userId,
      localFilePath: localFilePath,
      extension: extension,
    );
  }
}
