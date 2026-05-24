import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';

/// 内存版 [KeyValueStorage]，用于隔离测试持久化逻辑（无需 SharedPreferences）。
class InMemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, Object> _store = <String, Object>{};

  @override
  String? getString(String key) => _store[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _store[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _store[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
    _store[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _store[key] as double?;
  @override
  Future<bool> setDouble(String key, double value) async {
    _store[key] = value;
    return true;
  }

  @override
  List<String>? getStringList(String key) => _store[key] as List<String>?;
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _store.clear();
    return true;
  }

  @override
  bool containsKey(String key) => _store.containsKey(key);

  @override
  Set<String> getKeys() => _store.keys.toSet();
}
