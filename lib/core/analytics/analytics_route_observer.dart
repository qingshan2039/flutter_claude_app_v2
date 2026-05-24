import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';
import 'package:injectable/injectable.dart';

/// 自动页面埋点观察者（T27.2）。
///
/// 装到 `GoRouter.observers`（或任意 Navigator 的 observers）后，页面进入/返回时
/// 自动上报 `screen_view`。页面名取 `route.settings.name`（go_router 会带上路径/名称）。
///
/// 接入：`createAppRouter(..., extraObservers: [getIt<AnalyticsRouteObserver>()])`。
@lazySingleton
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final Analytics _analytics;

  void _report(Route<dynamic>? route) {
    if (route is! PageRoute) return; // 只报页面级路由，忽略弹窗等
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(_analytics.logScreenView(name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _report(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _report(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // 返回后，重新可见的是上一个页面。
    _report(previousRoute);
  }
}
