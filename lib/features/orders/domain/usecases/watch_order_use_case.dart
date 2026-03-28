import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_view.dart';
import '../repositories/order_repository.dart';

class WatchOrderUseCase {
  final OrderRepository _repository;
  const WatchOrderUseCase(this._repository);

  Stream<Either<Failure, OrderView?>> call(String orderId) =>
      _repository.watchOrder(orderId);
}
