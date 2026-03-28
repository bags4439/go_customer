import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/car_make.dart';
import '../entities/car_model.dart';

abstract class CarCatalogueRepository {
  /// Returns all active makes sorted by [sortOrder], then popular within
  /// each group, then alphabetically by [name].
  Future<Either<Failure, List<CarMake>>> getMakes();

  /// Returns all active models for the given [makeSlug].
  Future<Either<Failure, List<CarModel>>> getModels(
    String makeSlug,
  );
}
