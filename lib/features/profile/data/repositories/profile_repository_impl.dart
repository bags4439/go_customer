import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/models/user_session_model.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/user_session_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_firestore_data_source.dart';
import '../datasources/user_session_firestore_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileFirestoreDataSource _profileDataSource;
  final UserSessionFirestoreDataSource _sessionDataSource;
  final FirebaseFunctions _functions;

  const ProfileRepositoryImpl(
    this._profileDataSource,
    this._sessionDataSource,
    this._functions,
  );

  @override
  Stream<AppUser?> watchUser(String userId) {
    return _profileDataSource.watchUser(userId).map((m) => m?.toAppUser());
  }

  @override
  Future<Either<Failure, Unit>> updateFullName(
    String userId,
    String value,
  ) async {
    try {
      await _profileDataSource.updateFullName(userId, value);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLocation(
    String userId,
    String value,
  ) async {
    try {
      await _profileDataSource.updateLocation(userId, value);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePhone(String userId, String phone) async {
    try {
      await _profileDataSource.updatePhone(userId, phone);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNotificationPreference(
    String userId,
    String key,
    bool value,
  ) async {
    try {
      await _profileDataSource.updateNotificationPreference(userId, key, value);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not update.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePreferredCurrency(
    String userId,
    String value,
  ) async {
    try {
      await _profileDataSource.updatePreferredCurrency(userId, value);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePreferredLanguage(
    String userId,
    String value,
  ) async {
    try {
      await _profileDataSource.updatePreferredLanguage(userId, value);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateGhanaIdAfterUpload(
    String userId,
    String storagePath,
  ) async {
    try {
      await _profileDataSource.updateGhanaIdAfterUpload(userId, storagePath);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not save.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadIdDocument(
    String userId,
    String localFilePath,
    String extension, {
    void Function(double)? onProgress,
  }) async {
    try {
      final path = await _profileDataSource.uploadIdDocument(
        userId: userId,
        localFilePath: localFilePath,
        extension: extension,
        onProgress: onProgress,
      );
      await _profileDataSource.updateGhanaIdAfterUpload(userId, path);
      return right(unit);
    } catch (e) {
      return left(StorageFailure(message: 'Could not upload.', cause: e));
    }
  }

  @override
  Stream<List<UserSessionEntity>> watchSessions(String userId) {
    return _sessionDataSource
        .watchSessions(userId)
        .map((list) => list.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<Failure, Unit>> updateSessionExpiry(
    String sessionId,
    DateTime expiresAt,
  ) async {
    try {
      await _sessionDataSource.updateSessionExpiry(sessionId, expiresAt);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not update.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSession(String sessionId) async {
    try {
      await _sessionDataSource.deleteSession(sessionId);
      return right(unit);
    } catch (e) {
      return left(FirestoreFailure(message: 'Could not delete.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUserAccount(String userId) async {
    try {
      await _functions.httpsCallable('deleteUserAccount').call({
        'userId': userId,
      });
      return right(unit);
    } catch (e) {
      return left(
        UnexpectedFailure(message: 'Could not delete account.', cause: e),
      );
    }
  }
}
