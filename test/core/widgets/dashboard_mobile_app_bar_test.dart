import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/theme/app_colors.dart';
import 'package:go_customer/core/widgets/dashboard_mobile_app_bar.dart';

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('DashboardMobileTitleAppBar', () {
    testWidgets('uses surface background and toolbar on portrait tablet', (
      tester,
    ) async {
      _setViewport(tester, const Size(768, 1024));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DashboardMobileTitleAppBar(
              title: 'Test',
              onBack: () {},
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.surface);
      expect(find.byType(DashboardAppBarToolbar), findsOneWidget);
      expect(find.byType(DashboardAppBarIconButton), findsOneWidget);
    });

    testWidgets('uses surface background and toolbar on phone', (tester) async {
      _setViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: DashboardMobileTitleAppBar(
              title: 'Test',
              onBack: () {},
            ),
          ),
        ),
      );

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.surface);
      expect(find.byType(DashboardAppBarToolbar), findsOneWidget);
      expect(find.byType(DashboardAppBarIconButton), findsOneWidget);
    });
  });

  group('dashboardMobileAppBarBackground', () {
    testWidgets('is surface on mobile shell', (tester) async {
      _setViewport(tester, const Size(390, 844));

      Color? color;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              color = dashboardMobileAppBarBackground(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(color, AppColors.surface);
    });
  });
}
