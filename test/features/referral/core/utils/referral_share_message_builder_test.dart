import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/referral/core/utils/referral_share_message_builder.dart';
import 'package:go_customer/features/referral/domain/entities/referral_share_settings.dart';

void main() {
  group('ReferralShareMessageBuilder', () {
    test('opens with invitation line, not a bare duplicate app name', () {
      final message = ReferralShareMessageBuilder.build(
        settings: const ReferralShareSettings(
          appUrl: 'https://app.whiplyn.com',
        ),
        referralCode: 'YHSQGB',
      );

      expect(message.startsWith('Join me on Whiplyn.'), isTrue);
      expect(message.startsWith('Whiplyn\n'), isFalse);
      expect(message, contains('My referral code: YHSQGB'));
      expect(message, contains('Web: https://app.whiplyn.com'));
      expect(message.trimRight(), endsWith('— Whiplyn'));
    });

    test('uses appUrl for Web line, not marketing websiteUrl', () {
      final message = ReferralShareMessageBuilder.build(
        settings: const ReferralShareSettings(
          appUrl: 'https://app.whiplyn.com',
          websiteUrl: 'https://whiplyn.com',
        ),
        referralCode: 'ABC',
      );

      expect(message, contains('Web: https://app.whiplyn.com'));
      expect(message, isNot(contains('Web: https://whiplyn.com')));
    });
  });
}
