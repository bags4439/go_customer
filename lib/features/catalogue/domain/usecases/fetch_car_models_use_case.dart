import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/car_model.dart';
import '../repositories/car_catalogue_repository.dart';

class FetchCarModelsUseCase {
  final CarCatalogueRepository _repository;
  const FetchCarModelsUseCase(this._repository);

  Future<Either<Failure, List<CarModel>>> call(String makeSlug) =>
      _repository.getModels(makeSlug);
}
