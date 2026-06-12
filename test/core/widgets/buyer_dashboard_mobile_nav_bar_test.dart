import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/widgets/buyer_dashboard_mobile_nav_bar.dart';

void _setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('portrait tablet nav bar stays short (not full-screen height)', (
    tester,
  ) async {
    _setViewport(tester, const Size(768, 1024));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: BuyerDashboardMobileNavBar(
            selectedIndex: 0,
            unreadCount: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final navBar = tester.getSize(
      find.byType(BuyerDashboardMobileNavBar),
    );
    expect(navBar.height, lessThan(120));
    expect(navBar.height, greaterThan(60));
  });

  testWidgets('portrait tablet nav pill is above screen centre', (
    tester,
  ) async {
    _setViewport(tester, const Size(768, 1024));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: BuyerDashboardMobileNavBar(
            selectedIndex: 0,
            unreadCount: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final pill = tester.getCenter(find.byType(Container).first);
    expect(pill.dy, greaterThan(900));
  });
}
