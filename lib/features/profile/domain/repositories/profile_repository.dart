import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/user_session_entity.dart';

abstract class ProfileRepository {
  Stream<AppUser?> watchUser(String userId);

  Future<Either<Failure, Unit>> updateFullName(String userId, String value);
  Future<Either<Failure, Unit>> updateLocation(String userId, String value);
  Future<Either<Failure, Unit>> updatePhone(String userId, String phone);
  Future<Either<Failure, Unit>> updateNotificationPreference(
    String userId,
    String key,
    bool value,
  );
  Future<Either<Failure, Unit>> updatePreferredCurrency(
    String userId,
    String value,
  );
  Future<Either<Failure, Unit>> updatePreferredLanguage(
    String userId,
    String value,
  );
  Future<Either<Failure, Unit>> updateGhanaIdAfterUpload(
    String userId,
    String storagePath,
  );

  /// Uploads file to Storage and updates user with storage path (not URL).
  /// [onProgress] is called with 0.0 to 1.0 during upload.
  Future<Either<Failure, Unit>> uploadIdDocument(
    String userId,
    String localFilePath,
    String extension, {
    void Function(double)? onProgress,
  });

  Stream<List<UserSessionEntity>> watchSessions(String userId);
  Future<Either<Failure, Unit>> updateSessionExpiry(
    String sessionId,
    DateTime expiresAt,
  );
  Future<Either<Failure, Unit>> deleteSession(String sessionId);

  Future<Either<Failure, Unit>> deleteUserAccount(String userId);
}
