import 'package:flutter_claude_app_v2/core/offline/cache_store.dart';
import 'package:flutter_claude_app_v2/core/offline/cached_fetcher.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

void main() {
  late KeyValueCacheStore store;
  late CachedFetcher fetcher;
  late int networkCalls;

  setUp(() {
    store = KeyValueCacheStore(InMemoryKeyValueStorage());
    fetcher = CachedFetcher(store);
    networkCalls = 0;
  });

  Future<CacheResult<String>> run(
    CachePolicy policy, {
    bool isOnline = true,
    bool fail = false,
    Duration? maxAge,
    DateTime Function()? clock,
    String value = 'net',
  }) {
    return fetcher.fetch<String>(
      key: 'k',
      policy: policy,
      isOnline: isOnline,
      maxAge: maxAge,
      clock: clock,
      networkFetch: () async {
        networkCalls++;
        if (fail) throw Exception('network down');
        return value;
      },
      encode: (v) => v,
      decode: (j) => j! as String,
    );
  }

  group('CacheStore (T25.1)', () {
    test('write/read 往返 + remove', () async {
      await store.write('k', 'v', now: DateTime(2026, 5, 1));
      final entry = await store.read('k');
      expect(entry!.data, 'v');
      expect(entry.savedAt, DateTime(2026, 5, 1));
      await store.remove('k');
      expect(await store.read('k'), isNull);
    });

    test('isStale 按 maxAge 判断', () async {
      await store.write('k', 'v', now: DateTime(2026, 5, 1));
      final entry = (await store.read('k'))!;
      expect(entry.isStale(const Duration(days: 1), DateTime(2026, 5, 1, 12)), isFalse);
      expect(entry.isStale(const Duration(hours: 1), DateTime(2026, 5, 1, 2)), isTrue);
    });
  });

  group('CachedFetcher 策略 (T25.1)', () {
    test('networkOnly：在线取网络并写缓存；离线无数据', () async {
      final r = await run(CachePolicy.networkOnly);
      expect(r.source, CacheSource.network);
      expect(r.data, 'net');
      expect((await store.read('k'))!.data, 'net');

      final offline = await run(CachePolicy.networkOnly, isOnline: false);
      expect(offline.source, CacheSource.none);
      expect(offline.hasData, isFalse);
    });

    test('cacheOnly：只读缓存，从不发网络', () async {
      await store.write('k', 'cached');
      final r = await run(CachePolicy.cacheOnly);
      expect(r.source, CacheSource.cache);
      expect(r.data, 'cached');
      expect(networkCalls, 0);
    });

    test('cacheFirst：新鲜缓存命中则不发网络', () async {
      await store.write('k', 'cached', now: DateTime(2026, 5, 1));
      final r = await run(
        CachePolicy.cacheFirst,
        maxAge: const Duration(days: 1),
        clock: () => DateTime(2026, 5, 1, 6),
      );
      expect(r.source, CacheSource.cache);
      expect(networkCalls, 0);
    });

    test('cacheFirst：缓存过期 + 在线 → 取网络刷新', () async {
      await store.write('k', 'old', now: DateTime(2026, 5, 1));
      final r = await run(
        CachePolicy.cacheFirst,
        maxAge: const Duration(hours: 1),
        clock: () => DateTime(2026, 5, 2),
      );
      expect(r.source, CacheSource.network);
      expect(r.data, 'net');
      expect(networkCalls, 1);
    });

    test('cacheFirst：过期 + 离线 → 退回陈旧缓存', () async {
      await store.write('k', 'old', now: DateTime(2026, 5, 1));
      final r = await run(
        CachePolicy.cacheFirst,
        isOnline: false,
        maxAge: const Duration(hours: 1),
        clock: () => DateTime(2026, 5, 2),
      );
      expect(r.source, CacheSource.cache);
      expect(r.data, 'old');
      expect(r.isStale, isTrue);
      expect(networkCalls, 0);
    });

    test('networkFirst：在线取网络', () async {
      await store.write('k', 'cached');
      final r = await run(CachePolicy.networkFirst);
      expect(r.source, CacheSource.network);
      expect(r.data, 'net');
    });

    test('networkFirst：网络失败 → 回退缓存', () async {
      await store.write('k', 'cached');
      final r = await run(CachePolicy.networkFirst, fail: true);
      expect(r.source, CacheSource.cache);
      expect(r.data, 'cached');
      expect(networkCalls, 1);
    });

    test('networkFirst：离线 → 用缓存', () async {
      await store.write('k', 'cached');
      final r = await run(CachePolicy.networkFirst, isOnline: false);
      expect(r.source, CacheSource.cache);
      expect(networkCalls, 0);
    });
  });
}
