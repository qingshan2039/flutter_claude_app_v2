import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';

/// App 生命周期监听（T13.5）。
///
/// 通过 [WidgetsBindingObserver] 监听前后台切换与内存警告，转发到可选回调。
/// 在 [App] 的 initState 中 `WidgetsBinding.instance.addObserver(...)` 注册，
/// dispose 时移除。
///
/// 典型用途：
/// - onPaused：保存草稿、暂停视频、停止定位
/// - onResumed：刷新 token、恢复轮询、检查更新
/// - onMemoryPressure：清理图片缓存、释放大对象
class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver({
    this.onResumed,
    this.onInactive,
    this.onPaused,
    this.onDetached,
    this.onHidden,
    this.onMemoryPressure,
    AppLogger? logger,
  }) : _logger = logger;

  final VoidCallback? onResumed;
  final VoidCallback? onInactive;
  final VoidCallback? onPaused;
  final VoidCallback? onDetached;
  final VoidCallback? onHidden;
  final VoidCallback? onMemoryPressure;
  final AppLogger? _logger;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger?.d('[lifecycle] $state');
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed?.call();
      case AppLifecycleState.inactive:
        onInactive?.call();
      case AppLifecycleState.paused:
        onPaused?.call();
      case AppLifecycleState.detached:
        onDetached?.call();
      case AppLifecycleState.hidden:
        onHidden?.call();
    }
  }

  @override
  void didHaveMemoryPressure() {
    _logger?.w('[lifecycle] memory pressure — consider freeing caches');
    onMemoryPressure?.call();
  }
}
