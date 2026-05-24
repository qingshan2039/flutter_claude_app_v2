import 'package:flutter/material.dart';

/// 通用 Hero 封装（T34.3）。
///
/// 在来源页与目标页用**相同 [tag]** 包裹同一逻辑元素（如缩略图 → 大图），即可
/// 获得共享元素转场。本封装在原生 [Hero] 上统一：
/// - [enabled] 为 false 时退化为普通 [child]（便于按平台 / 可达性需求关闭动画）；
/// - 透传可选 [flightShuttleBuilder]，默认用 Flutter 内置 shuttle（对图片/容器稳定）。
///
/// ```dart
/// // 列表页
/// AppHero(tag: 'avatar-$id', child: Image.network(url));
/// // 详情页
/// AppHero(tag: 'avatar-$id', child: Image.network(url, width: 240));
/// ```
class AppHero extends StatelessWidget {
  const AppHero({
    required this.tag,
    required this.child,
    super.key,
    this.enabled = true,
    this.flightShuttleBuilder,
  });

  /// 共享元素标识：来源 / 目标页必须一致且唯一。
  final Object tag;
  final Widget child;

  /// false 时不参与 Hero 动画，直接渲染 [child]。
  final bool enabled;

  /// 自定义飞行内容构建器（高级用法）；为空时用框架默认。
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Hero(
      tag: tag,
      flightShuttleBuilder: flightShuttleBuilder,
      child: child,
    );
  }
}
