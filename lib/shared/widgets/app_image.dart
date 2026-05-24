import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';

/// 网络图片组件（T14.3 + T21.4 图片性能）。
///
/// 封装 [CachedNetworkImage]：内存+磁盘缓存、占位图、错误图、圆角，并支持
/// **内存/磁盘缓存尺寸控制**（T21.4）——避免把一张大图按原始分辨率解码进内存。
///
/// 关键性能点（T21.4）：
/// - [cacheWidth] / [cacheHeight] 是**逻辑像素**；build 时按 `devicePixelRatio`
///   换算成 `memCacheWidth/Height`（即解码后驻留内存的位图尺寸）。列表缩略图务必
///   设置，否则一张 4000×3000 的图会按原图占用约 48MB 内存。
/// - [AppImage.thumbnail] 为「缩略图 / 原图分离」提供默认：按展示尺寸解码 +
///   限制磁盘缓存尺寸。
/// - [maxWidthDiskCache] / [maxHeightDiskCache] 控制磁盘缓存的原图尺寸（原始像素）。
///
/// ```dart
/// AppImage(url, width: 80, height: 80, borderRadius: RadiusTokens.allMd);
/// AppImage.circle(url, size: 48);              // 圆形头像（已限制解码尺寸）
/// AppImage.thumbnail(url, size: 96);           // 列表缩略图（小内存）
/// AppImage(url, cacheWidth: 360);              // 原图视图：按列宽解码
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
    this.cacheWidth,
    this.cacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  });

  /// 圆形（头像）便捷构造。默认按 [size] 限制解码尺寸（头像无需大位图）。
  AppImage.circle(this.url, {super.key, double size = 48, this.placeholder})
    : width = size,
      height = size,
      fit = BoxFit.cover,
      borderRadius = BorderRadius.circular(size / 2),
      errorWidget = null,
      cacheWidth = size.round(),
      cacheHeight = size.round(),
      maxWidthDiskCache = null,
      maxHeightDiskCache = null;

  /// 缩略图构造（T21.4「缩略图与原图分离」）：按展示 [size] 解码进内存，
  /// 并把磁盘缓存原图限制到 2×[size]，显著降低长列表的内存与磁盘占用。
  AppImage.thumbnail(
    this.url, {
    super.key,
    double size = 96,
    this.fit = BoxFit.cover,
    this.borderRadius = RadiusTokens.allSm,
    this.placeholder,
    this.errorWidget,
  }) : width = size,
       height = size,
       cacheWidth = size.round(),
       cacheHeight = size.round(),
       maxWidthDiskCache = (size * 2).round(),
       maxHeightDiskCache = (size * 2).round();

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  /// 解码进内存的目标**逻辑宽**（null = 不限制，按原图解码）。
  final int? cacheWidth;

  /// 解码进内存的目标**逻辑高**（null = 不限制）。
  final int? cacheHeight;

  /// 磁盘缓存原图的最大宽（原始像素，null = 不限制）。
  final int? maxWidthDiskCache;

  /// 磁盘缓存原图的最大高（原始像素，null = 不限制）。
  final int? maxHeightDiskCache;

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
    // 逻辑像素 → 物理像素（解码尺寸用物理像素更精确，避免高 DPR 屏发虚）。
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
    int? toPixels(int? logical) =>
        logical == null ? null : (logical * dpr).round();

    final image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: toPixels(cacheWidth),
      memCacheHeight: toPixels(cacheHeight),
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
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
