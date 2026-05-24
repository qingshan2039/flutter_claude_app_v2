import 'package:flutter_claude_app_v2/core/experiment/experiment.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment_rollback.dart';
import 'package:flutter_claude_app_v2/core/experiment/experiment_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';
import '../../_helpers/recording_analytics.dart';

Experiment _ab() => Experiment(
  key: 'button_color',
  variants: const <Variant>[
    Variant('control', weight: 50),
    Variant('blue', weight: 25),
    Variant('green', weight: 25),
  ],
);

void main() {
  late RecordingAnalytics analytics;
  late ExperimentRollback rollback;
  late ExperimentService service;

  setUp(() {
    analytics = RecordingAnalytics();
    rollback = ExperimentRollback(InMemoryKeyValueStorage());
    service = ExperimentService(analytics, rollback)..register(_ab());
  });

  group('ExperimentService.assignFor 权重分配 (T31.2)', () {
    test('单一用户稳定分配同一变体', () {
      final a1 = ExperimentService.assignFor(_ab(), 'user_1');
      final a2 = ExperimentService.assignFor(_ab(), 'user_1');
      expect(a1.variantKey, a2.variantKey);
    });

    test('100% 单变体始终命中', () {
      final exp = Experiment(
        key: 'x',
        variants: const <Variant>[Variant('only', weight: 100)],
      );
      for (final u in <String>['a', 'b', 'c']) {
        expect(ExperimentService.assignFor(exp, u).variantKey, 'only');
      }
    });

    test('50% control 大样本约一半命中 control', () {
      var control = 0;
      for (var i = 0; i < 3000; i++) {
        if (ExperimentService.assignFor(_ab(), 'user_$i').variantKey == 'control') {
          control++;
        }
      }
      expect(control / 3000, closeTo(0.50, 0.06));
    });
  });

  group('ExperimentService.resolve 禁用/回滚 (T31.2/T31.3)', () {
    test('未注册实验 → null', () {
      expect(service.resolve('missing', 'u'), isNull);
    });

    test('禁用实验 → 强制对照组', () {
      service.register(
        Experiment(
          key: 'off',
          enabled: false,
          variants: const <Variant>[Variant('control'), Variant('v1')],
        ),
      );
      final a = service.resolve('off', 'u')!;
      expect(a.variantKey, 'control');
      expect(a.forcedControl, isTrue);
    });

    test('已回滚 → 强制对照组', () async {
      await rollback.rollback('button_color');
      final a = service.resolve('button_color', 'u')!;
      expect(a.variantKey, 'control');
      expect(a.forcedControl, isTrue);
    });

    test('正常 → 真实变体（非强制控制）', () {
      final a = service.resolve('button_color', 'user_1')!;
      expect(a.forcedControl, isFalse);
      expect(<String>['control', 'blue', 'green'], contains(a.variantKey));
    });
  });

  group('ExperimentService.activate 曝光上报 (T31.2)', () {
    test('activate 上报 experiment_exposure', () async {
      final a = await service.activate('button_color', 'user_1');
      expect(a, isNotNull);
      expect(analytics.events, contains('experiment_exposure'));
      final params = analytics.eventParams.single!;
      expect(params['experiment'], 'button_color');
      expect(params['variant'], a!.variantKey);
    });
  });
}
