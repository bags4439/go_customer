import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../../core/constants/firestore_collections.dart';
import '../../../../../shared/providers/firebase_providers.dart';

class AssistedCustomer {
  const AssistedCustomer({
    required this.phone,
    required this.fullName,
    required this.maskedPhone,
  });

  final String phone;
  final String fullName;
  final String maskedPhone;
}

final assistedCustomerProvider = StateProvider<AssistedCustomer?>(
  (ref) => null,
);

final canCreateOrdersForCustomersProvider = FutureProvider<bool>((ref) async {
  final uid = ref.watch(authStateProvider).valueOrNull;
  if (uid == null) return false;
  final doc = await ref
      .watch(firestoreProvider)
      .collection(FirestoreCollections.users)
      .doc(uid)
      .get();
  final data = doc.data();
  return data?['role'] == 'agent' && data?['createOrdersForCustomers'] == true;
});
