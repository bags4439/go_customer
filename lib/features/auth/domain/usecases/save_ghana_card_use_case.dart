import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SaveGhanaCardUseCase {
  final AuthRepository _repository;
  const SaveGhanaCardUseCase(this._repository);

  Future<Either<Failure, Unit>> call({
    required String uid,
    String? idNumber,
    String? photoPath,
    String idDocumentType = 'ghana_card',
  }) {
    return _repository.saveGhanaCard(
      uid: uid,
      idNumber: idNumber,
      photoPath: photoPath,
      idDocumentType: idDocumentType,
    );
  }
}
