import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/car_make.dart';
import '../repositories/car_catalogue_repository.dart';

class FetchCarMakesUseCase {
  final CarCatalogueRepository _repository;
  const FetchCarMakesUseCase(this._repository);

  Future<Either<Failure, List<CarMake>>> call() => _repository.getMakes();
}
