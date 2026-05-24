import 'package:flutter_claude_app_v2/core/experiment/bucketer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bucketer (T31.1)', () {
    test('bucketOf 稳定且落在 [0, buckets)', () {
      final b1 = Bucketer.bucketOf('user_1', salt: 'exp');
      final b2 = Bucketer.bucketOf('user_1', salt: 'exp');
      expect(b1, b2);
      expect(b1, inInclusiveRange(0, 99));
      expect(Bucketer.bucketOf('user_1', salt: 'exp', buckets: 4), inInclusiveRange(0, 3));
    });

    test('salt 独立：不同实验分桶相互独立', () {
      // 同一 unit、不同 salt 通常落不同桶（至少分桶是各自稳定的）。
      final a = Bucketer.bucketOf('u', salt: 'expA', buckets: 1000);
      final b = Bucketer.bucketOf('u', salt: 'expB', buckets: 1000);
      expect(a, isNot(equals(b)));
    });

    test('resolveUnitId：userId > deviceId > anonymous', () {
      expect(Bucketer.resolveUnitId(userId: 'u', deviceId: 'd'), 'u');
      expect(Bucketer.resolveUnitId(deviceId: 'd'), 'd');
      expect(Bucketer.resolveUnitId(userId: ''), 'anonymous');
      expect(Bucketer.resolveUnitId(), 'anonymous');
    });

    test('isInRollout：0 全否、100 全是、30% 大样本≈30%', () {
      expect(Bucketer.isInRollout('x', percent: 0), isFalse);
      expect(Bucketer.isInRollout('x', percent: 100), isTrue);
      var hit = 0;
      for (var i = 0; i < 3000; i++) {
        if (Bucketer.isInRollout('user_$i', percent: 30, salt: 'rollout')) hit++;
      }
      expect(hit / 3000, closeTo(0.30, 0.05));
    });

    test('大样本在桶内分布大致均匀（4 桶）', () {
      final counts = List<int>.filled(4, 0);
      for (var i = 0; i < 4000; i++) {
        counts[Bucketer.bucketOf('u_$i', salt: 's', buckets: 4)]++;
      }
      for (final c in counts) {
        expect(c, inInclusiveRange(800, 1200)); // 期望 1000
      }
    });
  });
}
