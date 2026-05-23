import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:flutter_claude_app_v2/core/logger/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

/// 记录日志调用的假 AppLogger。
class _RecordingLogger implements AppLogger {
  final List<String> infos = <String>[];
  final List<String> warnings = <String>[];

  @override
  void i(String message, {Object? error, StackTrace? stackTrace}) =>
      infos.add(message);
  @override
  void w(String message, {Object? error, StackTrace? stackTrace}) =>
      warnings.add(message);
  @override
  void t(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void d(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void e(String message, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  late _RecordingLogger logger;
  late PerformanceMonitor perf;

  setUp(() {
    logger = _RecordingLogger();
    perf = PerformanceMonitorImpl(logger);
  });

  group('start / stop', () {
    test('stop 返回非负耗时并记录 info', () {
      perf.start('task');
      final d = perf.stop('task');
      expect(d, isNotNull);
      expect(d!.inMicroseconds, greaterThanOrEqualTo(0));
      expect(logger.infos.single, contains('task'));
      expect(logger.infos.single, contains('[perf]'));
    });

    test('stop 未 start 过 → null + warning', () {
      final d = perf.stop('never-started');
      expect(d, isNull);
      expect(logger.warnings.single, contains('never-started'));
    });
  });

  group('traceAsync', () {
    test('返回 action 结果并记录耗时', () async {
      final result = await perf.traceAsync('load', () async {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        return 42;
      });
      expect(result, 42);
      expect(logger.infos.single, contains('load'));
    });

    test('action 抛异常时仍记录耗时并向上抛', () async {
      await expectLater(
        perf.traceAsync<void>('fail', () async => throw Exception('boom')),
        throwsA(isA<Exception>()),
      );
      // finally 中 stop 仍执行 → 记录了一条 info
      expect(logger.infos.single, contains('fail'));
    });
  });

  group('traceSync', () {
    test('返回 action 结果并记录耗时', () {
      final result = perf.traceSync('compute', () => 1 + 1);
      expect(result, 2);
      expect(logger.infos.single, contains('compute'));
    });

    test('action 抛异常时仍记录耗时并向上抛', () {
      expect(
        () => perf.traceSync<void>('boom', () => throw StateError('x')),
        throwsStateError,
      );
      expect(logger.infos.single, contains('boom'));
    });
  });
}
