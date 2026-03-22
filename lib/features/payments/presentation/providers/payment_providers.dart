import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../data/datasources/payment_firestore_data_source.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../data/repositories/payment_request_repository_impl.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/repositories/payment_request_repository.dart';

// --- Data source & repositories ---
final paymentFirestoreDataSourceProvider = Provider<PaymentFirestoreDataSource>((ref) {
  return PaymentFirestoreDataSource(ref.watch(firestoreProvider));
});

final paymentRequestRepositoryProvider = Provider<PaymentRequestRepository>((ref) {
  return PaymentRequestRepositoryImpl(ref.watch(paymentFirestoreDataSourceProvider));
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.watch(paymentFirestoreDataSourceProvider));
});

// --- Payment request (Screen 1) ---
final paymentRequestProvider =
    StreamProvider.family<PaymentRequest?, String>((ref, requestId) {
  return ref.watch(paymentRequestRepositoryProvider).watchPaymentRequest(requestId);
});

// --- Agent for payment header (users/{agentUserId} via agent doc) ---
final agentForPaymentProvider =
    FutureProvider.family<AgentDetailView?, String>((ref, agentId) {
  return ref.watch(agentDetailProvider(agentId).future);
});

// --- Selected method & MoMo number (Screen 2) ---
enum PaymentMethod {
  mtnMomo,
  vodafoneCash,
  airteltigoMoney,
  card,
  bankTransfer,
}

final selectedPaymentMethodProvider =
    StateProvider<PaymentMethod?>((ref) => PaymentMethod.mtnMomo);

final momoNumberProvider = StateProvider<String>((ref) => '');

// --- Active payment (in-progress) per order ---
final activePaymentProvider =
    StateProvider.family<Payment?, String>((ref, orderId) => null);

// --- Payment status stream (Screen 3) ---
final paymentStatusProvider =
    StreamProvider.family<Payment?, String>((ref, paymentId) {
  return ref.watch(paymentRepositoryProvider).watchPayment(paymentId);
});

// --- 5 minute timeout ---
final paymentTimeoutProvider =
    StateNotifierProvider<PaymentTimeoutNotifier, PaymentTimeoutState>((ref) {
  return PaymentTimeoutNotifier();
});

class PaymentTimeoutState {
  final bool isTimedOut;
  final String? paymentId;

  const PaymentTimeoutState({this.isTimedOut = false, this.paymentId});
}

class PaymentTimeoutNotifier extends StateNotifier<PaymentTimeoutState> {
  Timer? _timer;

  PaymentTimeoutNotifier() : super(const PaymentTimeoutState());

  void start(String paymentId) {
    _timer?.cancel();
    state = const PaymentTimeoutState(isTimedOut: false);
    _timer = Timer(const Duration(minutes: 5), () {
      state = PaymentTimeoutState(isTimedOut: true, paymentId: paymentId);
    });
  }

  void reset() {
    _timer?.cancel();
    state = const PaymentTimeoutState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// --- Helpers: payment type label (never hardcode in UI) ---
String paymentRequestTypeLabel(String type) {
  return AppConstants.paymentRequestTypeLabels[type] ?? type;
}

String paymentMethodLabel(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.mtnMomo:
      return 'MTN Mobile Money';
    case PaymentMethod.vodafoneCash:
      return 'Vodafone Cash';
    case PaymentMethod.airteltigoMoney:
      return 'AirtelTigo Money';
    case PaymentMethod.card:
      return 'Debit/Credit card';
    case PaymentMethod.bankTransfer:
      return 'Bank transfer';
  }
}
