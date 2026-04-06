import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/country.dart';

abstract class CountriesRepository {
  /// Returns all active countries ordered by
  /// sortOrder. Cached — does not re-fetch
  /// within the same provider lifetime.
  Future<Either<Failure, List<Country>>> getAll();
}
