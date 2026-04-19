import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const ProfileFirestoreDataSource(this._firestore, this._storage);

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
    String storagePath,
  ) async {
    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'ghanaCardPhotoUrl': storagePath,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadIdDocument({
    required String userId,
    required String localFilePath,
    required String extension,
    void Function(double)? onProgress,
  }) async {
    final path = 'users/$userId/id_document.$extension';
    final storageRef = _storage.ref().child(path);
    final xFile = XFile(localFilePath);
    final bytes = await xFile.readAsBytes();
    final uploadTask = storageRef.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/${extension.toLowerCase()}',
      ),
    );
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final total = snapshot.totalBytes;
        if (total > 0) {
          onProgress(
            (snapshot.bytesTransferred / total).clamp(0.0, 1.0),
          );
        }
      });
    }
    await uploadTask;
    return path;
  }
}
