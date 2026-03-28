import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../data/datasources/profile_firestore_data_source.dart';
import '../../domain/entities/user_session_entity.dart';
import '../../data/datasources/user_session_firestore_data_source.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

final profileDataSourceProvider = Provider<ProfileFirestoreDataSource>((ref) {
  return ProfileFirestoreDataSource(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  );
});

final userSessionDataSourceProvider = Provider<UserSessionFirestoreDataSource>((
  ref,
) {
  return UserSessionFirestoreDataSource(ref.watch(firestoreProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(profileDataSourceProvider),
    ref.watch(userSessionDataSourceProvider),
    ref.watch(functionsProvider),
  );
});

final currentUserProfileProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchUser(uid);
});

class OrderSummary {
  final int activeCount;
  final int completedCount;
  final String agentFirstName;

  const OrderSummary({
    required this.activeCount,
    required this.completedCount,
    required this.agentFirstName,
  });
}

final orderSummaryProvider = FutureProvider<OrderSummary>((ref) async {
  final ordersAsync = ref.watch(buyerOrdersProvider);
  final orders = ordersAsync.valueOrNull ?? [];
  final activeCount = orders
      .where(
        (o) =>
            o.status != FirestoreEnumValues.orderStatusDelivered &&
            o.status != FirestoreEnumValues.orderStatusCancelled,
      )
      .length;
  final completedCount = orders
      .where((o) => o.status == FirestoreEnumValues.orderStatusDelivered)
      .length;
  final activeWithAgent = orders
      .where(
        (o) =>
            o.agentId != null &&
            o.agentId!.isNotEmpty &&
            o.status != FirestoreEnumValues.orderStatusDelivered &&
            o.status != FirestoreEnumValues.orderStatusCancelled,
      )
      .toList();
  String agentFirstName = '—';
  if (activeWithAgent.isNotEmpty) {
    final agentDetail = await ref.read(
      agentDetailProvider(activeWithAgent.first.agentId!).future,
    );
    if (agentDetail != null && agentDetail.fullName.isNotEmpty) {
      final parts = agentDetail.fullName.trim().split(' ');
      agentFirstName = parts.first;
    }
  }
  return OrderSummary(
    activeCount: activeCount,
    completedCount: completedCount,
    agentFirstName: agentFirstName,
  );
});

class ProfileEditState {
  final String? expandedField;
  final String? draftValue;
  final String? errorMessage;

  const ProfileEditState({
    this.expandedField,
    this.draftValue,
    this.errorMessage,
  });

  static const initial = ProfileEditState();
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  ProfileEditNotifier() : super(ProfileEditState.initial);

  void expandField(String field, String currentValue) {
    state = ProfileEditState(
      expandedField: field,
      draftValue: currentValue,
      errorMessage: null,
    );
  }

  void updateDraft(String value) {
    state = ProfileEditState(
      expandedField: state.expandedField,
      draftValue: value,
      errorMessage: null,
    );
  }

  void setError(String? message) {
    state = ProfileEditState(
      expandedField: state.expandedField,
      draftValue: state.draftValue,
      errorMessage: message,
    );
  }

  void collapse() {
    state = ProfileEditState.initial;
  }
}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>(
      (ref) => ProfileEditNotifier(),
    );

final sessionListProvider = StreamProvider<List<UserSessionEntity>>((ref) {
  final uid = ref.watch(authStateProvider).value;
  if (uid == null) return Stream.value([]);
  return ref.watch(profileRepositoryProvider).watchSessions(uid);
});

final stayLoggedInProvider = Provider<bool>((ref) {
  final sessionsAsync = ref.watch(sessionListProvider);
  final sessions = sessionsAsync.valueOrNull ?? [];
  if (sessions.isEmpty) return true;
  final first = sessions.first;
  if (first.expiresAt == null) return true;
  final now = DateTime.now();
  return first.expiresAt!.difference(now).inHours > 24;
});

enum GhanaCardSaveStatus { idle, saving, success, error }

class GhanaCardState {
  final GhanaCardSaveStatus status;
  final String cardNumber;
  final String? photoPath;
  final String? existingPhotoUrl;
  final String? errorMessage;

  const GhanaCardState({
    this.status = GhanaCardSaveStatus.idle,
    this.cardNumber = '',
    this.photoPath,
    this.existingPhotoUrl,
    this.errorMessage,
  });

  GhanaCardState copyWith({
    GhanaCardSaveStatus? status,
    String? cardNumber,
    String? photoPath,
    String? existingPhotoUrl,
    String? errorMessage,
    bool clearPhotoPath = false,
    bool clearError = false,
  }) => GhanaCardState(
    status: status ?? this.status,
    cardNumber: cardNumber ?? this.cardNumber,
    photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
    existingPhotoUrl: existingPhotoUrl ?? this.existingPhotoUrl,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  bool get hasAnyData =>
      cardNumber.trim().isNotEmpty ||
      photoPath != null ||
      (existingPhotoUrl != null && existingPhotoUrl!.isNotEmpty);
}

class GhanaCardNotifier extends StateNotifier<GhanaCardState> {
  GhanaCardNotifier(this._ref) : super(const GhanaCardState());

  final Ref _ref;

  void init(AppUser user) {
    state = GhanaCardState(
      cardNumber: user.ghanaCardNumber ?? '',
      existingPhotoUrl: user.ghanaCardPhotoUrl,
    );
  }

  void updateCardNumber(String value) {
    state = state.copyWith(
      cardNumber: value,
      status: GhanaCardSaveStatus.idle,
      clearError: true,
    );
  }

  void setPhoto(String path) {
    state = state.copyWith(
      photoPath: path,
      status: GhanaCardSaveStatus.idle,
      clearError: true,
    );
  }

  void clearPhoto() {
    state = state.copyWith(
      clearPhotoPath: true,
      status: GhanaCardSaveStatus.idle,
      clearError: true,
    );
  }

  Future<void> save() async {
    final uid = _ref.read(authStateProvider).value;
    if (uid == null) return;

    final number = state.cardNumber.trim();
    final photo = state.photoPath;

    if (number.isEmpty && photo == null) return;

    state = state.copyWith(
      status: GhanaCardSaveStatus.saving,
      clearError: true,
    );

    final authRepo = _ref.read(authRepositoryProvider);
    final result = await authRepo.saveGhanaCard(
      uid: uid,
      idNumber: number.isEmpty ? null : number,
      photoPath: photo,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: GhanaCardSaveStatus.error,
        errorMessage: failure.message,
      ),
      (_) {
        state = state.copyWith(
          status: GhanaCardSaveStatus.success,
          clearPhotoPath: true,
          clearError: true,
        );
        _ref.invalidate(currentUserProfileProvider);
      },
    );
  }
}

final ghanaCardProvider =
    StateNotifierProvider.autoDispose<GhanaCardNotifier, GhanaCardState>(
      (ref) => GhanaCardNotifier(ref),
    );
