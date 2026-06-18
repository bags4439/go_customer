import '../constants/app_constants.dart';
import '../../shared/providers/system_settings_provider.dart';

/// Resolved app branding and support URLs (Firestore overrides + code defaults).
class AppConfig {
  const AppConfig({
    required this.displayName,
    required this.supportEmail,
    required this.webBaseUrl,
    required this.appUrl,
    required this.faqUrl,
    required this.termsUrl,
    required this.websiteUrl,
    required this.deepLinkScheme,
    required this.paystackCallbackUrl,
  });

  final String displayName;
  final String supportEmail;

  /// Marketing site base URL (landing, FAQ, terms).
  final String webBaseUrl;

  /// Flutter web app URL (login, product).
  final String appUrl;

  final String faqUrl;
  final String termsUrl;

  /// Same as [webBaseUrl] — public marketing website.
  final String websiteUrl;

  final String deepLinkScheme;
  final String paystackCallbackUrl;

  static final AppConfig defaults = AppConfig(
    displayName: AppBrandingDefaults.displayName,
    supportEmail: AppBrandingDefaults.supportEmail,
    webBaseUrl: AppBrandingDefaults.webBaseUrl,
    appUrl: AppBrandingDefaults.appWebUrl,
    faqUrl: AppBrandingDefaults.faqUrl,
    termsUrl: AppBrandingDefaults.termsUrl,
    websiteUrl: AppBrandingDefaults.websiteUrl,
    deepLinkScheme: AppBrandingDefaults.deepLinkScheme,
    paystackCallbackUrl: AppBrandingDefaults.paystackCallbackUrl,
  );
}

/// Merges [settings] from `system_settings` with [AppBrandingDefaults].
AppConfig resolveAppConfig(Map<String, dynamic> settings) {
  final websiteUrl = settings.stringValue(SystemSettingsKeys.websiteUrl) ??
      AppBrandingDefaults.websiteUrl;
  final appUrl = settings.stringValue(SystemSettingsKeys.appUrl) ??
      AppBrandingDefaults.appWebUrl;

  return AppConfig(
    displayName: AppBrandingDefaults.displayName,
    supportEmail: settings.stringValue(SystemSettingsKeys.supportEmail) ??
        AppBrandingDefaults.supportEmail,
    webBaseUrl: websiteUrl,
    appUrl: appUrl,
    faqUrl: settings.stringValue(SystemSettingsKeys.faqUrl) ??
        AppBrandingDefaults.urlPath(websiteUrl, 'faq'),
    termsUrl: settings.stringValue(SystemSettingsKeys.termsUrl) ??
        AppBrandingDefaults.urlPath(websiteUrl, 'terms'),
    websiteUrl: websiteUrl,
    deepLinkScheme: AppBrandingDefaults.deepLinkScheme,
    paystackCallbackUrl: AppBrandingDefaults.paystackCallbackUrl,
  );
}
