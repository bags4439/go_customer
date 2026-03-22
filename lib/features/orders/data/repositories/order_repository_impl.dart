import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../datasources/order_firestore_data_source.dart';

class OrderRepositoryImpl {
  final OrderFirestoreDataSource _dataSource;
  final FirebaseFunctions _functions;

  const OrderRepositoryImpl(this._dataSource, this._functions);

  Future<Either<Failure, Map<String, dynamic>?>> getOrderGuard(
      String orderId) async {
    try {
      final data = await _dataSource.getOrderGuard(orderId);
      return right(data);
    } catch (e) {
      return left(
          FirestoreFailure(message: 'Could not load order.', cause: e));
    }
  }

  Future<Either<Failure, Unit>> cancelOrder(String orderId) async {
    try {
      await _dataSource.cancelOrder(orderId);
      await _functions
          .httpsCallable('notifyAgentOrderCancelled')
          .call({'orderId': orderId});
      return right(unit);
    } catch (e) {
      return left(
          FirestoreFailure(message: 'Could not cancel order.', cause: e));
    }
  }
}
