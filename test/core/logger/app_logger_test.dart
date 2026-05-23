import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:flutter_claude_app_v2/core/logger/log_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  /// 用 MemoryOutput 捕获日志行，断言内容与级别过滤。
  ({AppLogger logger, MemoryOutput output}) build({required Level level}) {
    final output = MemoryOutput(bufferSize: 100);
    final logger = Logger(
      level: level,
      filter: ProductionFilter(), // 按 Logger.level 过滤
      printer: SimplePrinter(printTime: false, colors: false),
      output: output,
    );
    return (logger: LoggerImpl.withLogger(logger), output: output);
  }

  String allLines(MemoryOutput o) =>
      o.buffer.expand((e) => e.lines).join('\n');

  group('分级输出', () {
    test('level=trace 时 t/d/i/w/e 全部输出', () {
      final (:logger, :output) = build(level: Level.trace);
      logger
        ..t('trace-msg')
        ..d('debug-msg')
        ..i('info-msg')
        ..w('warn-msg')
        ..e('error-msg');

      final text = allLines(output);
      expect(text, contains('trace-msg'));
      expect(text, contains('debug-msg'));
      expect(text, contains('info-msg'));
      expect(text, contains('warn-msg'));
      expect(text, contains('error-msg'));
    });

    test('level=warning（prod 策略）时 t/d/i 被过滤', () {
      final (:logger, :output) = build(level: Level.warning);
      logger
        ..t('trace-msg')
        ..d('debug-msg')
        ..i('info-msg')
        ..w('warn-msg')
        ..e('error-msg');

      final text = allLines(output);
      expect(text, isNot(contains('trace-msg')));
      expect(text, isNot(contains('debug-msg')));
      expect(text, isNot(contains('info-msg')));
      expect(text, contains('warn-msg'));
      expect(text, contains('error-msg'));
    });
  });

  group('脱敏接入', () {
    test('消息中的 password 在输出前被脱敏', () {
      final (:logger, :output) = build(level: Level.trace);
      logger.i('login {"password":"p@ss"}');

      final text = allLines(output);
      expect(text, contains('***'));
      expect(text, isNot(contains('p@ss')));
    });

    test('自定义 sanitizer 生效', () {
      final out = MemoryOutput(bufferSize: 10);
      final raw = Logger(
        level: Level.trace,
        printer: SimplePrinter(printTime: false, colors: false),
        output: out,
      );
      final logger = LoggerImpl.withLogger(
        raw,
        sanitizer: LogSanitizer(
          extraRules: <RedactionRule>[
            RedactionRule(pattern: RegExp(r'topsecret'), replace: (_) => '###'),
          ],
        ),
      );
      logger.i('value=topsecret');
      final text = out.buffer.expand((e) => e.lines).join('\n');
      expect(text, contains('###'));
    });
  });

  group('error/stackTrace 透传', () {
    test('e() 携带 error 与 stackTrace 不抛错', () {
      final (:logger, :output) = build(level: Level.trace);
      expect(
        () => logger.e('boom',
            error: Exception('x'), stackTrace: StackTrace.current),
        returnsNormally,
      );
    });
  });
}
