import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';

/// 性能监控工具（T11.5）。
///
/// 用于度量页面加载时间、接口耗时等。结果记录到 [AppLogger]（info 级），
/// M27 数据埋点完成后可同时上报到 analytics / Sentry performance。
///
/// 用法：
/// ```dart
/// final perf = getIt<PerformanceMonitor>();
///
/// // 手动起止
/// perf.start('home_load');
/// ...
/// perf.stop('home_load');   // 记录 "[perf] home_load took 123ms"
///
/// // 包裹异步（接口耗时）
/// final users = await perf.traceAsync('GET /users', () => api.getUsers());
///
/// // 包裹同步
/// final parsed = perf.traceSync('parse_json', () => decode(raw));
/// ```
abstract class PerformanceMonitor {
  void start(String name);

  /// 停止并返回耗时；若 [name] 未 start 过返回 null。
  Duration? stop(String name);

  Future<T> traceAsync<T>(String name, Future<T> Function() action);

  T traceSync<T>(String name, T Function() action);
}

@LazySingleton(as: PerformanceMonitor)
class PerformanceMonitorImpl implements PerformanceMonitor {
  PerformanceMonitorImpl(this._logger);

  final AppLogger _logger;
  final Map<String, Stopwatch> _active = <String, Stopwatch>{};

  @override
  void start(String name) {
    _active[name] = Stopwatch()..start();
  }

  @override
  Duration? stop(String name) {
    final sw = _active.remove(name);
    if (sw == null) {
      _logger.w('[perf] stop("$name") called without matching start()');
      return null;
    }
    sw.stop();
    _logger.i('[perf] $name took ${sw.elapsedMilliseconds}ms');
    return sw.elapsed;
  }

  @override
  Future<T> traceAsync<T>(String name, Future<T> Function() action) async {
    start(name);
    try {
      return await action();
    } finally {
      stop(name);
    }
  }

  @override
  T traceSync<T>(String name, T Function() action) {
    start(name);
    try {
      return action();
    } finally {
      stop(name);
    }
  }
}
