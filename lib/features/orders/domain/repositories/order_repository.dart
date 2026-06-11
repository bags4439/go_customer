import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/agent_detail_view.dart';
import '../entities/order_view.dart';

abstract class OrderRepository {
  /// Streams the order combined with its car preferences.
  /// Emits a new value whenever the order document changes.
  Stream<Either<Failure, OrderView?>> watchOrder(String orderId);

  /// Streams all orders for the current buyer.
  Stream<Either<Failure, List<OrderView>>> watchBuyerOrders(String buyerId);

  /// Fetches agent detail including photo URL.
  Future<Either<Failure, AgentDetailView?>> getAgentDetail(String agentId);

  /// Guard check before cancellation.
  Future<Either<Failure, Map<String, dynamic>?>> getOrderGuard(String orderId);

  /// Cancels the order and notifies the agent.
  Future<Either<Failure, Unit>> cancelOrder(String orderId);

  /// Hides a cancelled order from buyer and agent lists (soft delete).
  Future<Either<Failure, Unit>> hideCancelledOrder(String orderId);
}
