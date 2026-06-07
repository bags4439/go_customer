import 'compare_semantic_versions_use_case.dart';

class CheckForceUpdateRequiredUseCase {
  CheckForceUpdateRequiredUseCase(this._compareVersions);

  final CompareSemanticVersionsUseCase _compareVersions;

  /// Returns `true` when the installed build is below [minimumVersion].
  /// Missing or invalid minimum versions fail open (no update required).
  bool call({
    required String installedVersion,
    String? minimumVersion,
  }) {
    final minimum = minimumVersion?.trim();
    if (minimum == null || minimum.isEmpty) {
      return false;
    }

    return _compareVersions.isUpdateRequired(installedVersion, minimum);
  }
}
