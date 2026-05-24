import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/offline/cache_store.dart';
import 'package:injectable/injectable.dart';

/// 缓存策略（T25.1）。
enum CachePolicy {
  /// 网络优先：在线先取网络（失败回退缓存）；离线用缓存。
  networkFirst,

  /// 缓存优先：缓存命中且未过期则用缓存；否则在线取网络；离线用旧缓存。
  cacheFirst,

  /// 仅缓存：只读缓存，从不发网络。
  cacheOnly,

  /// 仅网络：只发网络（在线），不读缓存；离线则无数据。
  networkOnly,
}

/// 数据来源。
enum CacheSource { network, cache, none }

/// 取数结果（T25.1）。
@immutable
class CacheResult<T> {
  const CacheResult({required this.data, required this.source, this.isStale = false});

  final T? data;
  final CacheSource source;

  /// 命中缓存但已超过 maxAge（仍返回，标记为陈旧）。
  final bool isStale;

  bool get hasData => data != null;
}

/// 按 [CachePolicy] 编排「缓存 + 网络」取数（T25.1，离线优先核心）。
///
/// 与具体网络库无关：调用方传入 [networkFetch] 与 JSON 编解码回调即可。
/// [isOnline] 通常来自 `ConnectivityService`（T25.4）。
@lazySingleton
class CachedFetcher {
  const CachedFetcher(this._store);

  final CacheStore _store;

  Future<CacheResult<T>> fetch<T>({
    required String key,
    required CachePolicy policy,
    required Future<T> Function() networkFetch,
    required Object? Function(T value) encode,
    required T Function(Object? json) decode,
    Duration? maxAge,
    bool isOnline = true,
    DateTime Function()? clock,
  }) async {
    final now = (clock ?? DateTime.now)();

    Future<CacheResult<T>> fromCache({required bool allowStale}) async {
      final entry = await _store.read(key);
      if (entry == null) {
        return const CacheResult(data: null, source: CacheSource.none);
      }
      final stale = maxAge != null && entry.isStale(maxAge, now);
      if (stale && !allowStale) {
        return CacheResult<T>(
          data: decode(entry.data),
          source: CacheSource.cache,
          isStale: true,
        );
      }
      return CacheResult<T>(
        data: decode(entry.data),
        source: CacheSource.cache,
        isStale: stale,
      );
    }

    Future<CacheResult<T>> fromNetwork() async {
      final value = await networkFetch();
      await _store.write(key, encode(value), now: now);
      return CacheResult<T>(data: value, source: CacheSource.network);
    }

    switch (policy) {
      case CachePolicy.cacheOnly:
        return fromCache(allowStale: true);

      case CachePolicy.networkOnly:
        if (!isOnline) {
          return const CacheResult(data: null, source: CacheSource.none);
        }
        return fromNetwork();

      case CachePolicy.cacheFirst:
        final cached = await fromCache(allowStale: false);
        if (cached.hasData && !cached.isStale) return cached;
        if (isOnline) {
          try {
            return await fromNetwork();
          } catch (_) {
            // 网络失败：退回（可能陈旧的）缓存。
            return cached.hasData ? cached : fromCache(allowStale: true);
          }
        }
        return cached.hasData ? cached : fromCache(allowStale: true);

      case CachePolicy.networkFirst:
        if (isOnline) {
          try {
            return await fromNetwork();
          } catch (_) {
            return fromCache(allowStale: true);
          }
        }
        return fromCache(allowStale: true);
    }
  }
}
