import 'package:flutter/material.dart';
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

  group('OnboardingSlide heroPushFromBottom', () {
    test('resolves mobile vs portrait tablet push', () {
      const slide = OnboardingSlide(
        imagePath: 'assets/test.png',
        eyebrow: 'TEST',
        title: 'Title',
        subtitle: 'Subtitle',
        buttonLabel: 'Go',
        accentColor: Color(0xFF000000),
        tiles: [],
        mobileHeroPushFromBottom: 0.35,
        portraitTabletHeroPushFromBottom: 0.20,
      );

      expect(slide.heroPushFromBottom(portraitTablet: false), 0.35);
      expect(slide.heroPushFromBottom(portraitTablet: true), 0.20);
    });
  });

  group('kOnboardingSlides hero push values', () {
    test('each slide has clampable mobile and portrait tablet push', () {
      for (final slide in kOnboardingSlides) {
        expect(slide.mobileHeroPushFromBottom, inInclusiveRange(0.0, 0.5));
        expect(
          slide.portraitTabletHeroPushFromBottom,
          inInclusiveRange(0.0, 0.5),
        );
      }
    });

    test('preferences and agent slides use the largest mobile push', () {
      final pushes =
          kOnboardingSlides.map((s) => s.mobileHeroPushFromBottom).toList();

      expect(pushes[0], 0.35);
      expect(pushes[1], 0.35);
      expect(pushes[0], equals(pushes.reduce((a, b) => a > b ? a : b)));
    });
  });
}
