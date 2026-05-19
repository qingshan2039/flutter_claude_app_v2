import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/error/global_error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseIsolateMessage', () {
    test('合法 [error, stack] → 返回结构体', () {
      final parsed = parseIsolateMessage(['boom', '#0 main (file:///x.dart)']);
      expect(parsed, isNotNull);
      expect(parsed!.error, 'boom');
      expect(parsed.stackTrace, isA<StackTrace>());
    });

    test('null → null', () {
      expect(parseIsolateMessage(null), isNull);
    });

    test('非 List → null', () {
      expect(parseIsolateMessage('not-a-list'), isNull);
      expect(parseIsolateMessage(123), isNull);
    });

    test('长度不为 2 的 List → null', () {
      expect(parseIsolateMessage(<dynamic>[]), isNull);
      expect(parseIsolateMessage(['a']), isNull);
      expect(parseIsolateMessage(['a', 'b', 'c']), isNull);
    });

    test('error 为 null 时用 fallback', () {
      final parsed = parseIsolateMessage([null, '#0 main']);
      expect(parsed, isNotNull);
      expect(parsed!.error, 'Unknown isolate error');
    });

    test('stackString 为 null 时用空字符串', () {
      final parsed = parseIsolateMessage(['err', null]);
      expect(parsed, isNotNull);
      expect(parsed!.stackTrace, isA<StackTrace>());
    });
  });

  group('registerGlobalErrorHandlers', () {
    test('FlutterError.reportError 触发 reporter', () {
      Object? capturedError;
      StackTrace? capturedStack;

      final originalHandler = FlutterError.onError;
      try {
        registerGlobalErrorHandlers(reporter: (e, s) {
          capturedError = e;
          capturedStack = s;
        });

        // 直接调用安装好的 handler；模拟 framework 上抛
        FlutterError.onError!(
          FlutterErrorDetails(
            exception: Exception('widget-boom'),
            stack: StackTrace.current,
          ),
        );

        expect(capturedError, isA<Exception>());
        expect(capturedError.toString(), contains('widget-boom'));
        expect(capturedStack, isNotNull);
      } finally {
        FlutterError.onError = originalHandler;
      }
    });

    test('PlatformDispatcher.onError 触发 reporter 并返回 true', () {
      Object? capturedError;
      StackTrace? capturedStack;

      final originalHandler = PlatformDispatcher.instance.onError;
      try {
        registerGlobalErrorHandlers(reporter: (e, s) {
          capturedError = e;
          capturedStack = s;
        });

        final handled = PlatformDispatcher.instance.onError!(
          Exception('async-boom'),
          StackTrace.current,
        );

        expect(handled, isTrue);
        expect(capturedError.toString(), contains('async-boom'));
        expect(capturedStack, isNotNull);
      } finally {
        PlatformDispatcher.instance.onError = originalHandler;
      }
    });

    test('不传 reporter 时使用 _defaultReporter（不抛错）', () {
      final originalHandler = FlutterError.onError;
      try {
        registerGlobalErrorHandlers();
        expect(
          () => FlutterError.onError!(
            FlutterErrorDetails(
              exception: Exception('uses-default'),
              stack: StackTrace.current,
            ),
          ),
          returnsNormally,
        );
      } finally {
        FlutterError.onError = originalHandler;
      }
    });
  });

  group('runAppGuarded', () {
    test('zone 内的异步异常被 reporter 捕获', () async {
      Object? capturedError;
      final completer = Completer<void>();

      runAppGuarded(
        () {
          // 故意延迟，让异常在 zone 调度回来时才抛出
          Future<void>.delayed(const Duration(milliseconds: 1), () {
            throw Exception('zone-error');
          });
        },
        reporter: (e, s) {
          capturedError = e;
          if (!completer.isCompleted) completer.complete();
        },
      );

      await completer.future.timeout(const Duration(seconds: 2));
      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('zone-error'));
    });
  });
}
