import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/order_firestore_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/agent_detail_view.dart';
import '../../domain/entities/order_view.dart';
import '../../domain/entities/payment_request_view.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/cancel_order_use_case.dart';
import '../../domain/usecases/get_agent_detail_use_case.dart';
import '../../domain/usecases/watch_buyer_orders_use_case.dart';
import '../../domain/usecases/watch_order_use_case.dart';

// Re-export for backward compat with timeline widgets
export '../../domain/entities/order_view.dart' show OrderView, OrderModel;
export '../../domain/entities/agent_detail_view.dart' show AgentDetailView;
export '../../domain/entities/payment_request_view.dart'
    show PaymentRequestView;

// ── Infrastructure providers ────────────────────────────

final orderFirestoreDataSourceProvider =
    Provider<OrderFirestoreDataSource>((ref) {
  return OrderFirestoreDataSource(
    ref.watch(firestoreProvider),
  );
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(
    ref.watch(orderFirestoreDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

// ── Use case providers ──────────────────────────────────

final watchOrderUseCaseProvider = Provider<WatchOrderUseCase>((ref) {
  return WatchOrderUseCase(
    ref.watch(orderRepositoryProvider),
  );
});

final watchBuyerOrdersUseCaseProvider =
    Provider<WatchBuyerOrdersUseCase>((ref) {
  return WatchBuyerOrdersUseCase(
    ref.watch(orderRepositoryProvider),
  );
});

final getAgentDetailUseCaseProvider =
    Provider<GetAgentDetailUseCase>((ref) {
  return GetAgentDetailUseCase(
    ref.watch(orderRepositoryProvider),
  );
});

final cancelOrderUseCaseProvider = Provider<CancelOrderUseCase>((ref) {
  return CancelOrderUseCase(
    ref.watch(orderRepositoryProvider),
  );
});

// ── Order stream ────────────────────────────────────────

final orderProvider =
    StreamProvider.family<OrderView?, String>((ref, orderId) {
  final useCase = ref.watch(watchOrderUseCaseProvider);
  return useCase(orderId).map(
    (either) => either.fold((_) => null, (order) => order),
  );
});

// ── Buyer orders stream ─────────────────────────────────

final buyerOrdersProvider = StreamProvider<List<OrderView>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return const Stream.empty();
  final useCase = ref.watch(watchBuyerOrdersUseCaseProvider);
  return useCase(uid).map(
    (either) => either.fold((_) => [], (orders) => orders),
  );
});

// ── Agent detail ────────────────────────────────────────

final agentDetailProvider =
    FutureProvider.family<AgentDetailView?, String>((ref, agentId) async {
  final useCase = ref.watch(getAgentDetailUseCaseProvider);
  final result = await useCase(agentId);
  return result.fold((_) => null, (agent) => agent);
});

// ── Payment requests ────────────────────────────────────

final activePaymentRequestProvider =
    StreamProvider.family<PaymentRequestView?, String>((ref, orderId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection(FirestoreCollections.paymentRequests)
      .where('orderId', isEqualTo: orderId)
      .where(
        'status',
        isEqualTo: FirestoreEnumValues.paymentRequestStatusPending,
      )
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data();
    final totalGhs = (data['totalGhs'] as num?)?.toDouble() ?? 0;
    final deadlineRaw = data['deadlineAt'];
    DateTime? deadline;
    if (deadlineRaw is Timestamp) {
      deadline = deadlineRaw.toDate();
    }
    return PaymentRequestView(
      id: doc.id,
      totalGhs: totalGhs,
      type: (data['type'] as String?) ?? '',
      deadlineAt: deadline,
    );
  });
});

// ── Unread messages count ───────────────────────────────

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

// ── Derived providers ───────────────────────────────────

final pendingPaymentCountProvider = Provider<int>((ref) {
  final ordersAsync = ref.watch(buyerOrdersProvider);
  return ordersAsync.maybeWhen(
    data: (orders) =>
        orders.where((o) => o.needsPayment).length,
    orElse: () => 0,
  );
});

final canEditOrderProvider =
    Provider.family<bool, String>((ref, orderId) {
  final orderAsync = ref.watch(orderProvider(orderId));
  return orderAsync.maybeWhen(
    data: (order) {
      if (order == null) return false;
      if (order.firstPaymentMade) return false;
      if (order.isCancelled) return false;
      if (order.isCompleted) return false;
      return true;
    },
    orElse: () => false,
  );
});

final vehicleOptionsSentProvider =
    FutureProvider.family<bool, String>((ref, orderId) async {
  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection(FirestoreCollections.vehicleOptions)
      .where('orderId', isEqualTo: orderId)
      .where('status', whereIn: ['sent', 'confirmed'])
      .limit(1)
      .get();
  return snapshot.docs.isNotEmpty;
});

// ── Cancel order notifier ───────────────────────────────

enum CancelOrderStatus { idle, cancelling, cancelled, error }

class CancelOrderNotifier extends StateNotifier<CancelOrderStatus> {
  CancelOrderNotifier(this._orderId, this._ref)
      : super(CancelOrderStatus.idle);

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
    final useCase = _ref.read(cancelOrderUseCaseProvider);
    final result = await useCase(_orderId);
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

final cancelOrderNotifierProvider = StateNotifierProvider.family<
    CancelOrderNotifier, CancelOrderStatus, String>(
  (ref, orderId) => CancelOrderNotifier(orderId, ref),
);
