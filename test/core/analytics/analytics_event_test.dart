import 'package:flutter_claude_app_v2/core/analytics/analytics_event.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/recording_analytics.dart';

void main() {
  group('AnalyticsEvent (T27.4)', () {
    test('保存事件名与参数', () {
      final e =
          AnalyticsEvent('add_to_cart', params: const {'id': 1, 'qty': 2});
      expect(e.name, 'add_to_cart');
      expect(e.params['id'], 1);
    });

    test('sanitizedParams 过滤 null 值', () {
      final e = AnalyticsEvent(
        'view',
        params: const {'a': 1, 'b': null, 'c': 'x'},
      );
      expect(e.sanitizedParams(), <String, Object>{'a': 1, 'c': 'x'});
    });

    test('空事件名触发断言', () {
      expect(() => AnalyticsEvent(''), throwsA(isA<AssertionError>()));
    });

    test('便捷构造 tap / exposure', () {
      expect(AnalyticsEvent.tap('buy').name, 'button_click');
      expect(AnalyticsEvent.tap('buy').params['target'], 'buy');
      expect(AnalyticsEvent.exposure('banner').name, 'element_exposure');
      expect(AnalyticsEvent.exposure('banner').params['element'], 'banner');
    });

    test('params 不可变', () {
      final e = AnalyticsEvent('x', params: const {'a': 1});
      expect(() => e.params['b'] = 2, throwsUnsupportedError);
    });
  });

  group('AnalyticsX.track (T27.4)', () {
    test('track 用 sanitizedParams 调 logEvent', () async {
      final analytics = RecordingAnalytics();
      await analytics.track(
        AnalyticsEvent('order', params: const {'amount': 9.9, 'coupon': null}),
      );
      expect(analytics.events, <String>['order']);
      expect(analytics.eventParams.single, <String, Object>{'amount': 9.9});
    });
  });
}
