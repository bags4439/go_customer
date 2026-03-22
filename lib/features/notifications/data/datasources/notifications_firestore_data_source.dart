import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

const int _pageSize = 50;
const int _maxBatchWrites = 500;

class NotificationsFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const NotificationsFirestoreDataSource(this._firestore);

  Stream<QuerySnapshot<Map<String, dynamic>>> watchNotificationsStream(
    String userId, {
    int limit = _pageSize,
  }) {
    return _firestore
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  /// Returns (items, lastDocumentSnapshot for pagination).
  Future<(List<NotificationEntity>, DocumentSnapshot<Map<String, dynamic>>?)> fetchPageAfter(
    String userId, {
    required DocumentSnapshot<Map<String, dynamic>>? startAfterDocument,
    int limit = _pageSize,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestoreCollections.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(limit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    final snapshot = await query.get();
    final list =
        snapshot.docs.map((d) => notificationFromDoc(d)).toList();
    final lastDoc =
        snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return (list, lastDoc);
  }

  Future<void> markRead(String notificationId) {
    return _firestore
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllRead(Iterable<String> notificationIds) async {
    final ids = notificationIds.take(_maxBatchWrites).toList();
    if (ids.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in ids) {
      final ref =
          _firestore.collection(FirestoreCollections.notifications).doc(id);
      batch.update(ref, {'isRead': true});
    }
    await batch.commit();
    final rest = notificationIds.skip(_maxBatchWrites).toList();
    if (rest.isNotEmpty) await markAllRead(rest);
  }
}
