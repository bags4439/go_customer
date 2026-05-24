// Web-only Paystack checkout popup.
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Opens Paystack checkout in a centered browser popup window.
/// Returns false if the browser blocked the popup.
bool openPaystackCheckoutPopup(String authorizationUrl) {
  try {
    final result = js.context.callMethod(
      'openPaystackCheckoutPopup',
      [authorizationUrl],
    );
    return result == true;
  } catch (_) {
    return false;
  }
}
