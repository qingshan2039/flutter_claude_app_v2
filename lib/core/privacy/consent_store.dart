import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:injectable/injectable.dart';

/// 隐私同意状态存储（T24.1）。
///
/// 记录用户是否同意隐私政策、同意的**版本**与时间。隐私政策更新版本号后，
/// [needsConsent] 会再次要求用户重新同意（合规要求实质性变更需重新告知）。
///
/// 持久化在 [KeyValueStorage]（非敏感数据）。SDK 初始化分级（T24.2）据此决定
/// 是否初始化可选 SDK。
@lazySingleton
class ConsentStore {
  const ConsentStore(this._storage);

  final KeyValueStorage _storage;

  static const String _versionKey = 'privacy.consent.version';
  static const String _timestampKey = 'privacy.consent.timestamp';

  /// 已同意的隐私政策版本（从未同意则为 null）。
  String? agreedVersion() => _storage.getString(_versionKey);

  /// 同意时间（ISO8601；无则 null）。
  DateTime? agreedAt() {
    final raw = _storage.getString(_timestampKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// 是否已同意**当前版本** [currentVersion] 的隐私政策。
  bool hasAgreed(String currentVersion) => agreedVersion() == currentVersion;

  /// 是否需要弹出同意（未同意，或同意的是旧版本）。
  bool needsConsent(String currentVersion) => !hasAgreed(currentVersion);

  /// 记录用户同意 [version] 版本。
  Future<void> agree(String version, {DateTime? at}) async {
    await _storage.setString(_versionKey, version);
    await _storage.setString(
      _timestampKey,
      (at ?? DateTime.now()).toIso8601String(),
    );
  }

  /// 撤回同意（清除记录）。撤回后应停用可选 SDK。
  Future<void> revoke() async {
    await _storage.remove(_versionKey);
    await _storage.remove(_timestampKey);
  }
}
