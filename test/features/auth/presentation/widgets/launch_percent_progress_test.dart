import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/auth/presentation/widgets/launch_percent_progress.dart';

void main() {
  group('LaunchPercentProgress', () {
    testWidgets('renders clamped percent label and fill', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LaunchPercentProgress(percent: 85),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('clamps percent below zero and above one hundred', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LaunchPercentProgress(percent: 150),
          ),
        ),
      );

      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('exposes loading semantics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LaunchPercentProgress(percent: 40),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(LaunchPercentProgress)),
        matchesSemantics(label: 'Loading 40 percent'),
      );
    });
  });
}
