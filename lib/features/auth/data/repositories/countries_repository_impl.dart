import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/countries_repository.dart';
import '../datasources/countries_firestore_datasource.dart';

class CountriesRepositoryImpl implements CountriesRepository {
  const CountriesRepositoryImpl(this._dataSource);

  final CountriesFirestoreDataSource _dataSource;

  @override
  Future<Either<Failure, List<Country>>> getAll() async {
    try {
      final countries = await _dataSource.getAll();
      return Right(countries);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Could not load countries.',
          cause: e,
        ),
      );
    }
  }
}
