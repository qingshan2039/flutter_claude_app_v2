import 'package:flutter/widgets.dart';

/// 屏幕类型（T12.1）。
enum ScreenType { mobile, tablet, desktop, largeDesktop }

/// 断点系统（T12.1）。
///
/// 阈值（宽度 dp）：
/// - mobile：< 600
/// - tablet：600 ~ 1024
/// - desktop：1024 ~ 1440
/// - largeDesktop：> 1440
abstract final class Breakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double desktopMax = 1440;

  /// 根据宽度判定屏幕类型。
  static ScreenType fromWidth(double width) {
    if (width < mobileMax) return ScreenType.mobile;
    if (width < tabletMax) return ScreenType.tablet;
    if (width < desktopMax) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }
}

/// `context.screenType` / `context.isMobile` 等便捷访问。
///
/// 注意：基于 `MediaQuery.sizeOf`（整窗口尺寸）。若需基于父容器约束判定，
/// 用 [ResponsiveBuilder]（内部走 LayoutBuilder）。
extension ResponsiveContext on BuildContext {
  ScreenType get screenType =>
      Breakpoints.fromWidth(MediaQuery.sizeOf(this).width);

  bool get isMobile => screenType == ScreenType.mobile;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop =>
      screenType == ScreenType.desktop ||
      screenType == ScreenType.largeDesktop;

  /// tablet 及以上（常用于「是否展示双栏 / NavigationRail」判断）。
  bool get isTabletOrLarger => screenType != ScreenType.mobile;
}
