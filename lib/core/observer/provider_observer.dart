import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

/// 应用全局 Riverpod [ProviderObserver]（T06.3）。
///
/// 监听四个生命周期事件，把状态变更日志输出到 [debugPrint]。M11/T11.4 完成后，
/// 替换 [_log] 为 `getIt<AppLogger>().d(...)` 或 Sentry breadcrumb。
///
/// 接入位置（main.dart）：
/// ```dart
/// runApp(ProviderScope(
///   observers: [AppProviderObserver()],
///   child: const MyApp(),
/// ));
/// ```
///
/// 单测中也可手工注入 ProviderContainer：
/// ```dart
/// final container = ProviderContainer(observers: [AppProviderObserver()]);
/// ```
@lazySingleton
class AppProviderObserver extends ProviderObserver {
  AppProviderObserver();

  /// 默认仅 debug 输出；生产 build 零开销（[debugPrint] 在 release 是 no-op，
  /// 但 [enabled] 提前 short-circuit 避免 toString 开销）。
  /// 公开字段而非构造参数：避免 injectable 试图从 DI 容器解析 `bool`。
  /// 测试可直接 `observer.enabled = false` 切换。
  bool enabled = kDebugMode;

  void _log(String line) {
    if (enabled) {
      debugPrint(line);
    }
  }

  String _providerName(ProviderBase<Object?> provider) =>
      provider.name ?? provider.runtimeType.toString();

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    _log('[provider+] ${_providerName(provider)} = $value');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _log('[provider~] ${_providerName(provider)}: $previousValue → $newValue');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    _log('[provider-] ${_providerName(provider)}');
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _log('[provider!] ${_providerName(provider)} failed: $error');
  }
}
