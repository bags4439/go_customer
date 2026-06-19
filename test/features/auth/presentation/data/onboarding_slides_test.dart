import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/presentation/data/onboarding_slides.dart';

void main() {
  group('kOnboardingSlides mobileHeroOffsetFraction', () {
    test('each slide has a clampable offset within 0.0–0.5', () {
      for (final slide in kOnboardingSlides) {
        expect(slide.mobileHeroOffsetFraction, greaterThanOrEqualTo(0.0));
        expect(slide.mobileHeroOffsetFraction, lessThanOrEqualTo(0.5));
      }
    });

    test('agent slide uses the largest offset', () {
      final offsets =
          kOnboardingSlides.map((s) => s.mobileHeroOffsetFraction).toList();

      expect(offsets[1], 0.40);
      expect(offsets[1], equals(offsets.reduce((a, b) => a > b ? a : b)));
    });
  });
}
