import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 嵌入原生视图（T26.4 PlatformView 示例）。
///
/// 按平台选择 [AndroidView] / [UiKitView] 渲染原生控件（地图、相机预览、富文本
/// 编辑器等）；非移动端回退到 [fallback]。
///
/// 原生侧需注册同名 viewType 的 PlatformViewFactory（Android
/// `registerViewFactory`，iOS `FlutterPlatformViewFactory`）。未注册时真机会显示
/// 平台报错，故 demo 默认按需加载。
class NativePlatformView extends StatelessWidget {
  const NativePlatformView({
    required this.viewType,
    super.key,
    this.fallback,
    this.creationParams,
  });

  /// 原生注册的视图类型标识。
  final String viewType;

  /// 不支持平台时的占位。
  final Widget? fallback;

  /// 传给原生的初始化参数。
  final Map<String, dynamic>? creationParams;

  /// 该平台是否支持 PlatformView（Android / iOS）。
  static bool isSupportedOn(TargetPlatform platform) =>
      platform == TargetPlatform.android || platform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    if (!isSupportedOn(defaultTargetPlatform)) {
      return fallback ?? const _UnsupportedNativeView();
    }
    const codec = StandardMessageCodec();
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        creationParams: creationParams,
        creationParamsCodec: codec,
      );
    }
    return UiKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: codec,
    );
  }
}

class _UnsupportedNativeView extends StatelessWidget {
  const _UnsupportedNativeView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Text(
          '当前平台不支持嵌入原生视图',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
