import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards against reintroducing legacy product name or domain in Dart UI code.
void main() {
  test('lib/ has no legacy AutoImport or autoimportgh branding strings', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue);

    const banned = [
      'AutoImport GH',
      'AutoImport',
      'autoimportgh.com',
      'support@autoimportgh.com',
    ];

    final violations = <String>[];

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      for (final needle in banned) {
        if (content.contains(needle)) {
          violations.add('${entity.path}: contains "$needle"');
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason: violations.join('\n'),
    );
  });
}
