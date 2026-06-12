import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/layout/app_breakpoints.dart';

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
  group('AppBreakpoints shell', () {
    testWidgets('phone uses mobile shell', (tester) async {
      _setViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        _probe((context) {
          expect(AppBreakpoints.useWebShell(context), isFalse);
          expect(AppBreakpoints.useMobileShell(context), isTrue);
          return const SizedBox();
        }),
      );
    });

    testWidgets('portrait tablet uses mobile shell', (tester) async {
      _setViewport(tester, const Size(768, 1024));

      await tester.pumpWidget(
        _probe((context) {
          expect(AppBreakpoints.useWebShell(context), isFalse);
          expect(AppBreakpoints.useMobileShell(context), isTrue);
          return const SizedBox();
        }),
      );
    });

    testWidgets('landscape tablet uses web shell below 960dp', (tester) async {
      _setViewport(tester, const Size(900, 700));

      await tester.pumpWidget(
        _probe((context) {
          expect(AppBreakpoints.useWebShell(context), isTrue);
          expect(AppBreakpoints.useMobileShell(context), isFalse);
          return const SizedBox();
        }),
      );
    });

    testWidgets('desktop always uses web shell', (tester) async {
      _setViewport(tester, const Size(1280, 800));

      await tester.pumpWidget(
        _probe((context) {
          expect(AppBreakpoints.useWebShell(context), isTrue);
          expect(AppBreakpoints.useMobileShell(context), isFalse);
          return const SizedBox();
        }),
      );
    });
  });
}
