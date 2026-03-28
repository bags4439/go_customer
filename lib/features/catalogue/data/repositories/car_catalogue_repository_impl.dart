import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/car_make.dart';
import '../../domain/entities/car_model.dart';
import '../../domain/repositories/car_catalogue_repository.dart';
import '../datasources/car_catalogue_firestore_data_source.dart';

class CarCatalogueRepositoryImpl implements CarCatalogueRepository {
  final CarCatalogueFirestoreDataSource _dataSource;
  const CarCatalogueRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<CarMake>>> getMakes() async {
    try {
      final models = await _dataSource.getMakes();
      final entities = models.map((m) => m.toEntity()).toList();

      entities.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        if (a.popular != b.popular) {
          return a.popular ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });

      return Right(entities);
    } on FirebaseException catch (e) {
      return Left(
        FirestoreFailure(
          message: e.message ?? 'Could not load car makes.',
          cause: e,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(message: e.toString(), cause: e),
      );
    }
  }

  @override
  Future<Either<Failure, List<CarModel>>> getModels(String makeSlug) async {
    try {
      final models = await _dataSource.getModels(makeSlug);
      return Right(models.map((m) => m.toEntity()).toList());
    } on FirebaseException catch (e) {
      return Left(
        FirestoreFailure(
          message: e.message ?? 'Could not load models.',
          cause: e,
        ),
      );
    } catch (e) {
      return Left(
        UnexpectedFailure(message: e.toString(), cause: e),
      );
    }
  }
}
