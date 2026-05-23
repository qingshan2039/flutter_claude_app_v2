import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart' show KeyValueStorage;
import 'package:flutter_claude_app_v2/core/storage/secure_token_storage.dart' show SecureTokenStorage;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// 加密键值存储抽象（T05.2）。
///
/// 用于保存 token、密钥、PII 等敏感数据。iOS Keychain / Android EncryptedSharedPreferences
/// 由 [FlutterSecureStorage] 在底层实现；本抽象让上层不直接依赖 platform channel。
///
/// 与 [KeyValueStorage] 的区别：
/// - 性能：SecureStorage 每次读写都过 native 层，**不要**在 hot path 调用
/// - 容量：仅适合存少量小数据（< 100 个 key，单值 < 几 KB）
/// - 一致性：返回均为 [Future]（底层 native 调用本身就是 async）
abstract class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<Map<String, String>> readAll();
  Future<bool> containsKey(String key);
}

/// 基于 [FlutterSecureStorage] 的实现。
///
/// Android: 强制启用 EncryptedSharedPreferences（更稳定，不依赖 Keystore 异常）。
/// iOS: 默认 Keychain。
@LazySingleton(as: SecureStorage)
class FlutterSecureStorageImpl implements SecureStorage {
  FlutterSecureStorageImpl()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();

  @override
  Future<Map<String, String>> readAll() => _storage.readAll();

  @override
  Future<bool> containsKey(String key) => _storage.containsKey(key: key);
}

/// 测试 / 开发用的内存实现。**不注册到 DI**——仅在测试中直接 new 出来。
///
/// FlutterSecureStorage 依赖 platform channel，在 unit test 默认不可用；
/// 因此 SecureStorage 的消费者（如 [SecureTokenStorage]）的单测应直接传入本实现。
class InMemorySecureStorage implements SecureStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<Map<String, String>> readAll() async => Map<String, String>.from(_store);

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);
}
