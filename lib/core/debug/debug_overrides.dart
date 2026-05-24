import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// Debug 运行时覆盖（T29.2 环境切换）。
///
/// 持久化「调试用 BaseUrl 覆盖」，让测试人员在不重装的情况下切换后端环境。
/// 网络层在解析 baseUrl 时优先用 [effectiveBaseUrl]（仅 dev/staging 生效）。
@lazySingleton
class DebugOverrides {
  const DebugOverrides(this._storage);

  final KeyValueStorage _storage;

  static const String _baseUrlKey = 'debug.base_url_override';

  /// 当前 BaseUrl 覆盖（未设置为 null）。
  String? get baseUrlOverride {
    final v = _storage.getString(_baseUrlKey);
    return (v == null || v.isEmpty) ? null : v;
  }

  Future<void> setBaseUrl(String url) => _storage.setString(_baseUrlKey, url);

  Future<void> clearBaseUrl() => _storage.remove(_baseUrlKey);

  /// 解析有效 BaseUrl：有覆盖用覆盖，否则用 [fallback]（一般传 EnvConfig.apiBaseUrl）。
  String effectiveBaseUrl(String fallback) => baseUrlOverride ?? fallback;
}
