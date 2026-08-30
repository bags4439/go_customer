import '../constants/app_constants.dart';

/// Classifies inbound URIs for app entry vs Paystack return.
abstract final class AppEntryLink {
  AppEntryLink._();

  static bool isPaystackCallback(Uri uri) {
    if (uri.scheme == AppBrandingDefaults.deepLinkScheme) {
      return uri.host == 'payment' &&
          (uri.path.isEmpty || uri.path == '/' || uri.path == '/callback');
    }
    if (!_isAppWebHost(uri)) return false;
    return uri.path == '/payment/callback';
  }

  /// HTTPS / custom-scheme opens that land on login or home only.
  static bool isAppEntry(Uri uri) {
    if (isPaystackCallback(uri)) return false;
    if (uri.scheme == AppBrandingDefaults.deepLinkScheme) return true;
    return _isAppWebHost(uri);
  }

  static bool _isAppWebHost(Uri uri) {
    if (uri.scheme != 'https' && uri.scheme != 'http') return false;
    return uri.host == AppBrandingDefaults.appWebHost;
  }
}
