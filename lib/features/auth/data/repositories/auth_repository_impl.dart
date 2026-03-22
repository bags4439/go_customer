import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/failures.dart';
import '../../../notifications/onesignal/notification_onesignal_handler.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Stream<String?> authStateChanges() => _dataSource.authStateChanges();

  @override
  Future<Either<Failure, Unit>> createUserProfile(RegisterUserParams params) async {
    try {
      await _dataSource.createUserProfile(params);
      return right(unit);
    } catch (e) {
      return left(const FirestoreFailure(message: 'Could not save your profile.'));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return right(user);
    } catch (e) {
      return left(const FirestoreFailure(message: 'Could not load your profile.'));
    }
  }

  @override
  Future<Either<Failure, PhoneVerificationSession>> startPhoneVerification({
    required String phoneNumber,
    int? resendToken,
  }) async {
    try {
      final session = await _dataSource.startPhoneVerification(
        phoneNumber: phoneNumber,
        resendToken: resendToken,
      );
      return right(session);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(message: e.message ?? 'Phone verification failed.', cause: e));
    } catch (e) {
      return left(AuthFailure(message: 'Phone verification failed.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncOneSignalIdentity(String userId) async {
    try {
      await _dataSource.syncOneSignalIdentity(userId);
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(message: 'Could not link notifications.', cause: e));
    }
  }

  @override
  Future<Either<Failure, Unit>> uploadIdDocument({
    required String userId,
    required String localFilePath,
    required String extension,
  }) async {
    try {
      await _dataSource.uploadIdDocument(
        userId: userId,
        localFilePath: localFilePath,
        extension: extension,
      );
      return right(unit);
    } catch (e) {
      return left(StorageFailure(message: 'Could not upload your ID document.', cause: e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final uid = await _dataSource.verifyOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return right(uid);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure(message: e.message ?? 'Invalid code.', cause: e));
    } catch (e) {
      return left(AuthFailure(message: 'Could not verify code.', cause: e));
    }
  }

  @override
  Future<void> signOut() async {
    clearOneSignalUser();
    await _dataSource.signOut();
  }
}

