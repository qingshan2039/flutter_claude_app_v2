import 'dart:ui' show Locale;

import 'package:flutter_claude_app_v2/core/i18n/locale_provider.dart';
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 内存版 KeyValueStorage，用于隔离测试 LocaleNotifier 的持久化逻辑。
class _FakeKeyValueStorage implements KeyValueStorage {
  final Map<String, Object> _store = <String, Object>{};

  @override
  String? getString(String key) => _store[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }

  @override
  bool containsKey(String key) => _store.containsKey(key);

  // 其余方法本测试用不到，给最小实现。
  @override
  Future<bool> clear() async {
    _store.clear();
    return true;
  }

  @override
  Set<String> getKeys() => _store.keys.toSet();
  @override
  bool? getBool(String key) => _store[key] as bool?;
  @override
  Future<bool> setBool(String key, bool value) async {
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
  group('LocaleNotifier 初始状态', () {
    test('无持久化值 → null（跟随系统）', () {
      final container = _container(_FakeKeyValueStorage());
      expect(container.read(localeProvider), isNull);
    });

    test('有持久化值 → 读取对应 Locale', () {
      final storage = _FakeKeyValueStorage();
      storage._store[LocaleNotifier.storageKey] = 'zh';
      final container = _container(storage);
      expect(container.read(localeProvider), const Locale('zh'));
    });
  });

  group('setLocale 切换 + 持久化', () {
    test('切到 zh → state 更新且写入 storage', () async {
      final storage = _FakeKeyValueStorage();
      final container = _container(storage);

      await container
          .read(localeProvider.notifier)
          .setLocale(const Locale('zh'));

      expect(container.read(localeProvider), const Locale('zh'));
      expect(storage.getString(LocaleNotifier.storageKey), 'zh');
    });

    test('setLocale(null) → 移除持久化并恢复跟随系统', () async {
      final storage = _FakeKeyValueStorage();
      storage._store[LocaleNotifier.storageKey] = 'en';
      final container = _container(storage);

      await container.read(localeProvider.notifier).setLocale(null);

      expect(container.read(localeProvider), isNull);
      expect(storage.containsKey(LocaleNotifier.storageKey), isFalse);
    });

    test('useSystemLocale 等价于 setLocale(null)', () async {
      final storage = _FakeKeyValueStorage();
      storage._store[LocaleNotifier.storageKey] = 'zh';
      final container = _container(storage);

      await container.read(localeProvider.notifier).useSystemLocale();

      expect(container.read(localeProvider), isNull);
      expect(storage.containsKey(LocaleNotifier.storageKey), isFalse);
    });

    test('连续切换 en → zh → en 持久化跟随最后一次', () async {
      final storage = _FakeKeyValueStorage();
      final container = _container(storage);
      final notifier = container.read(localeProvider.notifier);

      await notifier.setLocale(const Locale('en'));
      await notifier.setLocale(const Locale('zh'));
      await notifier.setLocale(const Locale('en'));

      expect(container.read(localeProvider), const Locale('en'));
      expect(storage.getString(LocaleNotifier.storageKey), 'en');
    });
  });

  group('kSupportedLocales', () {
    test('包含 en 与 zh', () {
      final codes = kSupportedLocales.map((l) => l.languageCode).toSet();
      expect(codes, containsAll(<String>['en', 'zh']));
    });
  });
}
