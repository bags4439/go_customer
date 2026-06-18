import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/config/app_config.dart';
import 'package:go_customer/core/constants/app_constants.dart';

void main() {
  group('resolveAppConfig', () {
    test('returns code defaults when settings map is empty', () {
      final config = resolveAppConfig({});

      expect(config.displayName, 'Whiplyn');
      expect(config.supportEmail, 'support@whiplyn.com');
      expect(config.websiteUrl, 'https://whiplyn.com');
      expect(config.appUrl, 'https://app.whiplyn.com');
      expect(config.faqUrl, 'https://whiplyn.com/faq');
      expect(config.termsUrl, 'https://whiplyn.com/terms');
      expect(config.deepLinkScheme, 'whiplyn');
      expect(config.paystackCallbackUrl, 'whiplyn://payment/callback');
    });

    test('merges Firestore overrides for remote keys', () {
      final config = resolveAppConfig({
        SystemSettingsKeys.supportEmail: 'help@example.com',
        SystemSettingsKeys.websiteUrl: 'https://example.com',
        SystemSettingsKeys.appUrl: 'https://app.example.com',
        SystemSettingsKeys.faqUrl: 'https://example.com/help',
      });

      expect(config.supportEmail, 'help@example.com');
      expect(config.websiteUrl, 'https://example.com');
      expect(config.appUrl, 'https://app.example.com');
      expect(config.faqUrl, 'https://example.com/help');
      expect(config.termsUrl, 'https://example.com/terms');
      expect(config.displayName, 'Whiplyn');
    });

    test('derives faq and terms from overridden website when not set', () {
      final config = resolveAppConfig({
        SystemSettingsKeys.websiteUrl: 'https://shop.example.com/',
      });

      expect(config.faqUrl, 'https://shop.example.com/faq');
      expect(config.termsUrl, 'https://shop.example.com/terms');
      expect(config.appUrl, 'https://app.whiplyn.com');
    });
  });

  group('AppBrandingDefaults', () {
    test('urlPath normalizes trailing slash', () {
      expect(
        AppBrandingDefaults.urlPath('https://whiplyn.com/', 'faq'),
        'https://whiplyn.com/faq',
      );
    });
  });
}
