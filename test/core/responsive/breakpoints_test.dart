import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Breakpoints.fromWidth', () {
    test('< 600 → mobile', () {
      expect(Breakpoints.fromWidth(0), ScreenType.mobile);
      expect(Breakpoints.fromWidth(599.9), ScreenType.mobile);
    });

    test('600 ~ 1024 → tablet', () {
      expect(Breakpoints.fromWidth(600), ScreenType.tablet);
      expect(Breakpoints.fromWidth(1023.9), ScreenType.tablet);
    });

    test('1024 ~ 1440 → desktop', () {
      expect(Breakpoints.fromWidth(1024), ScreenType.desktop);
      expect(Breakpoints.fromWidth(1439.9), ScreenType.desktop);
    });

    test('> 1440 → largeDesktop', () {
      expect(Breakpoints.fromWidth(1440), ScreenType.largeDesktop);
      expect(Breakpoints.fromWidth(2560), ScreenType.largeDesktop);
    });
  });

  group('ResponsiveContext 扩展', () {
    Future<void> pumpWidth(WidgetTester tester, double width) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }

    testWidgets('isMobile / isTabletOrLarger 正确', (tester) async {
      await pumpWidth(tester, 400);
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        })),
      );
      expect(ctx.isMobile, isTrue);
      expect(ctx.isTabletOrLarger, isFalse);
    });

    testWidgets('宽屏 → isDesktop', (tester) async {
      await pumpWidth(tester, 1300);
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        })),
      );
      expect(ctx.isDesktop, isTrue);
      expect(ctx.isTabletOrLarger, isTrue);
    });
  });
}
