import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_collections.dart';
import '../../features/auth/domain/profile_setup_gate.dart';

/// Drives [GoRouter] refresh when auth or buyer profile readiness changes.
class AppRouterRefresh extends ChangeNotifier {
  AppRouterRefresh({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
    _onAuthChanged(_auth.currentUser);
  }

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  late final StreamSubscription<User?> _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;

  bool _profileKnown = false;
  bool _registrationComplete = false;

  /// False while the first [users] snapshot for the signed-in uid is pending.
  bool get profileKnown => _profileKnown;

  /// True when the buyer may leave the registration wizard and use the app.
  bool get registrationComplete => _registrationComplete;

  void _onAuthChanged(User? user) {
    _profileSub?.cancel();
    _profileSub = null;

    if (user == null) {
      _profileKnown = true;
      _registrationComplete = false;
      notifyListeners();
      return;
    }

    _profileKnown = false;
    notifyListeners();

    _profileSub = _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .snapshots()
        .listen(
      (snap) {
        _profileKnown = true;
        _registrationComplete = isRegistrationCompleteMap(
          snap.data(),
          exists: snap.exists,
        );
        notifyListeners();
      },
      onError: (_) {
        _profileKnown = true;
        _registrationComplete = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSub.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}

/// Paths reachable without a Firebase Auth session.
const Set<String> kUnauthenticatedAllowedPaths = {
  '/splash',
  '/onboarding',
  '/login',
};

/// Splash / marketing paths — completed buyers skip to the dashboard.
const Set<String> kPreAppPaths = {
  '/splash',
  '/onboarding',
};
