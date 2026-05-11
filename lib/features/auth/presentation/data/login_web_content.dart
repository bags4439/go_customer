import 'package:flutter/material.dart';

/// Single source of truth for all
/// web login and account setup
/// left panel content.
///
/// To change any panel text or
/// tiles edit only this file.
/// Mobile layout is unchanged.

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
    required this.label,
    this.sublabel,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;

  /// Optional second line of text
  final String? sublabel;
}

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
        'From US auctions to Dubai'
        ' dealers — your dedicated'
        ' agent manages everything'
        ' so you don\'t have to.',
    tiles: [
      LoginWebTile(
        icon: Icons.map_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: '48+ vehicles imported',
        sublabel: 'Across Ghana',
      ),
      LoginWebTile(
        icon: Icons.star_outline_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: '4.9 ★ customer rating',
        sublabel: 'Average across all orders',
      ),
      LoginWebTile(
        icon: Icons.receipt_long_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: '100% transparent pricing',
        sublabel: 'No hidden fees ever',
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
        label:
            'Your agent knows who'
            ' to contact',
      ),
      LoginWebTile(
        icon: Icons.chat_bubble_outline_rounded,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label:
            'Personal communication'
            ' throughout',
      ),
      LoginWebTile(
        icon: Icons.verified_outlined,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label:
            'Required for port'
            ' clearance documents',
      ),
    ],
  ),

  'referral': LoginWebPanel(
    eyebrow: 'STEP 2 OF 3 · REFERRAL',
    heading: 'Share the journey.\nEarn rewards.',
    subheading:
        'If a friend referred you,'
        ' enter their code. They'
        ' earn a reward when you'
        ' complete your first order.',
    tiles: [
      LoginWebTile(
        icon: Icons.card_giftcard_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: 'GHS 500 reward',
        sublabel: 'Per successful referral',
      ),
      LoginWebTile(
        icon: Icons.flash_on_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'Instant credit',
        sublabel: 'Applied on order completion',
      ),
      LoginWebTile(
        icon: Icons.people_outline_rounded,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: 'No limit on referrals',
        sublabel: 'Refer as many as you want',
      ),
    ],
  ),

  'contactChannels': LoginWebPanel(
    eyebrow: 'STEP 3 OF 3 · STAY IN THE LOOP',
    heading: 'Never miss\na moment.',
    subheading:
        'We\'ll keep you updated on'
        ' your order progress via'
        ' the channels you choose.',
    tiles: [
      LoginWebTile(
        icon: Icons.sms_outlined,
        iconBg: Color(0xFFE6F1FB),
        iconColor: Color(0xFF185FA5),
        label: 'SMS',
        sublabel:
            'Payment requests and'
            ' key milestones',
      ),
      LoginWebTile(
        icon: Icons.chat_outlined,
        iconBg: Color(0xFFEAF3DE),
        iconColor: Color(0xFF27500A),
        label: 'WhatsApp',
        sublabel:
            'Rich updates with order'
            ' details',
      ),
      LoginWebTile(
        icon: Icons.mail_outline_rounded,
        iconBg: Color(0xFFFAEEDA),
        iconColor: Color(0xFF633806),
        label: 'Email',
        sublabel:
            'Payment receipts and'
            ' order summaries',
      ),
    ],
  ),
};
