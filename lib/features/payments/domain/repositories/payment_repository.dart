import '../../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../entities/payment.dart';

abstract class PaymentRepository {
  Stream<Payment?> watchPayment(String paymentId);
  Future<Either<Failure, Payment>> createPayment({
    required String orderId,
    required String buyerId,
    required String paymentRequestId,
    required String type,
    String? description,
    required double amountGhs,
    required double amountUsd,
    required double exchangeRate,
    required String method,
    required String providerRef,
  });
}
