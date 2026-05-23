import 'package:flutter/animation.dart';

/// 动效 Token（T10.1）— 统一的曲线 + 时长。
///
/// 与 M07/T07.7 的 [PageTransitions] 配合：转场时长 / 曲线统一从这里取，
/// 保证全应用动效节奏一致。
abstract final class MotionTokens {
  // ── 时长 ────────────────────────────────────
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slowest = Duration(milliseconds: 600);

  // ── 曲线 ────────────────────────────────────
  /// 标准进出（大多数过渡）
  static const Curve standard = Curves.easeInOutCubic;

  /// 强调进入（元素出现，先快后慢）
  static const Curve emphasizedDecelerate = Curves.easeOutCubic;

  /// 强调退出（元素消失，先慢后快）
  static const Curve emphasizedAccelerate = Curves.easeInCubic;

  /// 弹性（用于微交互 / 强调反馈）
  static const Curve bounce = Curves.elasticOut;
}
