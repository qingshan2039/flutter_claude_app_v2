import 'package:flutter_claude_app_v2/core/logger/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopCrashReporter', () {
    const reporter = NoopCrashReporter();

    test('recordError 不抛错', () async {
      await expectLater(
        reporter.recordError(Exception('x'), StackTrace.current),
        completes,
      );
    });

    test('recordError fatal 不抛错', () async {
      await expectLater(
        reporter.recordError(Exception('x'), null, fatal: true),
        completes,
      );
    });

    test('addBreadcrumb / setUser / setTag 均 no-op 完成', () async {
      await expectLater(
        reporter.addBreadcrumb('nav', category: 'ui', data: <String, dynamic>{'k': 'v'}),
        completes,
      );
      await expectLater(reporter.setUser('u1'), completes);
      await expectLater(reporter.setUser(null), completes);
      await expectLater(reporter.setTag('env', 'dev'), completes);
    });

    test('实现 CrashReporter 接口', () {
      expect(reporter, isA<CrashReporter>());
    });
  });

  group('CrashReporter 抽象用于测试替身', () {
    test('可被 fake 实现并记录调用', () async {
      final fake = _RecordingReporter();
      await fake.recordError(Exception('boom'), null);
      await fake.addBreadcrumb('crumb');
      await fake.setTag('a', 'b');

      expect(fake.errors.length, 1);
      expect(fake.breadcrumbs.single, 'crumb');
      expect(fake.tags['a'], 'b');
    });
  });
}

class _RecordingReporter implements CrashReporter {
  final List<Object> errors = <Object>[];
  final List<String> breadcrumbs = <String>[];
  final Map<String, String> tags = <String, String>{};
  String? user;

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace,
      {bool fatal = false}) async {
    errors.add(error);
  }

  @override
  Future<void> addBreadcrumb(String message,
      {String? category, Map<String, dynamic>? data}) async {
    breadcrumbs.add(message);
  }

  @override
  Future<void> setUser(String? id) async => user = id;

  @override
  Future<void> setTag(String key, String value) async => tags[key] = value;
}
