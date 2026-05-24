import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// WCAG 2.1 颜色对比度工具（T22.2）。
///
/// 计算两色之间的对比度，并判断是否满足 WCAG AA / AAA。用于：
/// - 单测里校验 Design Token（success/warning/info 等）满足 AA（见
///   `test/core/theme/a11y/wcag_contrast_test.dart`，即「对比度报告」）；
/// - 业务里运行时校验自定义配色。
///
/// 阈值（前景文字 vs 背景）：
/// | 级别 | 普通文字 | 大文字(≥18pt 或 14pt 粗) |
/// |---|---|---|
/// | AA  | 4.5:1 | 3:1 |
/// | AAA | 7:1   | 4.5:1 |
///
/// ```dart
/// WcagContrast.ratio(Colors.white, const Color(0xFF2E7D32)); // 5.13
/// WcagContrast.meetsAA(fg: Colors.white, bg: brand);          // true/false
/// ```
abstract final class WcagContrast {
  /// AA 普通文字阈值。
  static const double aaNormal = 4.5;

  /// AA 大文字阈值。
  static const double aaLarge = 3;

  /// AAA 普通文字阈值。
  static const double aaaNormal = 7;

  /// AAA 大文字阈值。
  static const double aaaLarge = 4.5;

  /// 单通道线性化（sRGB → 线性 RGB），输入/输出均为 0..1。
  static double _linearize(double channel) => channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

  /// 相对亮度（WCAG 定义），范围 0（黑）..1（白）。
  static double relativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// 两色对比度，范围 1.0（无对比）..21.0（黑白）。与前后顺序无关。
  static double ratio(Color a, Color b) {
    final la = relativeLuminance(a);
    final lb = relativeLuminance(b);
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// 是否满足 AA（[largeText] 为大文字）。
  static bool meetsAA({
    required Color foreground,
    required Color background,
    bool largeText = false,
  }) =>
      ratio(foreground, background) >= (largeText ? aaLarge : aaNormal);

  /// 是否满足 AAA（[largeText] 为大文字）。
  static bool meetsAAA({
    required Color foreground,
    required Color background,
    bool largeText = false,
  }) =>
      ratio(foreground, background) >= (largeText ? aaaLarge : aaaNormal);

  /// 评级标签：`AAA` / `AA` / `AA Large` / `Fail`（普通文字视角）。
  static String grade(Color foreground, Color background) {
    final r = ratio(foreground, background);
    if (r >= aaaNormal) return 'AAA';
    if (r >= aaNormal) return 'AA';
    if (r >= aaLarge) return 'AA Large';
    return 'Fail';
  }
}
