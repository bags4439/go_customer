import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<String?> authStateChanges();

  Future<Either<Failure, PhoneVerificationSession>> startPhoneVerification({
    required String phoneNumber,
    int? resendToken,
  });

  Future<Either<Failure, String>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  Future<Either<Failure, Unit>> createUserProfile(RegisterUserParams params);

  Future<Either<Failure, AppUser?>> getCurrentUser();

  Future<Either<Failure, Unit>> uploadIdDocument({
    required String userId,
    required String localFilePath,
    required String extension,
  });

  Future<Either<Failure, Unit>> syncOneSignalIdentity(String userId);

  Future<void> signOut();
}

