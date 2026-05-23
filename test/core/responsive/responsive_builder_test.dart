import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/breakpoints.dart';
import 'package:flutter_claude_app_v2/core/responsive/responsive_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveValue.resolve', () {
    const value = ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 3);

    test('按类型取值', () {
      expect(value.resolve(ScreenType.mobile), 1);
      expect(value.resolve(ScreenType.tablet), 2);
      expect(value.resolve(ScreenType.desktop), 3);
    });

    test('largeDesktop 缺省 → 回退 desktop', () {
      expect(value.resolve(ScreenType.largeDesktop), 3);
    });

    test('只给 mobile 时全部回退到 mobile', () {
      const only = ResponsiveValue<String>(mobile: 'm');
      expect(only.resolve(ScreenType.tablet), 'm');
      expect(only.resolve(ScreenType.desktop), 'm');
      expect(only.resolve(ScreenType.largeDesktop), 'm');
    });
  });

  group('ResponsiveBuilder', () {
    // 设置整窗口宽度（让 LayoutBuilder 的 maxWidth = width，不被测试默认 800 钳制）
    Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = Size(width, 600);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(home: child));
    }

    final builder = ResponsiveBuilder(
      mobile: (_) => const Text('MOBILE'),
      tablet: (_) => const Text('TABLET'),
      desktop: (_) => const Text('DESKTOP'),
    );

    testWidgets('窄约束 → mobile builder', (tester) async {
      await pumpAt(tester, 400, builder);
      expect(find.text('MOBILE'), findsOneWidget);
    });

    testWidgets('中约束 → tablet builder', (tester) async {
      await pumpAt(tester, 800, builder);
      expect(find.text('TABLET'), findsOneWidget);
    });

    testWidgets('宽约束 → desktop builder', (tester) async {
      await pumpAt(tester, 1200, builder);
      expect(find.text('DESKTOP'), findsOneWidget);
    });

    testWidgets('largeDesktop 缺省 → 回退 desktop builder', (tester) async {
      await pumpAt(tester, 1600, builder);
      expect(find.text('DESKTOP'), findsOneWidget);
    });
  });
}
