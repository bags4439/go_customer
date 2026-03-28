/// Public app links and optional referrer reward amount from `system_settings`.
class ReferralShareSettings {
  const ReferralShareSettings({
    this.referralDiscountGhs,
    this.appStoreUrl,
    this.playstoreUrl,
    this.websiteUrl,
  });

  final double? referralDiscountGhs;
  final String? appStoreUrl;
  final String? playstoreUrl;
  final String? websiteUrl;

  bool get hasDiscount =>
      referralDiscountGhs != null && referralDiscountGhs! > 0;

  bool get hasAnyLink {
    return _nonEmpty(appStoreUrl) ||
        _nonEmpty(playstoreUrl) ||
        _nonEmpty(websiteUrl);
  }

  static bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;
}
