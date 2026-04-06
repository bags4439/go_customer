import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<String?> authStateChanges();

  Future<Either<Failure, PhoneVerificationSession>> startPhoneVerification({
    required String phoneNumber,
    int? resendToken,
  });

  /// Legacy: verifies OTP and returns the authenticated user's uid.
  Future<Either<Failure, String>> verifyOtpAndReturnUid({
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

  /// Current Firebase Auth user id after phone sign-in; fails if not signed in.
  Future<Either<Failure, String>> getAuthenticatedUserId();

  /// Sends OTP to the given E.164 phone number.
  /// Returns the verificationId on success.
  Future<Either<Failure, String>> requestOtp(
    String e164Phone,
  );

  /// Verifies the OTP against the verificationId.
  /// Returns true if the user is new (no fullName set).
  /// Returns false if the user is returning.
  Future<Either<Failure, (String, bool)>> verifyOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Saves the user's full name, country, and
  /// preferred currency (derived from country).
  /// Generates a unique referral code.
  /// Returns the generated referral code.
  Future<Either<Failure, String>> completeProfile({
    required String uid,
    required String fullName,
    required String country,
  });

  /// Saves Ghana card details.
  /// Both idNumber and photoPath are optional.
  /// Uploads photo to Firebase Storage if photoPath
  /// is provided.
  Future<Either<Failure, Unit>> saveGhanaCard({
    required String uid,
    String? idNumber,
    String? photoPath,
  });
}
