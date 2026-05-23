import 'dart:ui' show DisplayFeature, DisplayFeatureType;

import 'package:flutter/widgets.dart';

/// 折叠屏支持（T12.5）。
///
/// 折叠屏 / 双屏设备通过 [MediaQueryData.displayFeatures] 暴露铰链（hinge）/
/// 折痕（fold）信息。本工具检测铰链并提供「避让铰链」的双栏布局。
abstract final class FoldableUtils {
  /// 返回第一个铰链 / 折痕 DisplayFeature；无则 null。
  static DisplayFeature? hinge(MediaQueryData mediaQuery) {
    for (final feature in mediaQuery.displayFeatures) {
      if (feature.type == DisplayFeatureType.hinge ||
          feature.type == DisplayFeatureType.fold) {
        return feature;
      }
    }
    return null;
  }

  /// 是否处于折叠 / 双屏形态（存在铰链且把屏幕一分为二）。
  static bool isFoldable(MediaQueryData mediaQuery) =>
      hinge(mediaQuery) != null;

  /// 铰链是否垂直（左右分屏）。垂直铰链 → 适合左右双栏。
  static bool isVerticalHinge(DisplayFeature hinge) =>
      hinge.bounds.height >= hinge.bounds.width;
}

/// 铰链感知的左右双栏（T12.5）。
///
/// - 无铰链：普通 [Row]，[start] 与 [end] 各占一半（[startFlex]:[endFlex]）
/// - 有垂直铰链：[start] 占铰链左侧，[end] 占铰链右侧，中间留出铰链宽度避让
class HingeAwareTwoPane extends StatelessWidget {
  const HingeAwareTwoPane({
    required this.start, required this.end, super.key,
    this.startFlex = 1,
    this.endFlex = 1,
  });

  final Widget start;
  final Widget end;
  final int startFlex;
  final int endFlex;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hinge = FoldableUtils.hinge(mq);

    if (hinge == null || !FoldableUtils.isVerticalHinge(hinge)) {
      return Row(
        children: <Widget>[
          Expanded(flex: startFlex, child: start),
          Expanded(flex: endFlex, child: end),
        ],
      );
    }

    // 垂直铰链：按铰链 bounds 切分，留出铰链宽度
    final hingeBounds = hinge.bounds;
    return Row(
      children: <Widget>[
        SizedBox(width: hingeBounds.left, child: start),
        SizedBox(width: hingeBounds.width),
        Expanded(child: end),
      ],
    );
  }
}
