/// Public app links and optional referrer reward amount from `system_settings`.
class ReferralShareSettings {
  const ReferralShareSettings({
    this.referralDiscountGhs,
    this.appStoreUrl,
    this.playstoreUrl,
    this.appUrl,
    this.websiteUrl,
  });

  final double? referralDiscountGhs;
  final String? appStoreUrl;
  final String? playstoreUrl;

  /// Flutter web app (e.g. https://app.whiplyn.com).
  final String? appUrl;

  /// Marketing / landing site (e.g. https://whiplyn.com).
  final String? websiteUrl;

  bool get hasDiscount =>
      referralDiscountGhs != null && referralDiscountGhs! > 0;

  bool get hasAnyLink {
    return _nonEmpty(appStoreUrl) ||
        _nonEmpty(playstoreUrl) ||
        _nonEmpty(appUrl) ||
        _nonEmpty(websiteUrl);
  }

  static bool _nonEmpty(String? s) => s != null && s.trim().isNotEmpty;
}
