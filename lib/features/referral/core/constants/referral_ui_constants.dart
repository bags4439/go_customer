/// Copy for referral promo on home (no hardcoded strings in widgets).
class ReferralUiConstants {
  ReferralUiConstants._();

  static const String cardTitle = 'Invite & Earn Rewards 🎁';
  static const String inviteFriendsCta = 'Invite Friends';

  static const String quickLinksHeading = 'Get the app';
  static const String linkAppStore = 'App Store';
  static const String linkGooglePlay = 'Google Play';
  static const String linkWebsite = 'Website';

  /// Shown when [referralDiscountAmount] is present (amount inserted between prefix/suffix).
  static const String bodyWithRewardPrefix =
      'Earn a fixed credit of ';
  static const String bodyWithRewardMiddle =
      ' when a friend joins with your code and completes onboarding. ';
  static const String bodyPerks =
      'Top referrers can unlock extra perks and qualify for prize draws.';

  static const String bodyGeneric =
      'Invite friends to import with us using your referral code. ';
  static const String bodyGenericSuffix = bodyPerks;

  static const String yourCodeLabel = 'Your code';
  static const String copyCodeTooltip = 'Copy code';
  static const String codeCopied = 'Referral code copied';
  static const String codeMissingHint =
      'Your personal code appears once your profile is complete.';

  static String shareMessageFooter(String appName) => '\n\n— $appName';
}
