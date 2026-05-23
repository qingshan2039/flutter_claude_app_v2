import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/lifecycle/app_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLifecycleObserver 状态分发', () {
    test('resumed → onResumed', () {
      var called = false;
      final obs = AppLifecycleObserver(onResumed: () => called = true);
      obs.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(called, isTrue);
    });

    test('paused → onPaused', () {
      var called = false;
      final obs = AppLifecycleObserver(onPaused: () => called = true);
      obs.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(called, isTrue);
    });

    test('inactive → onInactive', () {
      var called = false;
      final obs = AppLifecycleObserver(onInactive: () => called = true);
      obs.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(called, isTrue);
    });

    test('detached → onDetached', () {
      var called = false;
      final obs = AppLifecycleObserver(onDetached: () => called = true);
      obs.didChangeAppLifecycleState(AppLifecycleState.detached);
      expect(called, isTrue);
    });

    test('hidden → onHidden', () {
      var called = false;
      final obs = AppLifecycleObserver(onHidden: () => called = true);
      obs.didChangeAppLifecycleState(AppLifecycleState.hidden);
      expect(called, isTrue);
    });

    test('未匹配的回调不互相触发', () {
      var resumed = false;
      var paused = false;
      final obs = AppLifecycleObserver(
        onResumed: () => resumed = true,
        onPaused: () => paused = true,
      );
      obs.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(resumed, isTrue);
      expect(paused, isFalse);
    });

    test('回调为 null 时不抛错', () {
      final obs = AppLifecycleObserver();
      expect(
        () => obs.didChangeAppLifecycleState(AppLifecycleState.resumed),
        returnsNormally,
      );
    });
  });

  group('内存警告', () {
    test('didHaveMemoryPressure → onMemoryPressure', () {
      var called = false;
      final obs = AppLifecycleObserver(onMemoryPressure: () => called = true);
      obs.didHaveMemoryPressure();
      expect(called, isTrue);
    });
  });
}
