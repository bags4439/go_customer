import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/referral_code_generator.dart';
import '../../../notifications/onesignal/notification_onesignal_handler.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDataSource _dataSource;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const AuthRepositoryImpl(
    this._dataSource,
    this._firebaseAuth,
    this._firestore,
  );

  @override
  Stream<String?> authStateChanges() => _dataSource.authStateChanges();

  @override
  Future<Either<Failure, Unit>> createUserProfile(
    RegisterUserParams params,
  ) async {
    try {
      await _dataSource.createUserProfile(params);
      return right(unit);
    } catch (e) {
      return left(
        const FirestoreFailure(message: 'Could not save your profile.'),
      );
    }
  }

  @override
  Future<Either<Failure, AppUser?>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return right(user);
    } catch (e) {
      return left(
        const FirestoreFailure(message: 'Could not load your profile.'),
      );
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
      return left(
        AuthFailure(
          message: e.message ?? 'Phone verification failed.',
          cause: e,
        ),
      );
    } catch (e) {
      return left(AuthFailure(message: 'Phone verification failed.', cause: e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtpAndReturnUid({
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
  Future<Either<Failure, Unit>> syncOneSignalIdentity(String userId) async {
    try {
      await _dataSource.syncOneSignalIdentity(userId);
      return right(unit);
    } catch (e) {
      return left(
        UnexpectedFailure(message: 'Could not link notifications.', cause: e),
      );
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
      return left(
        StorageFailure(message: 'Could not upload your ID document.', cause: e),
      );
    }
  }

  @override
  Future<void> signOut() async {
    clearOneSignalUser();
    await _dataSource.signOut();
  }

  @override
  Future<Either<Failure, String>> getAuthenticatedUserId() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return const Left(
        AuthFailure(message: 'Not signed in. Please try again.'),
      );
    }
    return Right(uid);
  }

  @override
  Future<Either<Failure, String>> requestOtp(String e164Phone) async {
    final completer = Completer<Either<Failure, String>>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: e164Phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          await _firebaseAuth.signInWithCredential(credential);
        } catch (_) {}
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) {
          completer.complete(
            Left(FirebaseAuthFailure(message: _mapAuthError(e.code), cause: e)),
          );
        }
      },
      codeSent: (verificationId, _) {
        if (!completer.isCompleted) {
          completer.complete(Right(verificationId));
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) {
          completer.complete(Right(verificationId));
        }
      },
    );
    return completer.future;
  }

  @override
  Future<Either<Failure, (String, bool)>> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      final uid = result.user?.uid;
      if (uid == null) {
        return const Left(
          FirebaseAuthFailure(message: 'Sign in failed. Please try again.'),
        );
      }
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      final fullName = doc.data()?['fullName'] as String?;
      final isNewUser =
          !doc.exists || fullName == null || fullName.trim().isEmpty;

      return Right((doc.data()?['id'] ?? doc.id, isNewUser));
    } on FirebaseAuthException catch (e) {
      return Left(
        FirebaseAuthFailure(message: _mapAuthError(e.code), cause: e),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString(), cause: e));
    }
  }

  @override
  Future<Either<Failure, String>> completeProfile({
    required String uid,
    required String fullName,
    required String country,
  }) async {
    try {
      String code = ReferralCodeGenerator.generate();
      for (var attempt = 0; attempt < 5; attempt++) {
        final existing = await _firestore
            .collection(FirestoreCollections.referralCodes)
            .doc(code)
            .get();
        if (!existing.exists) break;
        code = attempt == 4
            ? 'R${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
            : ReferralCodeGenerator.generate();
      }

      var preferredCurrency = 'USD';
      if (country.isNotEmpty) {
        try {
          final currencySnap = await _firestore
              .collection(FirestoreCollections.currencies)
              .where('countryCodes', arrayContains: country)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

          if (currencySnap.docs.isNotEmpty) {
            final code_ = currencySnap.docs.first.data()['code'] as String?;
            if (code_ != null && code_.isNotEmpty) {
              preferredCurrency = code_;
            }
          }
        } catch (_) {
          preferredCurrency = 'USD';
        }
      }

      final batch = _firestore.batch();

      batch.set(
        _firestore.collection(FirestoreCollections.users).doc(uid),
        {
          'fullName': fullName.trim(),
          'country': country,
          'preferredCurrency': preferredCurrency,
          'referralCode': code,
          'referralDiscountGhs': 0.0,
          'referredBy': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      batch.set(
        _firestore.collection(FirestoreCollections.referralCodes).doc(code),
        {
          'userId': uid,
          'usedBy': <String>[],
          'usedCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
      return Right(code);
    } on FirebaseException catch (e) {
      return Left(
        FirestoreFailure(
          message: e.message ?? 'Could not save profile.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> saveGhanaCard({
    required String uid,
    String? idNumber,
    String? photoPath,
  }) async {
    try {
      final data = <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()};

      if (idNumber != null && idNumber.trim().isNotEmpty) {
        data['ghanaCardNumber'] = idNumber.trim().toUpperCase();
      }

      if (photoPath != null && photoPath.isNotEmpty) {
        final ref = FirebaseStorage.instance.ref().child(
          'ghana_cards/$uid.jpg',
        );
        await ref.putFile(File(photoPath));
        data['ghanaCardPhotoUrl'] = await ref.getDownloadURL();
      }

      if (data.length > 1) {
        await _firestore
            .collection(FirestoreCollections.users)
            .doc(uid)
            .update(data);
      }
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(
        FirestoreFailure(
          message: e.message ?? 'Could not save Ghana card.',
          cause: e,
        ),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString(), cause: e));
    }
  }
}

/// Maps Firebase Auth error codes to user-friendly messages.
String _mapAuthError(String code) {
  return switch (code) {
    'invalid-verification-code' =>
      'Incorrect code. Please check and try again.',
    'session-expired' => 'Code expired. Please request a new one.',
    'too-many-requests' => 'Too many attempts. Please try again later.',
    'invalid-phone-number' => 'Invalid phone number.',
    'network-request-failed' => 'No internet connection. Please try again.',
    _ => 'Something went wrong. Please try again.',
  };
}
