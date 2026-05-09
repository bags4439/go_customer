import 'package:cloud_functions/cloud_functions.dart';

/// Calls the initializePaystackTransaction Cloud Function.
///
/// Returns authorizationUrl, reference, paymentId and amountGhs on success.
/// Throws on failure.
class PaymentCloudService {
  final FirebaseFunctions _functions;

  PaymentCloudService(this._functions);

  Future<PaystackInitResult> initializeTransaction({
    required String orderId,
    required String requestId,
    required String email,
  }) async {
    final callable = _functions.httpsCallable('initializePaystackTransaction');

    final result = await callable.call<Map<String, dynamic>>({
      'orderId': orderId,
      'requestId': requestId,
      'email': email,
    });

    final data = result.data;
    return PaystackInitResult(
      authorizationUrl: data['authorizationUrl'] as String,
      reference: data['reference'] as String,
      paymentId: data['paymentId'] as String,
      amountGhs: (data['amountGhs'] as num).toDouble(),
    );
  }
}

/// Result from initializePaystackTransaction Cloud Function.
class PaystackInitResult {
  final String authorizationUrl;
  final String reference;
  final String paymentId;
  final double amountGhs;

  const PaystackInitResult({
    required this.authorizationUrl,
    required this.reference,
    required this.paymentId,
    required this.amountGhs,
  });
}
