import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';

class OrderFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const OrderFirestoreDataSource(this._firestore);

  /// Streams the order document combined with its
  /// car_preferences data. Emits on every order change.
  Stream<OrderRawData> watchOrder(String orderId) {
    return _firestore
        .collection(FirestoreCollections.orders)
        .doc(orderId)
        .snapshots()
        .asyncMap((doc) async {
      if (!doc.exists) {
        return const OrderRawData(
          orderDoc: null,
          orderId: null,
          preferences: null,
        );
      }
      final prefSnap = await _firestore
          .collection(FirestoreCollections.carPreferences)
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      final prefs =
          prefSnap.docs.isNotEmpty ? prefSnap.docs.first.data() : null;

      return OrderRawData(
        orderDoc: doc.data(),
        orderId: doc.id,
        preferences: prefs,
      );
    });
  }

  /// Streams all orders for the given buyer UID.
  Stream<List<String>> watchBuyerOrderIds(String buyerId) {
    return _firestore
        .collection(FirestoreCollections.orders)
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  /// Fetches agent document + linked user document.
  Future<AgentRawData?> getAgentDetail(String agentId) async {
    final agentDoc = await _firestore
        .collection(FirestoreCollections.agents)
        .doc(agentId)
        .get();
    if (!agentDoc.exists) return null;

    final agentData = agentDoc.data() ?? {};
    final userId = agentData['userId'] as String? ?? '';

    Map<String, dynamic> userData = {};
    if (userId.isNotEmpty) {
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      userData = userDoc.data() ?? {};
    }

    return AgentRawData(
      agentId: agentId,
      agentData: agentData,
      userId: userId,
      userData: userData,
    );
  }

  /// Fetches firstPaymentMade and status for guard checks.
  Future<Map<String, dynamic>?> getOrderGuard(String orderId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.orders)
        .doc(orderId)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    return {
      'firstPaymentMade': (data['firstPaymentMade'] as bool?) ?? false,
      'status': (data['status'] as String?) ?? '',
    };
  }

  Future<void> cancelOrder(String orderId) async {
    final now = FieldValue.serverTimestamp();
    await _firestore.collection(FirestoreCollections.orders).doc(orderId).update({
      'status': FirestoreEnumValues.orderStatusCancelled,
      'cancelledBy': 'buyer',
      'cancellationReason': 'Buyer requested cancellation',
      'cancelledAt': now,
      'updatedAt': now,
    });
  }
}

/// Raw order + preferences data from Firestore.
/// Used only in the data layer — never exposed to domain.
class OrderRawData {
  final Map<String, dynamic>? orderDoc;
  final String? orderId;
  final Map<String, dynamic>? preferences;

  const OrderRawData({
    required this.orderDoc,
    this.orderId,
    required this.preferences,
  });
}

/// Raw agent + user data from Firestore.
class AgentRawData {
  final String agentId;
  final Map<String, dynamic> agentData;
  final String userId;
  final Map<String, dynamic> userData;

  const AgentRawData({
    required this.agentId,
    required this.agentData,
    required this.userId,
    required this.userData,
  });
}
