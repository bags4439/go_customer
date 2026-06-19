import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/presentation/data/onboarding_slides.dart';
import 'package:go_customer/features/auth/presentation/widgets/onboarding_widgets.dart';

void main() {
  group('mobileHeroCoverViewportFraction', () {
    test('viewport equals 1 minus push from bottom', () {
      expect(mobileHeroCoverViewportFraction(0.20), 0.80);
      expect(mobileHeroCoverViewportFraction(0.40), 0.60);
      expect(mobileHeroCoverViewportFraction(0.0), 1.0);
    });

    test('clamps push to 0.5 maximum', () {
      expect(mobileHeroCoverViewportFraction(0.75), 0.5);
    });
  });

  group('kOnboardingSlides mobileHeroPushFromBottom', () {
    test('each slide has a clampable push within 0.0–0.5', () {
      for (final slide in kOnboardingSlides) {
        expect(slide.mobileHeroPushFromBottom, greaterThanOrEqualTo(0.0));
        expect(slide.mobileHeroPushFromBottom, lessThanOrEqualTo(0.5));
      }
    });

    test('journey slide uses the largest push', () {
      final pushes =
          kOnboardingSlides.map((s) => s.mobileHeroPushFromBottom).toList();

      expect(pushes[2], 0.30);
      expect(pushes[2], equals(pushes.reduce((a, b) => a > b ? a : b)));
    });
  });
}
