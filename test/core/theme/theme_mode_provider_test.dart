import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_claude_app_v2/core/storage/storage_providers.dart';
import 'package:flutter_claude_app_v2/core/theme/theme_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 内存版 KeyValueStorage（仅实现本测试需要的方法）。
class _FakeKeyValueStorage implements KeyValueStorage {
  final Map<String, Object> store = <String, Object>{};

  @override
  String? getString(String key) => store[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    store[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    store.remove(key);
    return true;
  }

  @override
  bool containsKey(String key) => store.containsKey(key);
  @override
  Future<bool> clear() async {
    store.clear();
    return true;
  }

  @override
  Set<String> getKeys() => store.keys.toSet();
  @override
  bool? getBool(String key) => store[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async => true;
  @override
  int? getInt(String key) => store[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async => true;
  @override
  double? getDouble(String key) => store[key] as double?;
  @override
  Future<bool> setDouble(String key, double value) async => true;
  @override
  List<String>? getStringList(String key) => store[key] as List<String>?;
  @override
  Future<bool> setStringList(String key, List<String> value) async => true;
}

ProviderContainer _container(_FakeKeyValueStorage storage) {
  final container = ProviderContainer(
    overrides: <Override>[
      keyValueStorageProvider.overrideWithValue(storage),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ThemeModeNotifier 初始状态', () {
    test('无持久化值 → system', () {
      final container = _container(_FakeKeyValueStorage());
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('持久化 dark → 读取 dark', () {
      final storage = _FakeKeyValueStorage();
      storage.store[ThemeModeNotifier.storageKey] = 'dark';
      final container = _container(storage);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('非法值 → 回退 system', () {
      final storage = _FakeKeyValueStorage();
      storage.store[ThemeModeNotifier.storageKey] = 'garbage';
      final container = _container(storage);
      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });

  group('setThemeMode 切换 + 持久化', () {
    test('切到 dark → state 与 storage 同步', () async {
      final storage = _FakeKeyValueStorage();
      final container = _container(storage);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(storage.getString(ThemeModeNotifier.storageKey), 'dark');
    });

    test('三选一：system / light / dark 均可持久化', () async {
      final storage = _FakeKeyValueStorage();
      final container = _container(storage);
      final notifier = container.read(themeModeProvider.notifier);

      for (final mode in ThemeMode.values) {
        await notifier.setThemeMode(mode);
        expect(container.read(themeModeProvider), mode);
        expect(storage.getString(ThemeModeNotifier.storageKey), mode.name);
      }
    });
  });

  group('toggle', () {
    test('system/light → dark；dark → light', () async {
      final container = _container(_FakeKeyValueStorage());
      final notifier = container.read(themeModeProvider.notifier);

      // 初始 system → toggle → dark
      await notifier.toggle();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      // dark → toggle → light
      await notifier.toggle();
      expect(container.read(themeModeProvider), ThemeMode.light);

      // light → toggle → dark
      await notifier.toggle();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
