import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository _repository;
  const CancelOrderUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String orderId) =>
      _repository.cancelOrder(orderId);
}
