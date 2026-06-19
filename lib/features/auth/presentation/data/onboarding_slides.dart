import 'package:flutter/material.dart';
import 'package:go_customer/core/theme/app_colors.dart';

/// Single source of truth for all onboarding slide content (all breakpoints).
class OnboardingSlide {
  const OnboardingSlide({
    required this.imagePath,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.accentColor,
    required this.tiles,
    this.quote,
    this.mobileHeroPushFromBottom = 0,
    this.portraitTabletHeroPushFromBottom = 0,
  });

  /// Fraction of screen height reserved below the phone hero cover viewport
  /// (0.0–0.5). Cover height is `1.0 - mobileHeroPushFromBottom`.
  final double mobileHeroPushFromBottom;

  /// Portrait-tablet hero push (600–959dp, portrait). Same semantics as
  /// [mobileHeroPushFromBottom] but tuned for the floating-card bottom panel.
  final double portraitTabletHeroPushFromBottom;

  /// Resolves hero push for the current mobile-shell layout variant.
  double heroPushFromBottom({required bool portraitTablet}) =>
      portraitTablet
          ? portraitTabletHeroPushFromBottom
          : mobileHeroPushFromBottom;

  final String imagePath;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color accentColor;
  final List<OnboardingTile> tiles;
  final OnboardingQuote? quote;
}

class OnboardingTile {
  const OnboardingTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
}

class OnboardingQuote {
  const OnboardingQuote({
    required this.initials,
    required this.name,
    required this.text,
  });

  final String initials;
  final String name;
  final String text;
}

const List<OnboardingSlide> kOnboardingSlides = [
  OnboardingSlide(
    imagePath: 'assets/onboarding_preference.jpg',
    eyebrow: 'STEP 1 · YOUR PREFERENCES',
    title: 'Tell us what you want.',
    subtitle:
        'Share the car you have in mind:'
        ' make, model, and what matters'
        ' to you. Your agent handles the rest.',
    buttonLabel: 'Get started',
    accentColor: AppColors.onboardingAccentNavy,
    tiles: [
      OnboardingTile(
        icon: Icons.directions_car_outlined,
        iconBg: AppColors.infoBackground,
        iconColor: AppColors.accent,
        label: 'Describe the car you want',
      ),
      OnboardingTile(
        icon: Icons.attach_money_rounded,
        iconBg: AppColors.successMutedBackground,
        iconColor: AppColors.successMutedForeground,
        label: 'Share a budget guide (optional)',
      ),
      OnboardingTile(
        icon: Icons.public_rounded,
        iconBg: AppColors.amberBackground,
        iconColor: AppColors.amberText,
        label: 'US, Dubai, China, or let your agent decide',
      ),
    ],
    mobileHeroPushFromBottom: 0.35,
    portraitTabletHeroPushFromBottom: 0.0,
  ),
  OnboardingSlide(
    imagePath: 'assets/onboarding_agent.jpg',
    eyebrow: 'STEP 2 · YOUR AGENT',
    title: 'Your personal agent.',
    subtitle:
        'A dedicated agent sources,'
        ' negotiates, and guides you'
        ' with updates at every step,'
        ' in chat.',
    buttonLabel: 'Continue',
    accentColor: AppColors.onboardingAccentGreen,
    tiles: [
      OnboardingTile(
        icon: Icons.search_rounded,
        iconBg: AppColors.infoBackground,
        iconColor: AppColors.accent,
        label: 'Sources vehicles globally across US, Dubai, China and more',
      ),
      OnboardingTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconBg: AppColors.successMutedBackground,
        iconColor: AppColors.successMutedForeground,
        label: 'Communicates via chat and call directly',
      ),
      OnboardingTile(
        icon: Icons.description_outlined,
        iconBg: AppColors.amberBackground,
        iconColor: AppColors.amberText,
        label: 'Sends real options with photos, specs and cost breakdowns',
      ),
    ],
    quote: OnboardingQuote(
      initials: 'EB',
      name: 'Ernest · Senior Agent',
      text:
          '"I found 3 strong options that'
          ' fit what you described, from'
          ' different sources. Here are the'
          ' details and my recommendations."',
    ),
    mobileHeroPushFromBottom: 0.35,
    portraitTabletHeroPushFromBottom: 0.0,
  ),
  OnboardingSlide(
    imagePath: 'assets/onboarding_journey.jpg',
    eyebrow: 'STEP 3 · THE JOURNEY',
    title: 'We handle the journey.',
    subtitle:
        'Shipping, port clearance,'
        ' duty, repairs tracked'
        ' end to end. You watch,'
        ' we handle it.',
    buttonLabel: 'Continue',
    accentColor: AppColors.warningDark,
    tiles: [
      OnboardingTile(
        icon: Icons.directions_boat_outlined,
        iconBg: AppColors.infoBackground,
        iconColor: AppColors.accent,
        label: 'Shipping booked and tracked',
      ),
      OnboardingTile(
        icon: Icons.account_balance_outlined,
        iconBg: AppColors.successMutedBackground,
        iconColor: AppColors.successMutedForeground,
        label: 'Port clearance and duty handled',
      ),
      OnboardingTile(
        icon: Icons.build_outlined,
        iconBg: AppColors.amberBackground,
        iconColor: AppColors.amberText,
        label: 'Repairs discussed and arranged after clearance, if needed',
      ),
    ],
    mobileHeroPushFromBottom: 0.30,
    portraitTabletHeroPushFromBottom: 0.2,
  ),
  OnboardingSlide(
    imagePath: 'assets/onboarding_ready.jpg',
    eyebrow: 'STEP 4 · ROAD READY',
    title: 'Road ready. Delivered.',
    subtitle:
        'Your car arrives cleared and'
        ' road-ready, delivered to you'
        ' or ready for collection.'
        ' Keys in hand.',
    buttonLabel: 'Continue',
    accentColor: AppColors.brand,
    tiles: [
      OnboardingTile(
        icon: Icons.verified_outlined,
        iconBg: AppColors.successMutedBackground,
        iconColor: AppColors.successMutedForeground,
        label: 'Car inspected and road-ready',
      ),
      OnboardingTile(
        icon: Icons.home_outlined,
        iconBg: AppColors.infoBackground,
        iconColor: AppColors.accent,
        label: 'Delivery or collection',
      ),
      OnboardingTile(
        icon: Icons.star_outline_rounded,
        iconBg: AppColors.amberBackground,
        iconColor: AppColors.amberText,
        label: 'Rate your experience',
      ),
    ],
    mobileHeroPushFromBottom: 0.3,
    portraitTabletHeroPushFromBottom: 0.0,
  ),
];
