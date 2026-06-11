import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/order_repository.dart';

class HideCancelledOrderUseCase {
  final OrderRepository _repository;

  const HideCancelledOrderUseCase(this._repository);

  Future<Either<Failure, Unit>> call(String orderId) =>
      _repository.hideCancelledOrder(orderId);
}
