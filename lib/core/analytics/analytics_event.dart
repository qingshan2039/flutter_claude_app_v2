import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';

/// 结构化埋点事件（T27.4：事件 API + 参数规范）。
///
/// **命名规范**：
/// - 事件名用 `snake_case`、动词在前（`button_click`、`screen_view`、`add_to_cart`）。
/// - 参数键 `snake_case`；值用基本类型（String/num/bool）。
/// - 不上报 `null`（[sanitizedParams] 会过滤）。
///
/// 用 [AnalyticsX.track] 上报：`getIt<Analytics>().track(AnalyticsEvent.tap('buy'))`。
@immutable
class AnalyticsEvent {
  AnalyticsEvent(this.name, {Map<String, Object?>? params})
    : assert(name.isNotEmpty, '事件名不能为空'),
      params = Map<String, Object?>.unmodifiable(params ?? const {});

  /// 点击事件便捷构造。
  factory AnalyticsEvent.tap(String target, {Map<String, Object?>? extra}) =>
      AnalyticsEvent('button_click', params: {'target': target, ...?extra});

  /// 内容曝光事件便捷构造。
  factory AnalyticsEvent.exposure(String element, {Map<String, Object?>? extra}) =>
      AnalyticsEvent('element_exposure', params: {'element': element, ...?extra});

  final String name;
  final Map<String, Object?> params;

  /// 过滤掉 null 值的参数（上报规范：不发 null）。
  Map<String, Object> sanitizedParams() => <String, Object>{
    for (final entry in params.entries)
      if (entry.value != null) entry.key: entry.value!,
  };

  @override
  String toString() => 'AnalyticsEvent($name, ${sanitizedParams()})';
}

/// 在 [Analytics] 上以结构化事件上报（T27.4）。
extension AnalyticsX on Analytics {
  Future<void> track(AnalyticsEvent event) =>
      logEvent(event.name, params: event.sanitizedParams());
}
