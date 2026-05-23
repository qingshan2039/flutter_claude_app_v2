import 'package:flutter/widgets.dart';

/// 安全区域工具（T12.6）。
///
/// 统一异形屏（刘海 / 挖孔）、Home Indicator、状态栏的避让规范。
/// 业务用 [AppSafeArea] 包裹页面内容，或用静态方法读各方向 inset。
abstract final class SafeAreaUtils {
  /// 系统 UI 占用的物理 padding（刘海/状态栏/Home Indicator），不含键盘。
  static EdgeInsets viewPadding(BuildContext context) =>
      MediaQuery.viewPaddingOf(context);

  /// 顶部 inset（状态栏 + 刘海高度）。
  static double topInset(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top;

  /// 底部 inset（Home Indicator 高度；无则 0）。
  static double bottomInset(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).bottom;

  /// 是否存在底部 Home Indicator（用于决定是否额外留白）。
  static bool hasBottomIndicator(BuildContext context) => bottomInset(context) > 0;
}

/// 项目统一的 SafeArea 封装（T12.6）。
///
/// 与原生 [SafeArea] 的区别：
/// - 默认上下避让、左右不避让（多数页面横向已贴边）
/// - [minimum] 提供最小内边距（即使无系统 inset 也保证留白）
/// - 命名更语义化，便于全项目统一规范
class AppSafeArea extends StatelessWidget {
  const AppSafeArea({
    required this.child, super.key,
    this.top = true,
    this.bottom = true,
    this.left = false,
    this.right = false,
    this.minimum = EdgeInsets.zero,
  });

  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets minimum;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum,
      child: child,
    );
  }
}
