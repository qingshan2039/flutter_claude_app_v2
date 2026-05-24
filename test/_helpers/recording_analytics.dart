import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';

/// 记录式 [Analytics] 测试替身：把每次调用存下来供断言。
class RecordingAnalytics implements Analytics {
  final List<String> events = <String>[];
  final List<Map<String, Object?>?> eventParams = <Map<String, Object?>?>[];
  final List<String> screens = <String>[];
  String? userId;
  final Map<String, Object?> userProperties = <String, Object?>{};

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    events.add(name);
    eventParams.add(params);
  }

  @override
  Future<void> logScreenView(
    String screenName, {
    Map<String, Object?>? params,
  }) async {
    screens.add(screenName);
  }

  @override
  Future<void> setUserId(String? id) async => userId = id;

  @override
  Future<void> setUserProperty(String name, Object? value) async =>
      userProperties[name] = value;
}
