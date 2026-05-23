import 'package:flutter/widgets.dart';

/// 字体缩放策略（T12.3）。
///
/// 用户在系统设置里可把字体放到很大（无障碍），无限制会撑破布局。本工具把
/// [TextScaler] 钳制在 [minScale, maxScale] 之间：既尊重用户偏好，又保证布局不崩。
abstract final class FontScaling {
  static const double minScale = 0.8;
  static const double maxScale = 1.4;

  /// 钳制 [scaler] 到 [min, max]。纯函数，便于测试。
  static TextScaler clamp(
    TextScaler scaler, {
    double min = minScale,
    double max = maxScale,
  }) {
    return scaler.clamp(minScaleFactor: min, maxScaleFactor: max);
  }
}

/// 用钳制后的 [TextScaler] 包裹 [child] 的 MediaQuery（T12.3）。
///
/// 放在 MaterialApp 的 `builder` 中即可全局生效：
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ClampedTextScaling(child: child!),
/// );
/// ```
class ClampedTextScaling extends StatelessWidget {
  const ClampedTextScaling({
    super.key,
    required this.child,
    this.min = FontScaling.minScale,
    this.max = FontScaling.maxScale,
  });

  final Widget child;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: FontScaling.clamp(mq.textScaler, min: min, max: max),
      ),
      child: child,
    );
  }
}
