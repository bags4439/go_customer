import 'package:flutter/material.dart';

/// Single source of truth for all
/// web onboarding slide content.
///
/// To change any slide text or
/// tiles edit only this file.
/// Mobile content is unchanged —
/// it lives in onboarding_screen.dart

class OnboardingWebSlide {
  const OnboardingWebSlide({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.accentColor,
    required this.tiles,
    this.quote,
  });

  /// Small all-caps label above
  /// title. e.g. 'STEP 1 · YOUR
  /// PREFERENCES'
  final String eyebrow;

  /// Large heading — supports
  /// newlines with \n
  final String title;

  /// Body text below title
  final String subtitle;

  /// CTA button label
  final String buttonLabel;

  /// Accent colour for dots and
  /// button background
  final Color accentColor;

  /// 3 feature tiles per slide
  final List<OnboardingWebTile> tiles;

  /// Optional agent quote tile —
  /// only used on slide 2
  final OnboardingWebQuote? quote;
}

class OnboardingWebTile {
  const OnboardingWebTile({
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

class OnboardingWebQuote {
  const OnboardingWebQuote({
    required this.initials,
    required this.name,
    required this.text,
  });

  final String initials;
  final String name;
  final String text;
}

/// All four onboarding slides for
/// the web layout. Edit here to
/// update web slide content.
const List<OnboardingWebSlide> kOnboardingWebSlides = [
  OnboardingWebSlide(
    eyebrow: 'STEP 1 · YOUR PREFERENCES',
    title: 'Tell us what\nyou want.',
    subtitle:
        'Point us to your dream car'
        ' — make, model, budget.'
        ' We take it from there.',
    buttonLabel: 'Get started',
    accentColor: Color(0xFF234A83),
    tiles: [
      OnboardingWebTile(
        icon: Icons.directions_car_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label:
            'Choose make, model'
            ' and condition',
      ),
      OnboardingWebTile(
        icon: Icons.attach_money_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'Set your budget in USD',
      ),
      OnboardingWebTile(
        icon: Icons.public_rounded,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label:
            'Pick your preferred'
            ' import source',
      ),
    ],
  ),
  OnboardingWebSlide(
    eyebrow: 'STEP 2 · YOUR AGENT',
    title: 'Your personal\nagent.',
    subtitle:
        'A dedicated human agent'
        ' searches, negotiates, and'
        ' keeps you updated every'
        ' step of the way.',
    buttonLabel: 'Continue',
    accentColor: Color(0xFF0F6A25),
    tiles: [
      OnboardingWebTile(
        icon: Icons.search_rounded,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label:
            'Searches auctions across'
            ' US, Dubai and China',
      ),
      OnboardingWebTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label:
            'Communicates via chat'
            ' and call directly',
      ),
      OnboardingWebTile(
        icon: Icons.description_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label:
            'Sends real options with'
            ' condition reports',
      ),
    ],
    quote: OnboardingWebQuote(
      initials: 'EB',
      name: 'Ernest · Senior Agent',
      text:
          '"I found 3 matching vehicles'
          ' at Copart. Here are the'
          ' estimates and condition'
          ' reports."',
    ),
  ),
  OnboardingWebSlide(
    eyebrow: 'STEP 3 · THE JOURNEY',
    title: 'We handle\nthe journey.',
    subtitle:
        'Shipping, port clearance,'
        ' duty, repairs — tracked'
        ' end to end. You watch,'
        ' we handle it.',
    buttonLabel: 'Continue',
    accentColor: Color(0xFF8C6B00),
    tiles: [
      OnboardingWebTile(
        icon: Icons.directions_boat_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label:
            'Shipping booked'
            ' and tracked',
      ),
      OnboardingWebTile(
        icon: Icons.account_balance_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label:
            'Port clearance and'
            ' duty handled',
      ),
      OnboardingWebTile(
        icon: Icons.build_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label:
            'Repairs arranged'
            ' if needed',
      ),
    ],
  ),
  OnboardingWebSlide(
    eyebrow: 'STEP 4 · ROAD READY',
    title: 'Road ready.\nDelivered.',
    subtitle:
        'Your car arrives road-ready'
        ' at your door. Keys in hand'
        ' — just the way you'
        ' imagined it.',
    buttonLabel: 'Create account',
    accentColor: Color(0xFF378ADD),
    tiles: [
      OnboardingWebTile(
        icon: Icons.verified_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label:
            'Car inspected and'
            ' road-ready',
      ),
      OnboardingWebTile(
        icon: Icons.home_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label:
            'Delivered to your door',
      ),
      OnboardingWebTile(
        icon: Icons.star_outline_rounded,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label:
            'Rate your experience',
      ),
    ],
  ),
];
