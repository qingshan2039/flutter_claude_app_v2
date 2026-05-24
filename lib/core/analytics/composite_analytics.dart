import 'dart:async';

import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';

/// 组合多个埋点后端（T27.1：可切换/可叠加 GA / 友盟 / 神策）。
///
/// 同一事件并行分发给所有 [backends]；某个后端失败不影响其它。
///
/// ```dart
/// final analytics = CompositeAnalytics([
///   GaAnalytics(), UmengAnalytics(), SensorsAnalytics(),
/// ]);
/// ```
class CompositeAnalytics implements Analytics {
  const CompositeAnalytics(this.backends);

  final List<Analytics> backends;

  Future<void> _fanOut(Future<void> Function(Analytics a) action) async {
    await Future.wait(
      backends.map((a) async {
        try {
          await action(a);
        } catch (_) {
          // 单个后端失败不影响其它后端。
        }
      }),
    );
  }

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) =>
      _fanOut((a) => a.logEvent(name, params: params));

  @override
  Future<void> logScreenView(String screenName, {Map<String, Object?>? params}) =>
      _fanOut((a) => a.logScreenView(screenName, params: params));

  @override
  Future<void> setUserId(String? id) => _fanOut((a) => a.setUserId(id));

  @override
  Future<void> setUserProperty(String name, Object? value) =>
      _fanOut((a) => a.setUserProperty(name, value));
}
