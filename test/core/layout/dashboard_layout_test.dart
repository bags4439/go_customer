import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/layout/dashboard_layout.dart';

Widget _probe(Widget Function(BuildContext) builder) {
  return MaterialApp(
    home: Builder(builder: builder),
  );
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('DashboardLayout', () {
    testWidgets('phone is not portrait tablet', (tester) async {
      _setViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        _probe((context) {
          expect(DashboardLayout.isPortraitTablet(context), isFalse);
          return const SizedBox();
        }),
      );
    });

    testWidgets('portrait tablet is detected', (tester) async {
      _setViewport(tester, const Size(768, 1024));

      await tester.pumpWidget(
        _probe((context) {
          expect(DashboardLayout.isPortraitTablet(context), isTrue);
          return const SizedBox();
        }),
      );
    });

    testWidgets('DashboardPortraitFrame wraps portrait tablet only', (
      tester,
    ) async {
      _setViewport(tester, const Size(768, 1024));

      await tester.pumpWidget(
        _probe(
          (context) => const DashboardPortraitFrame(
            child: Text('content'),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
      expect(find.byType(ColoredBox), findsWidgets);
    });
  });
}
