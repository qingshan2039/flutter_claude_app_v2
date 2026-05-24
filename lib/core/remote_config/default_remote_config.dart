import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/remote_config/remote_config.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// 默认远程配置实现（T28.1 + T28.4：缓存与刷新）。
///
/// - **默认值** [defaults]：内置兜底，离线/首启即可用。
/// - **本地缓存**（T28.4）：构造时从 [KeyValueStorage] 加载上次激活值，无需联网即生效。
/// - **刷新**（T28.4）：[fetchAndActivate] 经 [RemoteConfigClient] 拉取并写回缓存；
///   建议在 `bootstrap` 启动时调用一次（失败不影响启动，用旧缓存/默认值）。
@LazySingleton(as: RemoteConfig)
class DefaultRemoteConfig implements RemoteConfig {
  DefaultRemoteConfig(this._client, this._storage) {
    _loadCache();
  }

  final RemoteConfigClient _client;
  final KeyValueStorage _storage;

  static const String _cacheKey = 'remote_config.cache';

  /// 内置默认值（远程缺失/离线时的兜底）。
  static const Map<String, Object> defaults = <String, Object>{
    'welcome_title': '欢迎',
    'new_checkout_enabled': false,
    'max_upload_mb': 20,
    'app_kill_switch': false,
    'app_kill_message': '',
  };

  final Map<String, Object> _activated = <String, Object>{};

  void _loadCache() {
    final raw = _storage.getString(_cacheKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _activated.addAll(map.cast<String, Object>());
    } on FormatException {
      // 缓存损坏 → 忽略，用默认值。
    }
  }

  Object? _raw(String key) => _activated[key] ?? defaults[key];

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final v = _raw(key);
    return v is bool ? v : defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final v = _raw(key);
    return v is num ? v.toInt() : defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0}) {
    final v = _raw(key);
    return v is num ? v.toDouble() : defaultValue;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final v = _raw(key);
    return v is String ? v : defaultValue;
  }

  @override
  Map<String, Object> getAll() => <String, Object>{...defaults, ..._activated};

  @override
  Future<bool> fetchAndActivate() async {
    final fetched = await _client.fetch();
    final changed = !mapEquals(_activated, fetched);
    _activated
      ..clear()
      ..addAll(fetched);
    await _storage.setString(_cacheKey, jsonEncode(fetched));
    return changed;
  }
}
