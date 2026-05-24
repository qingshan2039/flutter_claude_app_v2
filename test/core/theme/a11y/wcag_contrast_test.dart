import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/a11y/wcag_contrast.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/color_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// T22.2：WCAG 对比度工具单测 + Design Token 满足 AA 的「对比度报告」。
///
/// 业务语义色（success/warning/info）是**手挑**的色值，必须验证其与配对前景
/// （on*）满足 WCAG AA（普通文字 4.5:1）。运行本测试即生成对比度报告。
void main() {
  group('WcagContrast 工具 (T22.2)', () {
    test('黑白对比度为最大值 21:1', () {
      expect(
        WcagContrast.ratio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
    });

    test('同色对比度为 1:1', () {
      expect(
        WcagContrast.ratio(const Color(0xFF6750A4), const Color(0xFF6750A4)),
        closeTo(1, 0.001),
      );
    });

    test('与顺序无关', () {
      const a = Color(0xFF2E7D32);
      const b = Color(0xFFFFFFFF);
      expect(WcagContrast.ratio(a, b), WcagContrast.ratio(b, a));
    });

    test('grade 评级正确', () {
      expect(
        WcagContrast.grade(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        'AAA',
      );
      // 浅灰文字配白底 → 不达标
      expect(
        WcagContrast.grade(const Color(0xFFBBBBBB), const Color(0xFFFFFFFF)),
        'Fail',
      );
    });
  });

  group('Design Token 对比度报告：业务语义色满足 WCAG AA (T22.2)', () {
    // 配对：前景(on*) vs 背景(语义色)
    final pairs = <String, ({Color fg, Color bg})>{
      'success (light)': (fg: ColorTokens.onSuccess, bg: ColorTokens.success),
      'warning (light)': (fg: ColorTokens.onWarning, bg: ColorTokens.warning),
      'info (light)': (fg: ColorTokens.onInfo, bg: ColorTokens.info),
      'success (dark)': (
        fg: ColorTokens.onSuccessDark,
        bg: ColorTokens.successDark,
      ),
      'warning (dark)': (
        fg: ColorTokens.onWarningDark,
        bg: ColorTokens.warningDark,
      ),
      'info (dark)': (fg: ColorTokens.onInfoDark, bg: ColorTokens.infoDark),
    };

    pairs.forEach((name, p) {
      test('$name 满足 AA（≥4.5:1）', () {
        final r = WcagContrast.ratio(p.fg, p.bg);
        // 打印对比度报告，便于人工/CI 查看
        debugPrint(
          '  $name: ${r.toStringAsFixed(2)}:1  '
          '[${WcagContrast.grade(p.fg, p.bg)}]',
        );
        expect(
          WcagContrast.meetsAA(foreground: p.fg, background: p.bg),
          isTrue,
          reason: '$name 对比度 ${r.toStringAsFixed(2)}:1 < 4.5:1',
        );
      });
    });
  });
}
