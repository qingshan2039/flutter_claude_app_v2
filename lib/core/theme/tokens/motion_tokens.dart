import 'package:flutter/animation.dart';
import 'package:flutter_claude_app_v2/core/router/page_transitions.dart' show PageTransitions;

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

  // ── M34 动效系统补充（T34.1）──────────────────
  /// Material 3「强调」标准曲线：表现力更强的进出（页面转场 / 入场动画）。
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);

  /// 按压反馈曲线（微交互按下/回弹，T34.5）。
  static const Curve pressable = Curves.easeOut;

  // ── 交错（stagger）────────────────────────────
  /// 列表项逐个入场时，相邻项之间的延迟步长（T34.1 / T34.5）。
  static const Duration staggerStep = Duration(milliseconds: 50);

  /// 第 [index] 个列表项的入场延迟（用于交错动画 stagger）。
  static Duration staggerDelay(int index) => staggerStep * index;
}
