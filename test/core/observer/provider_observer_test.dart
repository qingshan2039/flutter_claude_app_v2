import 'package:flutter_claude_app_v2/core/observer/provider_observer.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/counter_state_notifier.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/greeting_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 记录 [AppProviderObserver] 所有事件的可观察 subclass。
class _RecordingObserver extends AppProviderObserver {
  final List<String> events = <String>[];

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    events.add('add:${provider.name ?? provider.runtimeType}=$value');
    super.didAddProvider(provider, value, container);
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    events.add(
      'update:${provider.name ?? provider.runtimeType}=$previousValue→$newValue',
    );
    super.didUpdateProvider(provider, previousValue, newValue, container);
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    events.add('dispose:${provider.name ?? provider.runtimeType}');
    super.didDisposeProvider(provider, container);
  }
}

void main() {
  test('add 事件：首次 read 触发 didAddProvider', () {
    final observer = _RecordingObserver()..enabled = false;
    final container = ProviderContainer(observers: <ProviderObserver>[observer]);
    addTearDown(container.dispose);

    container.read(greetingProvider);

    expect(
      observer.events.any((e) => e.startsWith('add:greetingProvider')),
      isTrue,
    );
  });

  test('update 事件：StateNotifier 状态变化触发 didUpdateProvider', () {
    final observer = _RecordingObserver()..enabled = false;
    final container = ProviderContainer(observers: <ProviderObserver>[observer]);
    addTearDown(container.dispose);

    container.read(counterStateNotifierProvider.notifier).increment();
    container.read(counterStateNotifierProvider.notifier).increment();

    final updates = observer.events
        .where((e) => e.startsWith('update:counterStateNotifierProvider'))
        .toList();
    expect(updates.length, greaterThanOrEqualTo(2));
    expect(updates.first, contains('0→1'));
    expect(updates.last, contains('1→2'));
  });

  test('dispose 事件：container.dispose 触发 didDisposeProvider', () {
    final observer = _RecordingObserver()..enabled = false;
    final container = ProviderContainer(observers: <ProviderObserver>[observer]);

    container.read(greetingProvider);
    container.dispose();

    expect(
      observer.events.any((e) => e.startsWith('dispose:greetingProvider')),
      isTrue,
    );
  });

  test('enabled=false 时 _log 短路（不抛错也不副作用）', () {
    final observer = AppProviderObserver()..enabled = false;
    final container = ProviderContainer(observers: <ProviderObserver>[observer]);
    addTearDown(container.dispose);

    // 不抛错即可：本测验证 enabled 字段路径
    expect(() => container.read(greetingProvider), returnsNormally);
  });
}
