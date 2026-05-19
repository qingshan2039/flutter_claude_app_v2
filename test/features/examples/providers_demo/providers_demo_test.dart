import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/auto_dispose_search_provider.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/combined_greeting_provider.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/counter_state_notifier.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/greeting_provider.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/user_async_notifier.dart';
import 'package:flutter_claude_app_v2/features/examples/providers_demo/user_future_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderContainer createContainer({List<Override>? overrides}) {
    final container = ProviderContainer(overrides: overrides ?? <Override>[]);
    addTearDown(container.dispose);
    return container;
  }

  group('greetingProvider (Provider 同步)', () {
    test('返回固定问候语', () {
      final container = createContainer();
      expect(container.read(greetingProvider), 'Hello, World!');
    });
  });

  group('userFutureProvider (FutureProvider 三态)', () {
    test('初始 loading → 解析后 data', () async {
      final container = createContainer();
      // 第一次 read 立刻拿到 AsyncLoading
      expect(container.read(userFutureProvider).isLoading, isTrue);

      // 等待 future 完成
      final user = await container.read(userFutureProvider.future);
      expect(user, isA<User>());
      expect(user.id, 'demo-future-1');

      // 再次 read 现在是 AsyncData
      final after = container.read(userFutureProvider);
      expect(after.hasValue, isTrue);
      expect(after.value!.id, 'demo-future-1');
    });
  });

  group('counterStateNotifierProvider (StateNotifierProvider)', () {
    test('初始状态 0', () {
      final container = createContainer();
      expect(container.read(counterStateNotifierProvider), 0);
    });

    test('increment / decrement / reset', () {
      final container = createContainer();
      final notifier = container.read(counterStateNotifierProvider.notifier);

      notifier.increment();
      notifier.increment();
      notifier.increment();
      expect(container.read(counterStateNotifierProvider), 3);

      notifier.decrement();
      expect(container.read(counterStateNotifierProvider), 2);

      notifier.reset();
      expect(container.read(counterStateNotifierProvider), 0);
    });
  });

  group('userAsyncNotifierProvider (AsyncNotifierProvider)', () {
    test('初始 loading → data', () async {
      final container = createContainer();
      expect(container.read(userAsyncNotifierProvider).isLoading, isTrue);

      await container.read(userAsyncNotifierProvider.future);
      expect(container.read(userAsyncNotifierProvider).value!.id, 'async-1');
    });

    test('updateName 仅在 data 状态下生效', () async {
      final container = createContainer();
      await container.read(userAsyncNotifierProvider.future);

      container.read(userAsyncNotifierProvider.notifier).updateName('Alice');
      expect(
        container.read(userAsyncNotifierProvider).value!.name,
        'Alice',
      );
    });

    test('refresh 触发 loading 后再次 data', () async {
      final container = createContainer();
      await container.read(userAsyncNotifierProvider.future);

      final refreshFuture =
          container.read(userAsyncNotifierProvider.notifier).refresh();
      expect(container.read(userAsyncNotifierProvider).isLoading, isTrue);

      await refreshFuture;
      expect(container.read(userAsyncNotifierProvider).hasValue, isTrue);
    });
  });

  group('greetingWithCounterProvider (组合)', () {
    test('随 counter 变化重算', () {
      final container = createContainer();
      expect(
        container.read(greetingWithCounterProvider),
        'Hello, World! (counter = 0)',
      );

      container.read(counterStateNotifierProvider.notifier).increment();
      expect(
        container.read(greetingWithCounterProvider),
        'Hello, World! (counter = 1)',
      );
    });
  });

  group('autoDisposeSearchProvider (autoDispose + family)', () {
    test('空 query 返回空列表', () async {
      final container = createContainer();
      final results = await container.read(autoDisposeSearchProvider('').future);
      expect(results, isEmpty);
    });

    test('非空 query 返回三条带序号结果', () async {
      final container = createContainer();
      final results =
          await container.read(autoDisposeSearchProvider('dart').future);
      expect(results, <String>['dart #1', 'dart #2', 'dart #3']);
    });

    test('不同 query 之间互不污染', () async {
      final container = createContainer();
      final r1 = await container.read(autoDisposeSearchProvider('a').future);
      final r2 = await container.read(autoDisposeSearchProvider('b').future);
      expect(r1, <String>['a #1', 'a #2', 'a #3']);
      expect(r2, <String>['b #1', 'b #2', 'b #3']);
    });
  });
}
