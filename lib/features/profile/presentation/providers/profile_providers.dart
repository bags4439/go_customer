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

final userSessionDataSourceProvider =
    Provider<UserSessionFirestoreDataSource>((ref) {
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
      .where((o) =>
          o.status != FirestoreEnumValues.orderStatusDelivered &&
          o.status != FirestoreEnumValues.orderStatusCancelled)
      .length;
  final completedCount = orders
      .where((o) => o.status == FirestoreEnumValues.orderStatusDelivered)
      .length;
  final activeWithAgent = orders
      .where((o) =>
          o.agentId != null &&
          o.agentId!.isNotEmpty &&
          o.status != FirestoreEnumValues.orderStatusDelivered &&
          o.status != FirestoreEnumValues.orderStatusCancelled)
      .toList();
  String agentFirstName = '—';
  if (activeWithAgent.isNotEmpty) {
    final agentDetail =
        await ref.read(agentDetailProvider(activeWithAgent.first.agentId!).future);
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

enum IdVerificationUploadStatus { idle, selected, uploading, success, error }

class IdVerificationUploadState {
  final IdVerificationUploadStatus status;
  final String? selectedFilePath;
  final String? selectedFileName;
  final bool isPdf;
  final double uploadProgress;
  final String? errorMessage;

  const IdVerificationUploadState({
    this.status = IdVerificationUploadStatus.idle,
    this.selectedFilePath,
    this.selectedFileName,
    this.isPdf = false,
    this.uploadProgress = 0,
    this.errorMessage,
  });
}

class IdVerificationUploadNotifier extends StateNotifier<IdVerificationUploadState> {
  IdVerificationUploadNotifier(this._ref) : super(const IdVerificationUploadState());
  final Ref _ref;

  void setSelected({required String path, required String name, required bool isPdf}) {
    state = IdVerificationUploadState(
      status: IdVerificationUploadStatus.selected,
      selectedFilePath: path,
      selectedFileName: name,
      isPdf: isPdf,
    );
  }

  void clearSelection() {
    state = const IdVerificationUploadState();
  }

  void setUploading(double progress) {
    state = IdVerificationUploadState(
      status: IdVerificationUploadStatus.uploading,
      selectedFilePath: state.selectedFilePath,
      selectedFileName: state.selectedFileName,
      isPdf: state.isPdf,
      uploadProgress: progress,
    );
  }

  void setSuccess() {
    state = IdVerificationUploadState(
      status: IdVerificationUploadStatus.success,
      selectedFilePath: state.selectedFilePath,
      selectedFileName: state.selectedFileName,
      isPdf: state.isPdf,
    );
  }

  void setError(String message) {
    state = IdVerificationUploadState(
      status: IdVerificationUploadStatus.error,
      selectedFilePath: state.selectedFilePath,
      selectedFileName: state.selectedFileName,
      isPdf: state.isPdf,
      errorMessage: message,
    );
  }

  void reset() {
    state = const IdVerificationUploadState();
  }

  Future<void> startUpload() async {
    final path = state.selectedFilePath;
    if (path == null) return;
    final ext = path.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'pdf'].contains(ext)) {
      setError('Unsupported file type');
      return;
    }
    final userId = _ref.read(authStateProvider).value;
    if (userId == null) return;
    final repo = _ref.read(profileRepositoryProvider);
    setUploading(0);
    final result = await repo.uploadIdDocument(
      userId,
      path,
      ext,
      onProgress: (p) {
        state = IdVerificationUploadState(
          status: IdVerificationUploadStatus.uploading,
          selectedFilePath: state.selectedFilePath,
          selectedFileName: state.selectedFileName,
          isPdf: state.isPdf,
          uploadProgress: p,
        );
      },
    );
    result.fold(
      (_) => setError('Upload failed. Please try again.'),
      (_) {
        setSuccess();
        _ref.invalidate(currentUserProfileProvider);
      },
    );
  }
}

final idVerificationUploadProvider =
    StateNotifierProvider<IdVerificationUploadNotifier, IdVerificationUploadState>(
  (ref) => IdVerificationUploadNotifier(ref),
);
