import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/router_log_observer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouterLogObserver', () {
    test('未启用时 recordSink 不被填充', () {
      final observer = RouterLogObserver()..enabled = false;
      final sink = <String>[];
      observer.recordSink = sink;

      observer.didPush(
        MaterialPageRoute<void>(builder: (_) => const Placeholder()),
        null,
      );

      expect(sink, isEmpty);
    });

    test('启用时 didPush 写入一条 push 日志', () {
      final observer = RouterLogObserver()..enabled = true;
      final sink = <String>[];
      observer.recordSink = sink;

      observer.didPush(
        MaterialPageRoute<void>(
          builder: (_) => const Placeholder(),
          settings: const RouteSettings(name: '/home'),
        ),
        null,
      );

      expect(sink.length, 1);
      expect(sink.single, contains('push /home'));
      expect(sink.single, contains('from <null>'));
    });

    test('didPop 写入 pop 日志（含目的地）', () {
      final observer = RouterLogObserver()..enabled = true;
      final sink = <String>[];
      observer.recordSink = sink;

      final from = MaterialPageRoute<void>(
        builder: (_) => const Placeholder(),
        settings: const RouteSettings(name: '/detail/42'),
      );
      final to = MaterialPageRoute<void>(
        builder: (_) => const Placeholder(),
        settings: const RouteSettings(name: '/home'),
      );

      observer.didPop(from, to);

      expect(sink.single, contains('pop'));
      expect(sink.single, contains('/detail/42'));
      expect(sink.single, contains('to /home'));
    });

    test('didReplace 写入 replace 日志', () {
      final observer = RouterLogObserver()..enabled = true;
      final sink = <String>[];
      observer.recordSink = sink;

      observer.didReplace(
        oldRoute: MaterialPageRoute<void>(
          builder: (_) => const Placeholder(),
          settings: const RouteSettings(name: '/login'),
        ),
        newRoute: MaterialPageRoute<void>(
          builder: (_) => const Placeholder(),
          settings: const RouteSettings(name: '/home'),
        ),
      );

      expect(sink.single, contains('replace /login → /home'));
    });

    test('无 name 的 route 用 runtimeType 兜底', () {
      final observer = RouterLogObserver()..enabled = true;
      final sink = <String>[];
      observer.recordSink = sink;

      observer.didPush(
        MaterialPageRoute<void>(builder: (_) => const Placeholder()),
        null,
      );

      expect(sink.single, contains('MaterialPageRoute'));
    });
  });
}
