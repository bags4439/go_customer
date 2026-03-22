import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/data/models/user_session_model.dart';

class UserSessionFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const UserSessionFirestoreDataSource(this._firestore);

  Stream<List<UserSessionModel>> watchSessions(String userId) {
    return _firestore
        .collection(FirestoreCollections.userSessions)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserSessionModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateSessionExpiry(String sessionId, DateTime expiresAt) async {
    await _firestore
        .collection(FirestoreCollections.userSessions)
        .doc(sessionId)
        .update({
      'expiresAt': Timestamp.fromDate(expiresAt),
      'lastUsedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteSession(String sessionId) async {
    await _firestore
        .collection(FirestoreCollections.userSessions)
        .doc(sessionId)
        .delete();
  }
}
