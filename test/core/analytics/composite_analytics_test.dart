import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';
import 'package:flutter_claude_app_v2/core/analytics/composite_analytics.dart';
import 'package:flutter_claude_app_v2/core/analytics/noop_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/recording_analytics.dart';

class _ThrowingAnalytics implements Analytics {
  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async =>
      throw Exception('backend down');
  @override
  Future<void> logScreenView(String s, {Map<String, Object?>? params}) async =>
      throw Exception('backend down');
  @override
  Future<void> setUserId(String? id) async => throw Exception('x');
  @override
  Future<void> setUserProperty(String name, Object? value) async =>
      throw Exception('x');
}

void main() {
  group('NoopAnalytics (T27.1)', () {
    test('所有方法均无副作用、不抛', () async {
      const noop = NoopAnalytics();
      await noop.logEvent('x');
      await noop.logScreenView('y');
      await noop.setUserId('1');
      await noop.setUserProperty('k', 'v');
    });
  });

  group('CompositeAnalytics (T27.1)', () {
    test('事件分发到所有后端', () async {
      final a = RecordingAnalytics();
      final b = RecordingAnalytics();
      final composite = CompositeAnalytics([a, b]);

      await composite.logEvent('e', params: {'k': 1});
      await composite.logScreenView('s');

      expect(a.events, <String>['e']);
      expect(b.events, <String>['e']);
      expect(a.screens, <String>['s']);
      expect(b.screens, <String>['s']);
    });

    test('单个后端抛错不影响其它后端', () async {
      final good = RecordingAnalytics();
      final composite = CompositeAnalytics([_ThrowingAnalytics(), good]);

      await composite.logEvent('e');
      expect(good.events, <String>['e']);
    });
  });
}
