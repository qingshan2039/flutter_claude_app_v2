import 'package:flutter/widgets.dart';

/// 间距 Token（T10.1）— 4dp 基准的间距阶梯。
///
/// 统一所有 padding / margin / gap 取这些常量，避免散落的魔法数字。
abstract final class SpacingTokens {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // 常用 EdgeInsets 快捷方式
  static const EdgeInsets pagePadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);

  // 常用间隔 Widget（垂直）
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);

  // 常用间隔 Widget（水平）
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
}
