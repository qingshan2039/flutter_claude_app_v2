import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('light 主题 brightness=light，Material3', () {
      final t = AppTheme.light;
      expect(t.brightness, Brightness.light);
      expect(t.colorScheme.brightness, Brightness.light);
      expect(t.useMaterial3, isTrue);
    });

    test('dark 主题 brightness=dark', () {
      final t = AppTheme.dark;
      expect(t.brightness, Brightness.dark);
      expect(t.colorScheme.brightness, Brightness.dark);
    });

    test('light 与 dark 的 colorScheme 不同', () {
      expect(
        AppTheme.light.colorScheme.surface,
        isNot(AppTheme.dark.colorScheme.surface),
      );
    });
  });

  group('AppColorsExtension 注入主题', () {
    test('light 主题含 light 业务色', () {
      final ext = AppTheme.light.extension<AppColorsExtension>();
      expect(ext, isNotNull);
      expect(ext!.success, AppColorsExtension.light.success);
    });

    test('dark 主题含 dark 业务色', () {
      final ext = AppTheme.dark.extension<AppColorsExtension>();
      expect(ext, isNotNull);
      expect(ext!.success, AppColorsExtension.dark.success);
    });
  });

  group('AppColorsExtension lerp / copyWith', () {
    test('copyWith 改单个字段', () {
      const original = AppColorsExtension.light;
      final modified = original.copyWith(success: const Color(0xFF123456));
      expect(modified.success, const Color(0xFF123456));
      expect(modified.warning, original.warning); // 未改
    });

    test('lerp t=0 返回起点，t=1 返回终点', () {
      const a = AppColorsExtension.light;
      const b = AppColorsExtension.dark;
      final at0 = a.lerp(b, 0);
      final at1 = a.lerp(b, 1);
      expect(at0.success, a.success);
      expect(at1.success, b.success);
    });

    test('lerp 中间值在两端之间', () {
      const a = AppColorsExtension.light;
      const b = AppColorsExtension.dark;
      final mid = a.lerp(b, 0.5);
      expect(mid.success, Color.lerp(a.success, b.success, 0.5));
    });
  });

  group('context.appColors 扩展', () {
    testWidgets('从 Theme 读到业务色', (tester) async {
      late Color success;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) {
              success = context.appColors.success;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(success, AppColorsExtension.light.success);
    });
  });
}
