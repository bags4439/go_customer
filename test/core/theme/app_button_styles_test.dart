import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/theme/app_button_styles.dart';
import 'package:go_customer/core/theme/app_colors.dart';

void main() {
  group('AppButtonStyles', () {
    test('primary uses brand tokens', () {
      final style = AppButtonStyles.primary();
      expect(
        style.backgroundColor?.resolve({}),
        AppColors.brand,
      );
      expect(
        style.foregroundColor?.resolve({}),
        AppColors.onBrand,
      );
    });

    test('inversePrimary uses white fill and brand text', () {
      final style = AppButtonStyles.inversePrimary();
      expect(
        style.backgroundColor?.resolve({}),
        AppColors.background,
      );
      expect(
        style.foregroundColor?.resolve({}),
        AppColors.brand,
      );
    });

    test('destructive uses danger token', () {
      final style = AppButtonStyles.destructive();
      expect(
        style.backgroundColor?.resolve({}),
        AppColors.danger,
      );
    });

    test('success uses success token', () {
      final style = AppButtonStyles.success();
      expect(
        style.backgroundColor?.resolve({}),
        AppColors.success,
      );
    });

    test('accentFill accepts custom accent colour', () {
      const accent = Color(0xFF185FA5);
      final style = AppButtonStyles.accentFill(accent);
      expect(
        style.backgroundColor?.resolve({}),
        accent,
      );
    });
  });
}
