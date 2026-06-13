import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/features/support/presentation/widgets/support_contact_section.dart';

void main() {
  group('SupportHoursRow', () {
    testWidgets('does not overflow in narrow web panel content width', (
      tester,
    ) async {
      final overflowErrors = <FlutterErrorDetails>[];
      final previousHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) {
          overflowErrors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = previousHandler);

      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 220,
              child: SupportHoursRow(
                day: 'Monday – Friday',
                hours: '8:00 AM – 6:00 PM',
              ),
            ),
          ),
        ),
      );

      expect(overflowErrors, isEmpty);
      expect(find.text('Monday – Friday'), findsOneWidget);
      expect(find.text('8:00 AM – 6:00 PM'), findsOneWidget);
    });

    testWidgets('SupportHoursCard fits inside narrow web panel column', (
      tester,
    ) async {
      final overflowErrors = <FlutterErrorDetails>[];
      final previousHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) {
          overflowErrors.add(details);
        }
      };
      addTearDown(() => FlutterError.onError = previousHandler);

      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 250,
              child: SupportHoursCard(),
            ),
          ),
        ),
      );

      expect(overflowErrors, isEmpty);
      expect(find.text('SUPPORT HOURS'), findsOneWidget);
    });
  });
}
