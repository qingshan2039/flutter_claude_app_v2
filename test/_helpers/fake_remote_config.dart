import 'package:flutter_claude_app_v2/core/remote_config/remote_config.dart';

/// Map 支撑的 [RemoteConfig] 测试替身。
class FakeRemoteConfig implements RemoteConfig {
  FakeRemoteConfig([Map<String, Object>? values])
    : _values = <String, Object>{...?values};

  final Map<String, Object> _values;

  void set(String key, Object value) => _values[key] = value;

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    final v = _values[key];
    return v is bool ? v : defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    final v = _values[key];
    return v is num ? v.toInt() : defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0}) {
    final v = _values[key];
    return v is num ? v.toDouble() : defaultValue;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final v = _values[key];
    return v is String ? v : defaultValue;
  }

  @override
  Map<String, Object> getAll() => Map<String, Object>.of(_values);

  @override
  Future<bool> fetchAndActivate() async => false;
}
