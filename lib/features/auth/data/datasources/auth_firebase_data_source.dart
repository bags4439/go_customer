import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/onesignal_web_helper.dart';
import '../../domain/entities/app_user.dart';
import '../models/user_model.dart';

class AuthFirebaseDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const AuthFirebaseDataSource(this._auth, this._firestore, this._storage);

  Stream<String?> authStateChanges() {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  Future<PhoneVerificationSession> startPhoneVerification({
    required String phoneNumber,
    int? resendToken,
  }) async {
    final completer = Completer<PhoneVerificationSession>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      // Native SDK only supports 0–120s for auto-retrieval.
      // We still treat the OTP as valid for 10 minutes in our own session.
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatic verification can happen in the background.
        try {
          await _auth.signInWithCredential(credential);
        } catch (_) {}
      },
      verificationFailed: (FirebaseAuthException exception) {
        if (!completer.isCompleted) {
          completer.completeError(exception);
        }
      },
      codeSent: (String verificationId, int? token) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationSession(
              verificationId: verificationId,
              resendToken: token,
              expiresAt: DateTime.now().add(const Duration(minutes: 10)),
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationSession(
              verificationId: verificationId,
              resendToken: resendToken,
              expiresAt: DateTime.now().add(const Duration(minutes: 10)),
            ),
          );
        }
      },
    );

    return completer.future;
  }

  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    final uid = result.user?.uid;
    if (uid == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found after OTP verification.',
      );
    }
    return uid;
  }

  Future<void> createUserProfile(RegisterUserParams params) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(params.userId)
        .set({
          'id': params.userId,
          'fullName': params.fullName,
          'phone': params.phone,
          'email': params.email,
          'role': FirestoreEnumValues.roleBuyer,
          'location': params.location,
          'country': params.country,
          'isFirstTimeBuyer': params.isFirstTimeBuyer,
          'isVerified': false,
          'ghanaCardPhotoUrl': null,
          'ghanaCardNumber': null,
          'preferredCurrency': 'GHS',
          'preferredLanguage': 'en',
          'notificationPreferences': {
            'agentMessages': true,
            'orderUpdates': true,
            'paymentRequests': true,
            'promotionsAndNews': false,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(firebaseUser.uid)
        .get();
    if (!snapshot.exists) return null;

    return UserModel.fromFirestore(snapshot).toAppUser();
  }

  Future<void> uploadIdDocument({
    required String userId,
    required String localFilePath,
    required String extension,
  }) async {
    final path = 'users/$userId/id_document.$extension';
    final ref = _storage.ref().child(path);
    final xFile = XFile(localFilePath);
    final bytes = await xFile.readAsBytes();
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/${extension.toLowerCase()}',
      ),
    );
    final url = await ref.getDownloadURL();

    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'ghanaCardPhotoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> syncOneSignalIdentity(String userId) async {
    if (kIsWeb) {
      oneSignalWebLogin(userId);
      return;
    }
    try {
      await OneSignal.login(userId);
    } catch (e) {
      OneSignal.login(userId);
    }
    final playerId = OneSignal.User.pushSubscription.id;
    if (playerId == null || playerId.isEmpty) return;

    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      'pushToken': playerId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
