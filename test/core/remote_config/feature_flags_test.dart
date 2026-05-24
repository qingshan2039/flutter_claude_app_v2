import 'package:flutter_claude_app_v2/core/remote_config/feature_flags.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/fake_remote_config.dart';

void main() {
  group('RolloutEvaluator (T28.2)', () {
    test('bucketOf 稳定且落在 0–99', () {
      final b1 = RolloutEvaluator.bucketOf('user_1', 'flag_a');
      final b2 = RolloutEvaluator.bucketOf('user_1', 'flag_a');
      expect(b1, b2); // 稳定
      expect(b1, inInclusiveRange(0, 99));
    });

    test('percent 边界：0 全否、100 全是', () {
      for (final u in <String>['a', 'b', 'c']) {
        expect(
          RolloutEvaluator.isInRollout(userId: u, flag: 'f', percent: 0),
          isFalse,
        );
        expect(
          RolloutEvaluator.isInRollout(userId: u, flag: 'f', percent: 100),
          isTrue,
        );
      }
    });

    test('30% 灰度：大样本命中率接近 30%', () {
      var hit = 0;
      for (var i = 0; i < 2000; i++) {
        if (RolloutEvaluator.isInRollout(
          userId: 'user_$i',
          flag: 'home_banner',
          percent: 30,
        )) {
          hit++;
        }
      }
      final rate = hit / 2000;
      expect(rate, closeTo(0.30, 0.05)); // 25%–35%
    });
  });

  group('FeatureFlags (T28.2)', () {
    test('isEnabled 读取布尔开关', () {
      final flags = FeatureFlags(
        FakeRemoteConfig(const {'new_ui': true}),
      );
      expect(flags.isEnabled('new_ui'), isTrue);
      expect(flags.isEnabled('missing', defaultValue: true), isTrue);
    });

    test('isEnabledForUser 读 <flag>.rollout 灰度', () {
      final allIn = FeatureFlags(
        FakeRemoteConfig(const {'home_banner.rollout': 100}),
      );
      final noneIn = FeatureFlags(
        FakeRemoteConfig(const {'home_banner.rollout': 0}),
      );
      expect(allIn.isEnabledForUser('home_banner', 'u1'), isTrue);
      expect(noneIn.isEnabledForUser('home_banner', 'u1'), isFalse);
    });
  });
}
