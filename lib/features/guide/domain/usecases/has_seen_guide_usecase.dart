import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/guide_repository.dart';

class HasSeenGuideUseCase {
  const HasSeenGuideUseCase(this._repository);
  final GuideRepository _repository;

  Future<Either<Failure, bool>> call(String key) {
    return _repository.hasSeen(key);
  }
}
