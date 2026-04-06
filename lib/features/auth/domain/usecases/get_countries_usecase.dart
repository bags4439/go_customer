import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/country.dart';
import '../repositories/countries_repository.dart';

class GetCountriesUseCase {
  const GetCountriesUseCase(this._repository);

  final CountriesRepository _repository;

  Future<Either<Failure, List<Country>>> call() {
    return _repository.getAll();
  }
}
