import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

/// Launches the Paystack checkout WebView using a pre-generated authorization URL
/// from the server.
///
/// Call ONLY after initializePaystackTransaction Cloud Function has returned the
/// authorizationUrl.
///
/// Returns true if the user completed the flow, false if cancelled or an error
/// occurred.
Future<bool> launchPaystackCheckout({
  required BuildContext context,
  required String authorizationUrl,
  required String reference,
  required String customerEmail,
  required double amountGhs,
}) async {
  final completer = Completer<bool>();
  final amountInPesewas = (amountGhs * 100).round();

  try {
    unawaited(
      FlutterPaystackPlus.openPaystackPopup(
        context: context,
        customerEmail: customerEmail,
        amount: amountInPesewas.toString(),
        reference: reference,
        authorizationUrl: authorizationUrl,
        currency: 'GHS',
        onSuccess: () {
          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onClosed: () {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      ),
    );
    return completer.future;
  } catch (e) {
    debugPrint('[launchPaystackCheckout] error: $e');
    if (!completer.isCompleted) {
      completer.complete(false);
    }
    return false;
  }
}

/// Generates a unique Paystack reference. Used as a fallback only — the server
/// generates the authoritative reference.
String generatePaystackReference(String orderId, String requestId) {
  return 'pay_${orderId}_${requestId}_${DateTime.now().millisecondsSinceEpoch}';
}
