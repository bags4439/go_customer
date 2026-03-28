import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/order_view.dart';
import '../repositories/order_repository.dart';

class WatchBuyerOrdersUseCase {
  final OrderRepository _repository;
  const WatchBuyerOrdersUseCase(this._repository);

  Stream<Either<Failure, List<OrderView>>> call(String buyerId) =>
      _repository.watchBuyerOrders(buyerId);
}
