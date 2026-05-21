import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches Paystack checkout using a server-generated [authorizationUrl].
///
/// Call ONLY after `initializePaystackTransaction` has returned the URL.
///
/// **Mobile** — opens checkout in an in-app WebView. Returns `true` when the
/// user completes payment, `false` if they cancel or an error occurs.
///
/// **Web** — opens [authorizationUrl] in a new browser tab. Returns `true` if
/// the tab opened successfully. Payment completion is handled by the Paystack
/// webhook; show the processing screen after a successful launch.
Future<bool> launchPaystackCheckout({
  required BuildContext context,
  required String authorizationUrl,
  required String reference,
  required String customerEmail,
  required double amountGhs,
}) async {
  if (kIsWeb) {
    return _openPaystackAuthorizationInBrowser(authorizationUrl);
  }
  return _launchPaystackCheckoutMobile(
    context: context,
    authorizationUrl: authorizationUrl,
    reference: reference,
    customerEmail: customerEmail,
    amountGhs: amountGhs,
  );
}

/// Opens the server-initialized Paystack checkout URL in a new browser tab.
Future<bool> _openPaystackAuthorizationInBrowser(String authorizationUrl) async {
  final uri = Uri.tryParse(authorizationUrl);
  if (uri == null || !uri.hasScheme) {
    debugPrint(
      '[launchPaystackCheckout] invalid authorization URL: $authorizationUrl',
    );
    return false;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
    if (!launched) {
      debugPrint(
        '[launchPaystackCheckout] launchUrl returned false for $authorizationUrl',
      );
    }
    return launched;
  } catch (e, st) {
    debugPrint('[launchPaystackCheckout] web launch error: $e\n$st');
    return false;
  }
}

Future<bool> _launchPaystackCheckoutMobile({
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
    debugPrint('[launchPaystackCheckout] mobile error: $e');
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
