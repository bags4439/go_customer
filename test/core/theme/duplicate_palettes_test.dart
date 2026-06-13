import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('duplicate feature palettes are removed', () {
    expect(
      File('lib/features/orders/presentation/widgets/home_theme.dart')
          .readAsStringSync()
          .contains('class HomeColors'),
      isFalse,
    );
    expect(
      File('lib/features/profile/presentation/widgets/profile_ui_tokens.dart')
          .readAsStringSync()
          .contains('class ProfileUi'),
      isFalse,
    );
    expect(
      File(
        'lib/features/orders/presentation/widgets/order_detail/order_detail_ui.dart',
      ).existsSync(),
      isFalse,
    );
  });

  test('lib/features has no HomeColors ProfileUi or OrderDetailUi references', () {
    final featuresDir = Directory('lib/features');
    final violations = <String>[];

    for (final entity in featuresDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      if (content.contains('HomeColors.')) {
        violations.add('${entity.path}: HomeColors');
      }
      if (content.contains('ProfileUi.')) {
        violations.add('${entity.path}: ProfileUi');
      }
      if (content.contains('OrderDetailUi.')) {
        violations.add('${entity.path}: OrderDetailUi');
      }
    }

    expect(
      violations,
      isEmpty,
      reason: violations.join('\n'),
    );
  });

  test('lib/features has no private hex colour palette constants', () {
    final featuresDir = Directory('lib/features');
    final violations = <String>[];
    final palettePattern = RegExp(r'const _k\w+ = 0x[0-9A-Fa-f]+;');
    final classPalettePattern = RegExp(r'class \w+Colors\b');

    for (final entity in featuresDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (palettePattern.hasMatch(line)) {
          violations.add('${entity.path}:${i + 1}: $line');
        }
        if (classPalettePattern.hasMatch(line)) {
          violations.add('${entity.path}:${i + 1}: $line');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Use AppColors tokens instead of per-feature palettes:\n'
          '${violations.join('\n')}',
    );
  });
}
