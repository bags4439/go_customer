import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/breakdown_item.dart' as domain_breakdown;
import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_request.dart';
import '../models/payment_model.dart';
import '../models/payment_request_model.dart';

class PaymentFirestoreDataSource {
  final FirebaseFirestore _firestore;

  const PaymentFirestoreDataSource(this._firestore);

  Stream<PaymentRequest?> watchPaymentRequest(String requestId) {
    return _firestore
        .collection(FirestoreCollections.paymentRequests)
        .doc(requestId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return _paymentRequestFromDoc(doc);
    });
  }

  Stream<Payment?> watchPayment(String paymentId) {
    return _firestore
        .collection(FirestoreCollections.payments)
        .doc(paymentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return _paymentFromDoc(doc);
    });
  }

  Future<Payment?> getActivePayment({
    required String orderId,
    required String buyerId,
    required String paymentRequestId,
  }) async {
    final snap = await _firestore
        .collection(FirestoreCollections.payments)
        .where('orderId', isEqualTo: orderId)
        .where('buyerId', isEqualTo: buyerId)
        .where('paymentRequestId', isEqualTo: paymentRequestId)
        .where('status', whereIn: const ['pending', 'processing'])
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _paymentFromDoc(snap.docs.first);
  }

  Future<Payment> updatePendingPayment({
    required String paymentId,
    required String type,
    String? description,
    required double amountUsd,
    required double exchangeRateAtPayment,
    required String paidCurrency,
    double paidAmount = 0,
    required String method,
    required String providerRef,
  }) async {
    final ref = _firestore.collection(FirestoreCollections.payments).doc(paymentId);
    final update = <String, dynamic>{
      'type': type,
      'amountUsd': amountUsd,
      'exchangeRateAtPayment': exchangeRateAtPayment,
      'paidCurrency': paidCurrency,
      'paidAmount': paidAmount,
      'method': method,
      'providerRef': providerRef,
      'status': 'pending',
      'initiatedAt': FieldValue.serverTimestamp(),
    };
    if (description != null) {
      update['description'] = description;
    }
    await ref.update(update);
    final snap = await ref.get();
    return _paymentFromDoc(snap);
  }

  /// Create payment document; Cloud Function updates after Paystack webhook.
  Future<Payment> createPayment({
    required String orderId,
    required String buyerId,
    required String paymentRequestId,
    required String type,
    String? description,
    required double amountUsd,
    required double exchangeRateAtPayment,
    required String paidCurrency,
    double paidAmount = 0,
    required String method,
    required String providerRef,
  }) async {
    final ref = _firestore.collection(FirestoreCollections.payments).doc();
    final data = <String, dynamic>{
      'orderId': orderId,
      'buyerId': buyerId,
      'paymentRequestId': paymentRequestId,
      'type': type,
      'amountUsd': amountUsd,
      'exchangeRateAtPayment': exchangeRateAtPayment,
      'paidCurrency': paidCurrency,
      'paidAmount': paidAmount,
      'method': method,
      'provider': 'paystack',
      'providerRef': providerRef,
      'status': 'pending',
      'initiatedAt': FieldValue.serverTimestamp(),
    };
    if (description != null) data['description'] = description;
    await ref.set(data);
    final snapshot = await ref.get();
    return _paymentFromDoc(snapshot);
  }
}

PaymentRequest _paymentRequestFromDoc(DocumentSnapshot doc) {
  final m = PaymentRequestModel.fromFirestore(doc);
  return PaymentRequest(
    id: m.id,
    orderId: m.orderId,
    createdByAgentId: m.createdByAgentId ?? '',
    paymentId: m.paymentId,
    type: m.type.firestoreValue,
    description: m.description,
    breakdown: [
      for (final b in m.breakdown)
        domain_breakdown.BreakdownItem(
          label: b.label,
          amountUsd: b.amountUsd,
          isDeduction: b.isDeduction,
        ),
    ],
    amountUsd: m.amountUsd,
    exchangeRateAtRequest: m.exchangeRateAtRequest ?? 0,
    depositDeductedUsd: m.depositDeductedUsd,
    deadlineAt: m.deadlineAt,
    status: m.status,
    sentAt: m.sentAt,
    paidAt: m.paidAt,
    expiredAt: m.expiredAt,
    cancelledAt: m.cancelledAt,
  );
}

Payment _paymentFromDoc(DocumentSnapshot doc) {
  final m = PaymentModel.fromFirestore(doc);
  return Payment(
    id: m.id,
    orderId: m.orderId,
    buyerId: m.buyerId,
    paymentRequestId: m.paymentRequestId ?? '',
    type: m.type,
    description: m.description,
    amountUsd: m.amountUsd,
    exchangeRateAtPayment: m.exchangeRateAtPayment ?? 0,
    paidCurrency: m.paidCurrency,
    paidAmount: m.paidAmount,
    method: m.method ?? '',
    provider: m.provider ?? '',
    providerRef: m.providerRef,
    status: m.status,
    initiatedAt: m.initiatedAt,
    confirmedAt: m.confirmedAt,
    refundedAt: m.refundedAt,
  );
}
