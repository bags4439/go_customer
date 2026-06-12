import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/layout/dashboard_layout.dart';
import 'package:go_customer/core/theme/app_colors.dart';

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
          expect(DashboardLayout.usesMobileContentFrame(context), isTrue);
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

    testWidgets('phone horizontal inset is 16dp', (tester) async {
      _setViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        _probe((context) {
          expect(
            DashboardLayout.bodyContentHorizontalPadding(context),
            0,
          );
          expect(
            DashboardLayout.phoneGutterPadding(context).left,
            DashboardLayout.mobileHorizontalInset,
          );
          return const SizedBox();
        }),
      );
    });

    testWidgets('DashboardPortraitFrame uses surface canvas on phone', (
      tester,
    ) async {
      _setViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        _probe(
          (context) => const DashboardPortraitFrame(
            child: Text('content'),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);

      final surfaceBoxes = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .where((box) => box.color == AppColors.surface);
      expect(surfaceBoxes, isNotEmpty);

      final whiteBoxes = tester
          .widgetList<ColoredBox>(find.byType(ColoredBox))
          .where((box) => box.color == AppColors.background);
      expect(whiteBoxes, isEmpty);
    });

    testWidgets('DashboardPortraitFrame wraps portrait tablet with max width', (
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

      final constrained = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(DashboardPortraitFrame),
          matching: find.byType(ConstrainedBox),
        ),
      );
      expect(
        constrained.constraints.maxWidth,
        DashboardLayout.contentMaxWidth,
      );
    });
  });
}
