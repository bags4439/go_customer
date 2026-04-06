import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../core/constants/guide_keys.dart';
import '../../domain/repositories/guide_repository.dart';
import '../datasources/guide_local_datasource.dart';

class GuideRepositoryImpl implements GuideRepository {
  const GuideRepositoryImpl(this._dataSource);

  final GuideLocalDataSource _dataSource;

  @override
  Future<Either<Failure, bool>> hasSeen(String key) async {
    try {
      final seen = await _dataSource.hasSeen(key);
      return Right(seen);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Could not read guide state.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> markSeen(String key) async {
    try {
      await _dataSource.markSeen(key);
      return const Right(unit);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Could not save guide state.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> resetAll() async {
    try {
      await _dataSource.resetAll(GuideKeys.all);
      return const Right(unit);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Could not reset guide.',
          cause: e,
        ),
      );
    }
  }
}
