import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';

/// 空实现（T27.1）：不上报任何数据。
///
/// 用途：用户未同意隐私（M24）前、关闭统计时、或单测默认替身。
class NoopAnalytics implements Analytics {
  const NoopAnalytics();

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {}

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, Object?>? params,
  }) async {}

  @override
  Future<void> setUserId(String? id) async {}

  @override
  Future<void> setUserProperty(String name, Object? value) async {}
}
