import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/guide_repository.dart';

class MarkGuideSeenUseCase {
  const MarkGuideSeenUseCase(this._repository);
  final GuideRepository _repository;

  Future<Either<Failure, Unit>> call(String key) {
    return _repository.markSeen(key);
  }
}
