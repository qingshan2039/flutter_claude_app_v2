import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';

/// 网络图片组件（T14.3）。
///
/// 封装 [CachedNetworkImage]：内存+磁盘缓存、占位图、错误图、圆角。
///
/// ```dart
/// AppImage(url, width: 80, height: 80, borderRadius: RadiusTokens.allMd);
/// AppImage.circle(url, size: 48);            // 圆形头像
/// ```
class AppImage extends StatelessWidget {
  const AppImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.placeholder,
    this.errorWidget,
  });

  /// 圆形（头像）便捷构造。
  AppImage.circle(this.url, {super.key, double size = 48, this.placeholder})
    : width = size,
      height = size,
      fit = BoxFit.cover,
      borderRadius = BorderRadius.circular(size / 2),
      errorWidget = null;

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  /// 自定义占位（加载中）。默认是中性灰底块。
  final Widget? placeholder;

  /// 自定义错误图。默认是 broken_image 图标。
  final Widget? errorWidget;

  Widget _defaultPlaceholder(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
  );

  Widget _defaultError(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(
      Icons.broken_image_outlined,
      color: Theme.of(context).colorScheme.outline,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) =>
          placeholder ?? _defaultPlaceholder(context),
      errorWidget: (context, _, _) => errorWidget ?? _defaultError(context),
    );

    if (borderRadius == BorderRadius.zero) return image;
    return ClipRRect(borderRadius: borderRadius, child: image);
  }
}

/// 圆角裁剪扩展（T14.3）：任意 Widget 一键加圆角。
///
/// ```dart
/// someWidget.rounded();                 // 默认 md 圆角
/// someWidget.rounded(RadiusTokens.allLg);
/// ```
extension RoundedClipX on Widget {
  Widget rounded([BorderRadius borderRadius = RadiusTokens.allMd]) =>
      ClipRRect(borderRadius: borderRadius, child: this);
}
