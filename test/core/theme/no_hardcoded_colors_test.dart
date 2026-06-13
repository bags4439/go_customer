import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces that colour literals live only in [AppColors].
void main() {
  test('lib has no inline Color(0x literals outside app_colors.dart', () {
    final libDir = Directory('lib');
    final violations = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('app_colors.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].contains('Color(0x')) {
          violations.add('${entity.path}:${i + 1}: ${lines[i].trim()}');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Move literals to AppColors:\n${violations.join('\n')}',
    );
  });
}
