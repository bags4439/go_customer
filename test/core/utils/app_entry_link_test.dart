import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/utils/app_entry_link.dart';

void main() {
  group('AppEntryLink', () {
    test('treats app host opens as entry, ignoring path', () {
      expect(
        AppEntryLink.isAppEntry(Uri.parse('https://app.whiplyn.com')),
        isTrue,
      );
      expect(
        AppEntryLink.isAppEntry(
          Uri.parse('https://app.whiplyn.com/order/abc'),
        ),
        isTrue,
      );
      expect(
        AppEntryLink.isAppEntry(Uri.parse('https://whiplyn.com')),
        isFalse,
      );
    });

    test('does not treat Paystack callbacks as entry', () {
      final native = Uri.parse('whiplyn://payment/callback');
      final web = Uri.parse('https://app.whiplyn.com/payment/callback');

      expect(AppEntryLink.isPaystackCallback(native), isTrue);
      expect(AppEntryLink.isPaystackCallback(web), isTrue);
      expect(AppEntryLink.isAppEntry(native), isFalse);
      expect(AppEntryLink.isAppEntry(web), isFalse);
    });

    test('treats non-Paystack custom scheme as entry', () {
      expect(
        AppEntryLink.isAppEntry(Uri.parse('whiplyn://open')),
        isTrue,
      );
    });
  });
}
