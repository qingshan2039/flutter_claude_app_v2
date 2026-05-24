import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:injectable/injectable.dart';

/// 默认埋点实现（T27.1）：把事件打到 [AppLogger]（info 级）。
///
/// dev/调试可见埋点流；生产请改绑真实后端（GA/友盟/神策）或用
/// [CompositeAnalytics] 组合多后端（DI 中替换 `Analytics` 的绑定）。
@LazySingleton(as: Analytics)
class LoggingAnalytics implements Analytics {
  const LoggingAnalytics(this._logger);

  final AppLogger _logger;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    _logger.i('[analytics] event=$name params=${params ?? const {}}');
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, Object?>? params,
  }) async {
    _logger.i('[analytics] screen_view=$screenName params=${params ?? const {}}');
  }

  @override
  Future<void> setUserId(String? id) async {
    _logger.i('[analytics] setUserId=$id');
  }

  @override
  Future<void> setUserProperty(String name, Object? value) async {
    _logger.i('[analytics] userProperty $name=$value');
  }
}
