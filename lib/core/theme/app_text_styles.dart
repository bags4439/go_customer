import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextTheme textTheme(ColorScheme scheme) {
    final base = TextTheme(
      displayLarge: const TextStyle(fontSize: 48, fontWeight: FontWeight.w700),
      displayMedium: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
      displaySmall: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      headlineMedium: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface.withValues(alpha: 0.75),
      ),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    );

    return GoogleFonts.dmSansTextTheme(base);
  }
}
