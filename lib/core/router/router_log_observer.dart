import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// 路由日志观察者（T07.8）。
///
/// 安装到 [GoRouter.observers] 后，每次 push / pop / replace / remove 都会触发
/// 一条日志输出。默认只在 debug 期开（[enabled]），M11/T11.4 完成后可把 [_log]
/// 替换为 AppLogger 或 Sentry breadcrumb。
@lazySingleton
class RouterLogObserver extends NavigatorObserver {
  RouterLogObserver();

  /// 公开字段以便测试覆盖（避免构造参数让 injectable 找不到 bool 注册）。
  bool enabled = kDebugMode;

  /// 测试用 hook：所有日志的副本进入此列表，便于断言。生产期保留为 null。
  @visibleForTesting
  List<String>? recordSink;

  void _log(String line) {
    if (!enabled) return;
    debugPrint('[Route] $line');
    recordSink?.add(line);
  }

  String _routeLabel(Route<dynamic>? route) {
    if (route == null) return '<null>';
    final name = route.settings.name;
    return name ?? route.runtimeType.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('push ${_routeLabel(route)}  (from ${_routeLabel(previousRoute)})');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('pop  ${_routeLabel(route)}  (to ${_routeLabel(previousRoute)})');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('replace ${_routeLabel(oldRoute)} → ${_routeLabel(newRoute)}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('remove ${_routeLabel(route)}');
  }
}
