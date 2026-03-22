import '../entities/payment_request.dart';

abstract class PaymentRequestRepository {
  Stream<PaymentRequest?> watchPaymentRequest(String requestId);
}
