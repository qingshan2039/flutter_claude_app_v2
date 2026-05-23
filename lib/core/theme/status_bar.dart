import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 状态栏样式适配（T10.5）。
///
/// 状态栏图标颜色必须与背景亮度**相反**才看得清：
/// - 浅色背景（light theme）→ 深色图标（[Brightness.dark] icons）
/// - 深色背景（dark theme）→ 浅色图标（[Brightness.light] icons）
///
/// iOS 与 Android 的字段不同（iOS 用 statusBarBrightness，Android 用
/// statusBarIconBrightness），本工具两者都设，跨端一致。
abstract final class AppStatusBar {
  /// 根据**背景** brightness 计算应使用的 [SystemUiOverlayStyle]。
  ///
  /// [backgroundBrightness] 传当前主题的 brightness（Theme.of(context).brightness）。
  static SystemUiOverlayStyle styleFor(Brightness backgroundBrightness) {
    final isDarkBackground = backgroundBrightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Android：图标亮度（与背景相反）
      statusBarIconBrightness:
          isDarkBackground ? Brightness.light : Brightness.dark,
      // iOS：状态栏「亮度」语义是背景亮度
      statusBarBrightness: backgroundBrightness,
      // 底部导航栏（Android）
      systemNavigationBarColor: isDarkBackground
          ? const Color(0xFF000000)
          : const Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness:
          isDarkBackground ? Brightness.light : Brightness.dark,
    );
  }
}

/// 把 [child] 包在随主题自适应状态栏样式的 [AnnotatedRegion] 中（T10.5）。
///
/// 用法（页面根 / Scaffold 外层）：
/// ```dart
/// ThemedStatusBar(child: Scaffold(...));
/// ```
///
/// 自动读取 `Theme.of(context).brightness`，主题切换时状态栏图标颜色随之翻转。
class ThemedStatusBar extends StatelessWidget {
  const ThemedStatusBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppStatusBar.styleFor(brightness),
      child: child,
    );
  }
}
