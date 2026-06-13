import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/layout/dashboard_layout.dart';
import 'package:go_customer/features/preferences/presentation/widgets/preferences_widgets.dart';

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('PreferencesResponsiveColumn', () {
    testWidgets('web shell uses panel width with flow scroll gutters', (
      tester,
    ) async {
      _setViewport(tester, const Size(1200, 800));
      const panelWidth = 560.0;
      double? innerMaxWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: panelWidth,
              child: PreferencesResponsiveColumn(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      innerMaxWidth = constraints.maxWidth;
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final horizontal =
          DashboardLayout.flowScrollPadding(tester.element(find.byType(LayoutBuilder))).horizontal;
      expect(innerMaxWidth, panelWidth - (horizontal * 2));
    });

    testWidgets('mobile shell centres portrait tablet column at 520', (
      tester,
    ) async {
      _setViewport(tester, const Size(768, 1024));
      double? innerMaxWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: PreferencesResponsiveColumn(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  innerMaxWidth = constraints.maxWidth;
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      final horizontal = DashboardLayout.bodyContentHorizontalPadding(
        tester.element(find.byType(LayoutBuilder)),
      );
      expect(innerMaxWidth, 520 - (horizontal * 2));
    });
  });
}
