import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/theme/app_colors.dart';

void main() {
  group('AppColors semantic tokens', () {
    test('brand and foreground are distinct roles', () {
      expect(AppColors.brand, isNot(AppColors.foreground));
      expect(AppColors.brand, const Color(0xFF2563A8));
      expect(AppColors.foreground, AppColors.textPrimary);
    });

    test('legacy aliases point at brand', () {
      expect(AppColors.primary, AppColors.brand);
      expect(AppColors.secondary, AppColors.brand);
      expect(AppColors.onPrimary, AppColors.onBrand);
    });

    test('chat tokens are defined', () {
      expect(AppColors.chatSentBubble, isA<Color>());
      expect(AppColors.chatSentTimestamp, isA<Color>());
      expect(AppColors.composerBackground, isA<Color>());
    });

    test('shimmer tokens are defined', () {
      expect(AppColors.shimmerBase, isA<Color>());
      expect(AppColors.shimmerHighlight, isA<Color>());
    });
  });
}
