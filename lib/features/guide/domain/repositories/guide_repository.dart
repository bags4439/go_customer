import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class GuideRepository {
  /// Returns true if the guide for [key] has
  /// already been seen and dismissed.
  Future<Either<Failure, bool>> hasSeen(String key);

  /// Marks the guide for [key] as seen.
  Future<Either<Failure, Unit>> markSeen(String key);

  /// Resets all guide keys so the full guide
  /// flow plays again from the beginning.
  Future<Either<Failure, Unit>> resetAll();
}
