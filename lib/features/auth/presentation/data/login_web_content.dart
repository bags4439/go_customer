import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../referral/domain/entities/referral_share_settings.dart';

/// Single source of truth for all
/// web login and account setup
/// left panel content.
///
/// To change any panel text or
/// tiles edit only this file.
/// Mobile and portrait-tablet layouts
/// reuse panels via [MobileAuthShell].

class LoginWebPanel {
  const LoginWebPanel({
    required this.eyebrow,
    required this.heading,
    required this.subheading,
    required this.tiles,
  });

  final String eyebrow;
  final String heading;
  final String subheading;
  final List<LoginWebTile> tiles;
}

class LoginWebTile {
  const LoginWebTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
    required this.label,
    this.sublabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  /// Left border accent colour
  /// for the context tile on web
  final Color accentColor;

  final String label;

  /// Optional second line of text
  final String? sublabel;
}

class LoginPhoneWelcomeCopy {
  const LoginPhoneWelcomeCopy({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

LoginPhoneWelcomeCopy loginPhoneWelcomeCopy({required bool isReturning}) {
  return isReturning
      ? const LoginPhoneWelcomeCopy(
          title: 'Welcome back.',
          subtitle:
              'Enter your phone number to receive a verification code.',
        )
      : const LoginPhoneWelcomeCopy(
          title: 'Sign in to get started.',
          subtitle:
              'Enter your phone number to receive a verification code.',
        );
}

/// Compact phone / portrait-tablet login tiles (agent + pricing).
List<LoginWebTile> loginTrustTilesForPhone() {
  final tiles = kLoginWebPanels['login']!.tiles;
  return [tiles[0], tiles[2]];
}

/// Full login trust tiles for web split layout.
List<LoginWebTile> loginTrustTilesForWeb() =>
    kLoginWebPanels['login']!.tiles;

/// Referral step tiles — tile 2 reflects [settings.referralDiscountGhs].
List<LoginWebTile> buildReferralTrustTiles(ReferralShareSettings settings) {
  final amountTile = settings.hasDiscount
      ? LoginWebTile(
          icon: Icons.card_giftcard_outlined,
          iconBg: const Color(0xFFEAF3DE),
          iconColor: const Color(0xFF27500A),
          accentColor: const Color(0xFF1D9E75),
          label:
              'Up to ${CurrencyFormatter.formatGhs(settings.referralDiscountGhs!)} '
              'in referral rewards',
          sublabel:
              'Your friend stands a chance to win when you '
              'complete your order',
        )
      : const LoginWebTile(
          icon: Icons.card_giftcard_outlined,
          iconBg: Color(0xFFEAF3DE),
          iconColor: Color(0xFF27500A),
          accentColor: Color(0xFF1D9E75),
          label: 'Referral rewards for your friend',
          sublabel:
              'They stand a chance to win when you complete your order',
        );

  return [
    kReferralOptionalTile,
    amountTile,
    kReferralOwnCodeTile,
  ];
}

const LoginWebTile kReferralOptionalTile = LoginWebTile(
  icon: Icons.skip_next_outlined,
  iconBg: Color(0xFFE6F1FB),
  iconColor: Color(0xFF185FA5),
  accentColor: Color(0xFF378ADD),
  label: 'Optional step',
  sublabel: 'Skip if you weren\'t referred',
);

const LoginWebTile kReferralOwnCodeTile = LoginWebTile(
  icon: Icons.people_outline_rounded,
  iconBg: Color(0xFFFAEEDA),
  iconColor: Color(0xFF633806),
  accentColor: Color(0xFFBA7517),
  label: 'You\'ll get your own code',
  sublabel: 'Share it from your profile after signup',
);

/// Panel content for each login
/// step. All steps use the same
/// photo (onboarding_preference.jpg)
/// but different text and tiles.
const Map<String, LoginWebPanel> kLoginWebPanels = {
  /// phone + otp steps share
  /// the same panel content
  'login': LoginWebPanel(
    eyebrow: 'TRUSTED BY BUYERS ACROSS GHANA',
    heading: 'Your car,\nsourced globally.',
    subheading:
        'From US to Dubai to China,'
        ' your dedicated agent sources,'
        ' manages shipping and clearance,'
        ' and keeps you updated every step.',
    tiles: [
      LoginWebTile(
        icon: Icons.support_agent_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        accentColor: Color(0xFF378ADD),
        label: 'Dedicated agent per order',
        sublabel: 'One person from search to delivery',
      ),
      LoginWebTile(
        icon: Icons.notifications_active_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        accentColor: Color(0xFF1D9E75),
        label: 'Live order updates',
        sublabel: 'Chat, timeline, and documents in one place',
      ),
      LoginWebTile(
        icon: Icons.receipt_long_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        accentColor: Color(0xFFBA7517),
        label: 'Clear cost breakdown',
        sublabel: 'See fees before you pay',
      ),
    ],
  ),

  'name': LoginWebPanel(
    eyebrow: 'STEP 1 OF 3 · YOUR PROFILE',
    heading: 'It all starts\nwith a name.',
    subheading:
        'Your agent is a real person'
        ' who will address you by'
        ' name throughout your'
        ' entire import journey.',
    tiles: [
      LoginWebTile(
        icon: Icons.person_outline_rounded,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        accentColor: Color(0xFF378ADD),
        label:
            'Your agent knows who'
            ' to contact',
      ),
      LoginWebTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        accentColor: Color(0xFF1D9E75),
        label:
            'Personal communication'
            ' throughout',
      ),
      LoginWebTile(
        icon: Icons.verified_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        accentColor: Color(0xFFBA7517),
        label:
            'Required for port'
            ' clearance documents',
      ),
    ],
  ),

  'referral': LoginWebPanel(
    eyebrow: 'STEP 2 OF 3 · REFERRAL',
    heading: 'Were you referred?',
    subheading:
        'If a friend referred you, enter their code. They stand a '
        'chance to win referral rewards when you complete your order.',
    tiles: [],
  ),

  'contactChannels': LoginWebPanel(
    eyebrow: 'STEP 3 OF 3 · STAY IN THE LOOP',
    heading: 'Never miss\na moment.',
    subheading:
        'We\'ll keep you updated on'
        ' your order progress via'
        ' the channels you choose.',
    tiles: [],
  ),
};
