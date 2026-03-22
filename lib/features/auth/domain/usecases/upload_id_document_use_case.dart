import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class UploadIdDocumentUseCase {
  final AuthRepository _repository;

  const UploadIdDocumentUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String userId,
    required String localFilePath,
    required String extension,
  }) {
    return _repository.uploadIdDocument(
      userId: userId,
      localFilePath: localFilePath,
      extension: extension,
    );
  }
}

