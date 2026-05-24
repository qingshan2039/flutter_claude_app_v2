import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics_route_observer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/recording_analytics.dart';

MaterialPageRoute<void> _route(String name) => MaterialPageRoute<void>(
  builder: (_) => const SizedBox(),
  settings: RouteSettings(name: name),
);

void main() {
  group('AnalyticsRouteObserver (T27.2)', () {
    late RecordingAnalytics analytics;
    late AnalyticsRouteObserver observer;

    setUp(() {
      analytics = RecordingAnalytics();
      observer = AnalyticsRouteObserver(analytics);
    });

    test('didPush 上报 screen_view', () {
      observer.didPush(_route('/home'), null);
      expect(analytics.screens, <String>['/home']);
    });

    test('didReplace 上报新页面', () {
      observer.didReplace(newRoute: _route('/detail'), oldRoute: _route('/home'));
      expect(analytics.screens, <String>['/detail']);
    });

    test('didPop 上报返回后的上一页', () {
      observer.didPop(_route('/detail'), _route('/home'));
      expect(analytics.screens, <String>['/home']);
    });

    test('无名路由不上报', () {
      observer.didPush(_route(''), null);
      expect(analytics.screens, isEmpty);
    });
  });
}
