import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_firestore_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentFirestoreDataSource _dataSource;

  PaymentRepositoryImpl(this._dataSource);

  @override
  Stream<Payment?> watchPayment(String paymentId) {
    return _dataSource.watchPayment(paymentId);
  }

  @override
  Future<Either<Failure, Payment>> upsertPendingPayment({
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
    try {
      final existing = await _dataSource.getActivePayment(
        orderId: orderId,
        buyerId: buyerId,
        paymentRequestId: paymentRequestId,
      );
      final payment = existing != null
          ? await _dataSource.updatePendingPayment(
              paymentId: existing.id,
              type: type,
              description: description,
              amountUsd: amountUsd,
              exchangeRateAtPayment: exchangeRateAtPayment,
              paidCurrency: paidCurrency,
              paidAmount: paidAmount,
              method: method,
              providerRef: providerRef,
            )
          : await _dataSource.createPayment(
              orderId: orderId,
              buyerId: buyerId,
              paymentRequestId: paymentRequestId,
              type: type,
              description: description,
              amountUsd: amountUsd,
              exchangeRateAtPayment: exchangeRateAtPayment,
              paidCurrency: paidCurrency,
              paidAmount: paidAmount,
              method: method,
              providerRef: providerRef,
            );
      return Right(payment);
    } catch (e, st) {
      return Left(PaymentFailure(message: e.toString(), cause: st));
    }
  }
}
