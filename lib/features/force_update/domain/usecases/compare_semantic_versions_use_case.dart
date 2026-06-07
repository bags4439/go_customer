/// Compares dotted semantic versions (e.g. 1.10.0 vs 1.9.0).
class CompareSemanticVersionsUseCase {
  /// Returns `true` when [installed] is strictly older than [minimum].
  bool isUpdateRequired(String installed, String minimum) {
    final installedParts = _parse(installed);
    final minimumParts = _parse(minimum);
    if (installedParts == null || minimumParts == null) {
      return false;
    }

    for (var i = 0; i < 3; i++) {
      if (installedParts[i] < minimumParts[i]) return true;
      if (installedParts[i] > minimumParts[i]) return false;
    }
    return false;
  }

  List<int>? _parse(String version) {
    final cleaned = version.split('+').first.trim();
    if (cleaned.isEmpty) return null;

    final segments = cleaned.split('.');
    if (segments.isEmpty) return null;

    try {
      final parts = <int>[];
      for (var i = 0; i < 3; i++) {
        if (i < segments.length) {
          final numeric = segments[i].replaceAll(RegExp(r'[^0-9]'), '');
          if (numeric.isEmpty) return null;
          parts.add(int.parse(numeric));
        } else {
          parts.add(0);
        }
      }
      return parts;
    } catch (_) {
      return null;
    }
  }
}
