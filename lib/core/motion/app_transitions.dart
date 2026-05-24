import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';

/// 页面转场类型（T34.2）。
enum AppTransitionType {
  /// 淡入淡出（轻量）。
  fade,

  /// 自下轻微上滑 + 淡入（内容页）。
  slideUp,

  /// 缩放 + 淡入（强调）。
  scale,

  /// 横向位移 + 淡入（同级页面切换，类 shared-axis）。
  sharedAxis,
}

/// 统一页面转场封装（T34.2）。
///
/// 面向命令式导航（`Navigator.push`），与 go_router 的 `PageTransitions`
/// （M07/T07.7）视觉语言一致；转场时长 / 曲线统一取自 [MotionTokens]，保证
/// 全应用动效节奏统一。
///
/// ```dart
/// Navigator.of(context).push(
///   AppTransitions.route(builder: (_) => const DetailPage(),
///       type: AppTransitionType.slideUp),
/// );
/// ```
abstract final class AppTransitions {
  /// 按 [type] 构建过渡 widget；可复用于自定义 [PageRoute] 或 `AnimatedSwitcher`。
  static Widget build(
    AppTransitionType type,
    Animation<double> animation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: MotionTokens.emphasized,
      reverseCurve: MotionTokens.emphasizedAccelerate,
    );
    return switch (type) {
      AppTransitionType.fade => FadeTransition(opacity: curved, child: child),
      AppTransitionType.slideUp => FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      ),
      AppTransitionType.scale => FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      ),
      AppTransitionType.sharedAxis => FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      ),
    };
  }

  /// 创建带统一转场的 [PageRoute]（命令式导航）。
  static Route<T> route<T>({
    required WidgetBuilder builder,
    AppTransitionType type = AppTransitionType.fade,
    Duration duration = MotionTokens.normal,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          build(type, animation, child),
    );
  }
}
