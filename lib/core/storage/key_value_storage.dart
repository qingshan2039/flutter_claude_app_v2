import 'package:flutter_claude_app_v2/core/storage/database/app_database.dart' show AppDatabase;
import 'package:flutter_claude_app_v2/core/storage/secure_storage.dart' show SecureStorage;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通用键值存储抽象（T05.1）。
///
/// 设计要点：
/// - 接口故意不绑定 SharedPreferences；后续可在测试 / 桌面端切换 Hive 实现
/// - 读取为同步（SharedPreferences 启动后内存缓存）；写入异步
/// - 仅支持 SharedPreferences 原生类型：String / int / bool / double / List&lt;String&gt;
///
/// 不适合本接口的场景：
/// - 敏感数据（token、密码） → 用 [SecureStorage]（T05.2）
/// - 复杂对象 / 关系数据 → 用 [AppDatabase]（T05.3）
abstract class KeyValueStorage {
  String? getString(String key);
  Future<bool> setString(String key, String value);

  int? getInt(String key);
  Future<bool> setInt(String key, int value);

  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);

  double? getDouble(String key);
  Future<bool> setDouble(String key, double value);

  List<String>? getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);

  Future<bool> remove(String key);
  Future<bool> clear();
  bool containsKey(String key);
  Set<String> getKeys();
}

/// SharedPreferences 实现。
///
/// 由 [SharedPreferencesModule] 通过 `@module` + `@preResolve` 提供：
/// `SharedPreferences.getInstance()` 是 async，需在 `configureDependencies()` 时
/// 预解析（injectable 的 `@preResolve` 让 DI 容器先 await 它）。
@LazySingleton(as: KeyValueStorage)
class SharedPreferencesStorage implements KeyValueStorage {
  SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  int? getInt(String key) => _prefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  double? getDouble(String key) => _prefs.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);

  @override
  Future<bool> clear() => _prefs.clear();

  @override
  bool containsKey(String key) => _prefs.containsKey(key);

  @override
  Set<String> getKeys() => _prefs.getKeys();
}

/// 把 [SharedPreferences] 注入 DI；async 初始化由 `@preResolve` 处理。
///
/// 调用：`await configureDependencies()` 会等待 SharedPreferences.getInstance() 解析。
@module
abstract class SharedPreferencesModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
