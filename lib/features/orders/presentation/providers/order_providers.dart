import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/order_firestore_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';

/// Alias for timeline widgets that expect an "order" model.
typedef OrderModel = OrderView;

class OrderView {
  final String id;
  final String orderRef;
  final String? agentId;
  final String status;
  final int stageNumber;
  final bool hasPendingPayment;
  final bool firstPaymentMade;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? make;
  final String? model;

  const OrderView({
    required this.id,
    required this.orderRef,
    required this.agentId,
    required this.status,
    required this.stageNumber,
    required this.hasPendingPayment,
    required this.firstPaymentMade,
    required this.createdAt,
    required this.updatedAt,
    required this.make,
    required this.model,
  });

  bool get isCompleted => status == FirestoreEnumValues.orderStatusDelivered;
  bool get needsPayment => status == FirestoreEnumValues.orderStatusPaymentPending;
  bool get isCancelled => status == FirestoreEnumValues.orderStatusCancelled;
}

class AgentDetailView {
  final String agentId;
  final String userId;
  final String fullName;
  final String? phone;
  final double successRate;
  final double rating;
  final int totalOrdersCompleted;
  final String introMessage;

  const AgentDetailView({
    required this.agentId,
    required this.userId,
    required this.fullName,
    this.phone,
    required this.successRate,
    required this.rating,
    required this.totalOrdersCompleted,
    required this.introMessage,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return 'AG';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class PaymentRequestView {
  final String id;
  final double totalGhs;
  final String type;
  final DateTime? deadlineAt;

  const PaymentRequestView({
    required this.id,
    required this.totalGhs,
    required this.type,
    required this.deadlineAt,
  });
}

final orderProvider = StreamProvider.family<OrderView?, String>((ref, orderId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.orders)
      .doc(orderId)
      .snapshots()
      .asyncMap((orderDoc) async {
    if (!orderDoc.exists) return null;
    final orderData = orderDoc.data() ?? <String, dynamic>{};
    final agentId = orderData['agentId'] as String?;
    final status = (orderData['status'] as String?) ?? '';
    final stageNumber = (orderData['stageNumber'] as int?) ?? 1;
    final createdRaw = orderData['createdAt'];
    final updatedRaw = orderData['updatedAt'];
    DateTime? createdAt;
    DateTime? updatedAt;
    if (createdRaw is Timestamp) createdAt = createdRaw.toDate();
    if (updatedRaw is Timestamp) updatedAt = updatedRaw.toDate();

    String? make;
    String? model;
    final prefQuery = await firestore
        .collection(FirestoreCollections.carPreferences)
        .where('orderId', isEqualTo: orderDoc.id)
        .limit(1)
        .get();
    if (prefQuery.docs.isNotEmpty) {
      final pref = prefQuery.docs.first.data();
      make = pref['make'] as String?;
      model = pref['model'] as String?;
    }

    final hasPendingPayment =
        status == FirestoreEnumValues.orderStatusPaymentPending;
    final firstPaymentMade =
        (orderData['firstPaymentMade'] as bool?) ?? false;

    return OrderView(
      id: orderDoc.id,
      orderRef: (orderData['orderRef'] as String?) ?? orderDoc.id,
      agentId: agentId,
      status: status,
      stageNumber: stageNumber,
      hasPendingPayment: hasPendingPayment,
      firstPaymentMade: firstPaymentMade,
      createdAt: createdAt,
      updatedAt: updatedAt,
      make: make,
      model: model,
    );
  });
});

final buyerOrdersProvider = StreamProvider<List<OrderView>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return const Stream.empty();
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.orders)
      .where('buyerId', isEqualTo: uid)
      .snapshots()
      .asyncMap((snapshot) async {
    final futures = snapshot.docs.map((doc) => ref.read(orderProvider(doc.id).future));
    final orders = await Future.wait(futures);
    final nonNull = orders.whereType<OrderView>().toList();
    nonNull.sort((a, b) {
      // payment pending first
      if (a.needsPayment != b.needsPayment) {
        return a.needsPayment ? -1 : 1;
      }
      // non-completed before completed
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // newest updated first
      final at = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bt.compareTo(at);
    });
    return nonNull;
  });
});

final agentDetailProvider =
    FutureProvider.family<AgentDetailView?, String>((ref, agentId) async {
  final firestore = ref.watch(firestoreProvider);
  final agentDoc =
      await firestore.collection(FirestoreCollections.agents).doc(agentId).get();
  if (!agentDoc.exists) return null;
  final agentData = agentDoc.data() ?? <String, dynamic>{};
  final userId = (agentData['userId'] as String?) ?? '';

  String fullName = 'Assigned Agent';
  String? phone;
  if (userId.isNotEmpty) {
    final userDoc =
        await firestore.collection(FirestoreCollections.users).doc(userId).get();
    final userData = userDoc.data() ?? <String, dynamic>{};
    fullName = (userData['fullName'] as String?) ?? fullName;
    phone = userData['phone'] as String?;
  }

  final intro = (agentData['agentIntroMessage'] as String?) ??
      'Hi, I have received your request and I will start searching for options shortly.';

  return AgentDetailView(
    agentId: agentId,
    userId: userId,
    fullName: fullName,
    phone: phone,
    successRate: ((agentData['successRate'] as num?) ?? 98).toDouble(),
    rating: ((agentData['rating'] as num?) ?? 4.9).toDouble(),
    totalOrdersCompleted: ((agentData['totalOrdersCompleted'] as num?) ?? 142).toInt(),
    introMessage: intro,
  );
});

final activePaymentRequestProvider =
    StreamProvider.family<PaymentRequestView?, String>((ref, orderId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.paymentRequests)
      .where('orderId', isEqualTo: orderId)
      .where('status', isEqualTo: FirestoreEnumValues.paymentRequestStatusPending)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data();
    final totalGhs = (data['totalGhs'] as num?)?.toDouble() ?? 0;
    final deadlineRaw = data['deadlineAt'];
    DateTime? deadline;
    if (deadlineRaw is Timestamp) deadline = deadlineRaw.toDate();
    return PaymentRequestView(
      id: doc.id,
      totalGhs: totalGhs,
      type: (data['type'] as String?) ?? '',
      deadlineAt: deadline,
    );
  });
});

final unreadMessagesCountProvider =
    StreamProvider.family<int, String>((ref, orderId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.messages)
      .where('orderId', isEqualTo: orderId)
      .where('isRead', isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
});

final pendingPaymentCountProvider = Provider<int>((ref) {
  final ordersAsync = ref.watch(buyerOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) => orders.where((o) => o.needsPayment).length,
    orElse: () => 0,
  );
});

final orderFirestoreDataSourceProvider =
    Provider<OrderFirestoreDataSource>((ref) {
  return OrderFirestoreDataSource(ref.watch(firestoreProvider));
});

final orderRepositoryProvider = Provider<OrderRepositoryImpl>((ref) {
  return OrderRepositoryImpl(
    ref.watch(orderFirestoreDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

final canEditOrderProvider = Provider.family<bool, String>((ref, orderId) {
  final orderAsync = ref.watch(orderProvider(orderId));
  return orderAsync.maybeWhen(
    data: (order) {
      if (order == null) return false;
      if (order.firstPaymentMade) return false;
      if (order.status == FirestoreEnumValues.orderStatusCancelled) return false;
      if (order.status == FirestoreEnumValues.orderStatusDelivered) return false;
      return true;
    },
    orElse: () => false,
  );
});

final vehicleOptionsSentProvider = FutureProvider.family<bool, String>(
  (ref, orderId) async {
    final firestore = ref.watch(firestoreProvider);
    final snapshot = await firestore
        .collection(FirestoreCollections.vehicleOptions)
        .where('orderId', isEqualTo: orderId)
        .where('status', whereIn: ['sent', 'confirmed'])
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  },
);

enum CancelOrderStatus { idle, cancelling, cancelled, error }

class CancelOrderNotifier extends StateNotifier<CancelOrderStatus> {
  CancelOrderNotifier(this._orderId, this._ref) : super(CancelOrderStatus.idle);

  final String _orderId;
  final Ref _ref;

  Future<bool> cancel() async {
    state = CancelOrderStatus.cancelling;
    final repo = _ref.read(orderRepositoryProvider);
    final guardResult = await repo.getOrderGuard(_orderId);
    final guard = guardResult.fold((_) => null, (g) => g);
    if (guard != null &&
        (guard['firstPaymentMade'] as bool? ?? false)) {
      state = CancelOrderStatus.error;
      return false;
    }
    final result = await repo.cancelOrder(_orderId);
    return result.fold(
      (_) {
        state = CancelOrderStatus.error;
        return false;
      },
      (_) {
        state = CancelOrderStatus.cancelled;
        return true;
      },
    );
  }
}

final cancelOrderNotifierProvider =
    StateNotifierProvider.family<CancelOrderNotifier, CancelOrderStatus, String>(
  (ref, orderId) => CancelOrderNotifier(orderId, ref),
);

