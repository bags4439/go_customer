/// Result of evaluating whether the installed app must be updated.
class ForceUpdateRequirement {
  const ForceUpdateRequirement._({
    required this.isRequired,
    this.installedVersion,
    this.minimumVersion,
    this.storeUrl,
    this.storeLabel,
    this.isIos = false,
  });

  final bool isRequired;
  final String? installedVersion;
  final String? minimumVersion;
  final String? storeUrl;
  final String? storeLabel;
  final bool isIos;

  bool get hasStoreUrl {
    final url = storeUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  factory ForceUpdateRequirement.notRequired() {
    return const ForceUpdateRequirement._(isRequired: false);
  }

  factory ForceUpdateRequirement.required({
    required String installedVersion,
    required String minimumVersion,
    required String? storeUrl,
    required String storeLabel,
    required bool isIos,
  }) {
    return ForceUpdateRequirement._(
      isRequired: true,
      installedVersion: installedVersion,
      minimumVersion: minimumVersion,
      storeUrl: storeUrl,
      storeLabel: storeLabel,
      isIos: isIos,
    );
  }
}
