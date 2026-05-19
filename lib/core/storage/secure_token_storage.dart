import 'package:flutter_claude_app_v2/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart';
import 'package:injectable/injectable.dart';

/// 真实的 [TokenStorage] 实现，把 access/refresh token 持久化到 [SecureStorage]。
///
/// **替换** T04.3 引入的 `InMemoryTokenStorage` 占位实现。
/// 启动 [configureDependencies] 后，`getIt<TokenStorage>()` 返回本类的实例。
@LazySingleton(as: TokenStorage)
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final SecureStorage _storage;

  static const String _kAccessKey = 'auth.access_token';
  static const String _kRefreshKey = 'auth.refresh_token';

  @override
  Future<String?> readAccessToken() => _storage.read(_kAccessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(_kRefreshKey);

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(_kAccessKey, accessToken);
    await _storage.write(_kRefreshKey, refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(_kAccessKey);
    await _storage.delete(_kRefreshKey);
  }
}
