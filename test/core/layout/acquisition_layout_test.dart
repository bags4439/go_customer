import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_customer/core/layout/acquisition_layout.dart';

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
  group('AcquisitionLayout', () {
    testWidgets('phone uses phone layout', (tester) async {
      _setViewport(tester, const Size(390, 844));

      await tester.pumpWidget(
        _probe((context) {
          expect(AcquisitionLayout.useWebLayout(context), isFalse);
          expect(AcquisitionLayout.isPortraitTablet(context), isFalse);
          return const SizedBox();
        }),
      );
    });

    testWidgets('tablet portrait uses phone layout with constraints', (
      tester,
    ) async {
      _setViewport(tester, const Size(768, 1024));

      await tester.pumpWidget(
        _probe((context) {
          expect(AcquisitionLayout.useWebLayout(context), isFalse);
          expect(AcquisitionLayout.isPortraitTablet(context), isTrue);
          expect(
            AcquisitionLayout.phoneContentMaxWidth(context),
            AcquisitionLayout.phoneColumnMaxWidth,
          );
          return const SizedBox();
        }),
      );
    });

    testWidgets('tablet landscape uses web layout below 960dp', (tester) async {
      _setViewport(tester, const Size(900, 700));

      await tester.pumpWidget(
        _probe((context) {
          expect(AcquisitionLayout.useWebLayout(context), isTrue);
          expect(AcquisitionLayout.isPortraitTablet(context), isFalse);
          return const SizedBox();
        }),
      );
    });

    testWidgets('desktop width always uses web layout', (tester) async {
      _setViewport(tester, const Size(1280, 800));

      await tester.pumpWidget(
        _probe((context) {
          expect(AcquisitionLayout.useWebLayout(context), isTrue);
          return const SizedBox();
        }),
      );
    });
  });
}
