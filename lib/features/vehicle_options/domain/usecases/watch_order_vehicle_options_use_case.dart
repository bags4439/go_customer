import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/vehicle_option.dart';
import '../repositories/vehicle_option_repository.dart';

class WatchOrderVehicleOptionsUseCase {
  const WatchOrderVehicleOptionsUseCase(this._repository);

  final VehicleOptionRepository _repository;

  Stream<Either<Failure, List<VehicleOption>>> call(String orderId) =>
      _repository.watchSentOptionsForOrder(orderId);
}
