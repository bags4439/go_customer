import 'package:flutter/material.dart';

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
  });

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
    title: 'Tell us what\nyou want.',
    subtitle:
        'Point us to your dream car'
        ' , make, model, budget.'
        ' We take it from there.',
    buttonLabel: 'Get started',
    accentColor: Color(0xFF234A83),
    tiles: [
      OnboardingTile(
        icon: Icons.directions_car_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: 'Choose make, model and condition',
      ),
      OnboardingTile(
        icon: Icons.attach_money_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'Set your budget range',
      ),
      OnboardingTile(
        icon: Icons.public_rounded,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: 'Pick your preferred import source',
      ),
    ],
  ),
  OnboardingSlide(
    imagePath: 'assets/onboarding_agent.jpg',
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
      OnboardingTile(
        icon: Icons.search_rounded,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: 'Searches auctions across US, Dubai and China',
      ),
      OnboardingTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'Communicates via chat and call directly',
      ),
      OnboardingTile(
        icon: Icons.description_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: 'Sends real options with condition reports',
      ),
    ],
    quote: OnboardingQuote(
      initials: 'EB',
      name: 'Ernest · Senior Agent',
      text:
          '"I found 3 matching vehicles'
          ' at Copart. Here are the'
          ' estimates and condition'
          ' reports."',
    ),
  ),
  OnboardingSlide(
    imagePath: 'assets/onboarding_journey.jpg',
    eyebrow: 'STEP 3 · THE JOURNEY',
    title: 'We handle\nthe journey.',
    subtitle:
        'Shipping, port clearance,'
        ' duty, repairs tracked'
        ' end to end. You watch,'
        ' we handle it.',
    buttonLabel: 'Continue',
    accentColor: Color(0xFF8C6B00),
    tiles: [
      OnboardingTile(
        icon: Icons.directions_boat_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: 'Shipping booked and tracked',
      ),
      OnboardingTile(
        icon: Icons.account_balance_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'Port clearance and duty handled',
      ),
      OnboardingTile(
        icon: Icons.build_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: 'Repairs arranged if needed',
      ),
    ],
  ),
  OnboardingSlide(
    imagePath: 'assets/onboarding_ready.jpg',
    eyebrow: 'STEP 4 · ROAD READY',
    title: 'Road ready.\nDelivered.',
    subtitle:
        'Your car arrives road-ready'
        ' , delivered to you or ready'
        ' for collection. Keys in hand.',
    buttonLabel: 'Continue',
    accentColor: Color(0xFF378ADD),
    tiles: [
      OnboardingTile(
        icon: Icons.verified_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'Car inspected and road-ready',
      ),
      OnboardingTile(
        icon: Icons.home_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: 'Delivery or collection',
      ),
      OnboardingTile(
        icon: Icons.star_outline_rounded,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: 'Rate your experience',
      ),
    ],
  ),
];
