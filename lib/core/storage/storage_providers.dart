import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/i18n/locale_provider.dart' show LocaleNotifier;
import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart';
import 'package:flutter_claude_app_v2/core/theme/theme_mode_provider.dart' show ThemeModeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 存储层的 Riverpod 桥接 provider（共享）。
///
/// 把 DI 容器中的 [KeyValueStorage] 暴露给 Riverpod 树，供 [LocaleNotifier]（M08）、
/// [ThemeModeNotifier]（M10）等需要持久化的 Notifier 使用。
///
/// 测试中 override 此 provider 注入内存实现，无需触碰 getIt 全局容器：
/// ```dart
/// ProviderContainer(overrides: [
///   keyValueStorageProvider.overrideWithValue(InMemoryKeyValueStorage()),
/// ]);
/// ```
final Provider<KeyValueStorage> keyValueStorageProvider =
    Provider<KeyValueStorage>(
      (ref) => getIt<KeyValueStorage>(),
      name: 'keyValueStorageProvider',
    );
