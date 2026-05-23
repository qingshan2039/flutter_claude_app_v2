import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme.dart';
import 'package:flutter_claude_app_v2/core/theme/status_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStatusBar.styleFor', () {
    test('浅色背景 → 深色状态栏图标', () {
      final style = AppStatusBar.styleFor(Brightness.light);
      expect(style.statusBarIconBrightness, Brightness.dark);
      expect(style.statusBarBrightness, Brightness.light);
    });

    test('深色背景 → 浅色状态栏图标', () {
      final style = AppStatusBar.styleFor(Brightness.dark);
      expect(style.statusBarIconBrightness, Brightness.light);
      expect(style.statusBarBrightness, Brightness.dark);
    });

    test('状态栏透明', () {
      expect(
        AppStatusBar.styleFor(Brightness.light).statusBarColor,
        Colors.transparent,
      );
    });

    test('系统导航栏图标亮度与背景相反', () {
      expect(
        AppStatusBar.styleFor(Brightness.dark).systemNavigationBarIconBrightness,
        Brightness.light,
      );
      expect(
        AppStatusBar.styleFor(Brightness.light).systemNavigationBarIconBrightness,
        Brightness.dark,
      );
    });
  });

  group('ThemedStatusBar widget', () {
    testWidgets('light 主题下注入深色图标 overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const ThemedStatusBar(
            child: Scaffold(body: Text('content')),
          ),
        ),
      );

      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(region.value.statusBarIconBrightness, Brightness.dark);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('dark 主题下注入浅色图标 overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const ThemedStatusBar(
            child: Scaffold(body: Text('content')),
          ),
        ),
      );

      final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(region.value.statusBarIconBrightness, Brightness.light);
    });
  });
}
