import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// 一条缓存记录（T25.1）。
@immutable
class CacheEntry {
  const CacheEntry({required this.data, required this.savedAt});

  /// 已解码的 JSON 数据（Map / List / 基本类型）。
  final Object? data;

  /// 写入时间，用于判断是否过期。
  final DateTime savedAt;

  /// 相对 [now] 是否已超过 [maxAge]。
  bool isStale(Duration maxAge, DateTime now) =>
      now.isAfter(savedAt.add(maxAge));
}

/// 缓存存储抽象（T25.1）：按 key 读写「数据 + 写入时间」。
abstract class CacheStore {
  Future<CacheEntry?> read(String key);
  Future<void> write(String key, Object? data, {DateTime? now});
  Future<void> remove(String key);
}

/// 基于 [KeyValueStorage] 的缓存实现：把 `{savedAt, data}` 以 JSON 持久化。
///
/// 生产若需 HTTP 层缓存，可改用 `dio_cache_interceptor`（在 Dio 拦截器链中缓存
/// 响应）；本实现是**数据层通用缓存**，与具体网络库解耦，便于离线优先编排。
@LazySingleton(as: CacheStore)
class KeyValueCacheStore implements CacheStore {
  const KeyValueCacheStore(this._storage);

  final KeyValueStorage _storage;

  static const String _keyPrefix = 'cache.';

  String _k(String key) => '$_keyPrefix$key';

  @override
  Future<CacheEntry?> read(String key) async {
    final raw = _storage.getString(_k(key));
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final savedAt = DateTime.tryParse(map['savedAt'] as String? ?? '');
      if (savedAt == null) return null;
      return CacheEntry(data: map['data'], savedAt: savedAt);
    } on FormatException {
      return null; // 损坏的缓存当作未命中
    }
  }

  @override
  Future<void> write(String key, Object? data, {DateTime? now}) async {
    final payload = jsonEncode(<String, dynamic>{
      'savedAt': (now ?? DateTime.now()).toIso8601String(),
      'data': data,
    });
    await _storage.setString(_k(key), payload);
  }

  @override
  Future<void> remove(String key) => _storage.remove(_k(key));
}
