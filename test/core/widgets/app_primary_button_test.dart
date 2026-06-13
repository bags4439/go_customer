import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/theme/app_theme.dart';
import 'package:go_customer/core/widgets/app_primary_button.dart';

void main() {
  testWidgets('AppTheme maps brand to filled buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: FilledButton(
            onPressed: () {},
            child: const Text('Themed'),
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(FilledButton));
    final theme = Theme.of(context);
    expect(theme.colorScheme.primary, AppColors.brand);
    expect(theme.colorScheme.onPrimary, AppColors.onBrand);
    expect(theme.colorScheme.secondary, AppColors.accent);
    expect(theme.appBarTheme.foregroundColor, AppColors.foreground);
    expect(
      theme.filledButtonTheme.style?.backgroundColor?.resolve({}),
      AppColors.brand,
    );
  });

  testWidgets('AppPrimaryButton uses brand fill from theme system', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve({}),
      AppColors.brand,
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppPrimaryButton prominent applies brand shadow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Continue',
            onPressed: () {},
            prominent: true,
          ),
        ),
      ),
    );

    expect(find.byType(DecoratedBox), findsOneWidget);
  });

  testWidgets('AppPrimaryButton shows loading spinner on brand background', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: AppPrimaryButton(
            label: 'Continue',
            onPressed: null,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style?.backgroundColor?.resolve({}),
      AppColors.brand,
    );
  });
}
