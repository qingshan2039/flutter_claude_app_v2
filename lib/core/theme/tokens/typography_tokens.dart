import 'package:flutter/material.dart';

/// 字号 Token（T10.1）— 对齐 Material 3 type scale。
///
/// 这里只定义字号 / 字重 / 行高常量；[TextTheme] 在 app_theme.dart 中用这些常量装配。
/// UI 通过 `Theme.of(context).textTheme.titleLarge` 等访问，不直接引用本类。
abstract final class TypographyTokens {
  // 字号（dp）
  static const double displayLarge = 57;
  static const double displayMedium = 45;
  static const double displaySmall = 36;
  static const double headlineLarge = 32;
  static const double headlineMedium = 28;
  static const double headlineSmall = 24;
  static const double titleLarge = 22;
  static const double titleMedium = 16;
  static const double titleSmall = 14;
  static const double bodyLarge = 16;
  static const double bodyMedium = 14;
  static const double bodySmall = 12;
  static const double labelLarge = 14;
  static const double labelMedium = 12;
  static const double labelSmall = 11;

  // 字重
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // 行高倍数（相对字号）
  static const double tightLineHeight = 1.2;
  static const double normalLineHeight = 1.4;
  static const double relaxedLineHeight = 1.6;
}
