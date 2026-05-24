import 'package:flutter/material.dart';

/// 最小点击区域封装（T22.3）。
///
/// 无障碍要求可交互元素的点击区域 ≥ 48×48 dp（Material / WCAG 2.5.5）。小图标、
/// 小文字按钮直接点很难命中，本组件在**不改变视觉尺寸**的前提下，把可点击/命中
/// 区域撑到至少 [minSize]，并补齐 `Semantics`（button 角色 + 无障碍标签）。
///
/// ```dart
/// // 一个 20px 的关闭图标，点击区域自动撑到 48×48
/// MinTapTarget(
///   onTap: () => Navigator.pop(context),
///   semanticLabel: '关闭',
///   child: const Icon(Icons.close, size: 20),
/// );
/// ```
///
/// 说明：Material 的按钮（IconButton/TextButton 等）已内置
/// `MaterialTapTargetSize.padded`（48 命中区），本组件用于**自定义可点元素**
/// （GestureDetector / 自绘 / 小图标）。
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({
    required this.child,
    super.key,
    this.onTap,
    this.minSize = kMinInteractiveDimension,
    this.semanticLabel,
    this.excludeChildSemantics = false,
  });

  /// 视觉内容（保持其自身尺寸，居中显示）。
  final Widget child;

  /// 点击回调；为 null 时仅保证尺寸、不响应点击、不标记 button 语义。
  final VoidCallback? onTap;

  /// 最小命中尺寸（dp），默认 [kMinInteractiveDimension] = 48。
  final double minSize;

  /// 无障碍标签（屏幕阅读器朗读）。图标类可点元素**务必**提供。
  final String? semanticLabel;

  /// 是否屏蔽子树语义（child 自身已无意义时设 true，避免重复朗读）。
  final bool excludeChildSemantics;

  @override
  Widget build(BuildContext context) {
    // Center(widthFactor/heightFactor: 1) 先收缩到 child 尺寸，再由 ConstrainedBox
    // 把最小尺寸撑到 minSize；child 视觉尺寸不变，命中区扩大。
    Widget result = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: child,
      ),
    );

    if (onTap != null) {
      result = GestureDetector(
        behavior: HitTestBehavior.opaque, // 整个 48×48（含透明区）都可点
        onTap: onTap,
        child: result,
      );
    }

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: excludeChildSemantics,
      child: result,
    );
  }
}
