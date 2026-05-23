import 'package:flutter/material.dart';

/// 阴影 / 高度 Token（T10.1）— 对齐 Material 3 的 elevation levels。
abstract final class ElevationTokens {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 8;
  static const double level5 = 12;

  /// 生成一组柔和的 [BoxShadow]，用于自定义容器（非 Material 组件）。
  ///
  /// Material 组件优先用其自身的 `elevation` 属性；本工具用于 Container 等手画阴影。
  static List<BoxShadow> shadow(
    double elevation, {
    Color color = const Color(0x1F000000),
  }) {
    if (elevation <= 0) return const <BoxShadow>[];
    return <BoxShadow>[
      BoxShadow(
        color: color,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }
}
