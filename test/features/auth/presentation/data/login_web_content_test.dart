import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/presentation/data/login_web_content.dart';
import 'package:go_customer/features/referral/domain/entities/referral_share_settings.dart';

void main() {
  group('loginPhoneWelcomeCopy', () {
    test('returning users see Welcome back', () {
      final copy = loginPhoneWelcomeCopy(isReturning: true);
      expect(copy.title, 'Welcome back.');
    });

    test('first-time users see Sign in to get started', () {
      final copy = loginPhoneWelcomeCopy(isReturning: false);
      expect(copy.title, 'Sign in to get started.');
    });
  });

  group('loginTrustTilesForPhone', () {
    test('returns exactly two tiles', () {
      expect(loginTrustTilesForPhone(), hasLength(2));
    });

    test('includes agent and pricing tiles', () {
      final labels = loginTrustTilesForPhone().map((t) => t.label).toList();
      expect(labels, contains('Dedicated agent per order'));
      expect(labels, contains('Clear cost breakdown'));
    });
  });

  group('loginTrustTilesForWeb', () {
    test('returns all three login tiles', () {
      expect(loginTrustTilesForWeb(), hasLength(3));
    });
  });

  group('buildReferralTrustTiles', () {
    test('includes amount when referral discount is set', () {
      final tiles = buildReferralTrustTiles(
        const ReferralShareSettings(referralDiscountGhs: 500),
      );
      expect(tiles, hasLength(3));
      expect(tiles[1].label, contains('GHS 500'));
      expect(tiles[1].sublabel, contains('stands a chance to win'));
    });

    test('uses generic copy when amount is missing', () {
      final tiles = buildReferralTrustTiles(const ReferralShareSettings());
      expect(tiles[1].label, 'Referral rewards for your friend');
    });

    test('first tile is optional step', () {
      final tiles = buildReferralTrustTiles(const ReferralShareSettings());
      expect(tiles.first.label, 'Optional step');
    });
  });

  group('kLoginWebPanels referral', () {
    test('heading and subheading match agreed copy', () {
      final panel = kLoginWebPanels['referral']!;
      expect(panel.heading, 'Were you referred?');
      expect(panel.subheading, contains('stand a chance to win'));
      expect(panel.subheading, isNot(contains('draw')));
    });
  });
}
