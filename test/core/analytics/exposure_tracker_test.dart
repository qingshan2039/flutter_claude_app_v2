import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/analytics/exposure_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../_helpers/recording_analytics.dart';

void main() {
  setUp(() {
    // 让可见性回调即时触发（默认有 500ms 节流）。
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('ExposureTracker (T27.3)', () {
    testWidgets('元素可见时上报一次曝光事件', (tester) async {
      final analytics = RecordingAnalytics();
      var exposedCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExposureTracker(
              exposureName: 'home_banner',
              analytics: analytics,
              onExposed: () => exposedCalls++,
              child: const SizedBox(width: 200, height: 200),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(analytics.events, contains('element_exposure'));
      expect(analytics.eventParams.last?['element'], 'home_banner');
      expect(exposedCalls, 1);
    });

    testWidgets('视口外（被裁剪）的元素不上报', (tester) async {
      final analytics = RecordingAnalytics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // 滚动视口会裁剪：高空白把曝光元素推到视口下方不可见处。
            body: ListView(
              children: <Widget>[
                const SizedBox(height: 2000),
                ExposureTracker(
                  exposureName: 'offscreen',
                  analytics: analytics,
                  child: const SizedBox(width: 100, height: 100),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(analytics.events, isEmpty);
    });
  });
}
