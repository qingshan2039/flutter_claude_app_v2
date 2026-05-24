import 'package:flutter_claude_app_v2/core/logger/startup_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

/// T21.1：启动耗时埋点单测。用独立实例（非全局 instance）避免污染。
void main() {
  group('StartupTracker (T21.1)', () {
    test('begin → mark 多阶段：累计时间单调不减、delta 非负', () {
      final tracker = StartupTracker()..begin();

      final a = tracker.mark('binding');
      final b = tracker.mark('di');
      final c = tracker.mark('runApp');

      expect(tracker.phases, hasLength(3));
      expect(
        tracker.phases.map((p) => p.name),
        <String>['binding', 'di', 'runApp'],
      );
      // sinceStart 单调不减
      expect(a.sinceStart <= b.sinceStart, isTrue);
      expect(b.sinceStart <= c.sinceStart, isTrue);
      // delta 非负
      for (final p in tracker.phases) {
        expect(p.delta >= Duration.zero, isTrue);
      }
    });

    test('markFirstFrame：记录首帧 + 追加 firstFrame 阶段，重复只取首次', () {
      final tracker = StartupTracker()
        ..begin()
        ..mark('di')
        ..markFirstFrame();

      expect(tracker.firstFrameTime, isNotNull);
      expect(tracker.phases.last.name, 'firstFrame');
      final firstFrameLen = tracker.phases.length;

      tracker.markFirstFrame(); // 第二次应被忽略
      expect(tracker.phases.length, firstFrameLen);
    });

    test('summary：含各阶段名与首帧行', () {
      final tracker = StartupTracker()
        ..begin()
        ..mark('binding')
        ..mark('di')
        ..markFirstFrame();

      final summary = tracker.summary();
      expect(summary, contains('binding'));
      expect(summary, contains('di'));
      expect(summary, contains('first frame'));
    });

    test('未记录任何阶段时 summary 返回提示串', () {
      final tracker = StartupTracker();
      expect(tracker.summary(), contains('no phases recorded'));
      expect(tracker.phases, isEmpty);
      expect(tracker.firstFrameTime, isNull);
    });

    test('reset：清空阶段与首帧、停止计时', () {
      final tracker = StartupTracker()
        ..begin()
        ..mark('x')
        ..markFirstFrame()
        ..reset();

      expect(tracker.phases, isEmpty);
      expect(tracker.firstFrameTime, isNull);
      expect(tracker.isRunning, isFalse);
    });
  });
}
