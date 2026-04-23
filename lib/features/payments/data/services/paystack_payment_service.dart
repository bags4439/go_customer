import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';

import '../../../../core/constants/app_constants.dart';

/// Initiates Paystack popup (MoMo/card). Uses [reference] so the webhook can find the payment doc.
/// Call after creating the payment document with this reference.
/// Returns true if user completed successfully, false if cancelled/error or key not set.
/// [chargeAmountGhs] is the charge amount in GHS (major units); pesewas = amount × 100.
Future<bool> initiatePaystackCharge({
  required BuildContext context,
  required String reference,
  required double chargeAmountGhs,
  required String customerEmail,
}) async {
  final key = AppConstants.paystackSecretKey;
  if (key.isEmpty || key.startsWith('CHANGE_ME')) {
    return false;
  }

  final completer = Completer<bool>();
  final amountInMinor = (chargeAmountGhs * 100).round();
  try {
    unawaited(
      FlutterPaystackPlus.openPaystackPopup(
        context: context,
        customerEmail: customerEmail,
        amount: amountInMinor.toString(),
        reference: reference,
        secretKey: key,
        callBackUrl: AppConstants.paystackCallBackUrl,
        currency: 'GHS',
        onSuccess: () {
          if (!completer.isCompleted) completer.complete(true);
        },
        onClosed: () {
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    return completer.future;
  } catch (_) {
    if (!completer.isCompleted) completer.complete(false);
    return false;
  }
}

/// Generate a unique reference for Paystack. Stored in payments.providerRef.
String generatePaystackReference(String orderId, String requestId) {
  return 'pay_${orderId}_${requestId}_${DateTime.now().millisecondsSinceEpoch}';
}
