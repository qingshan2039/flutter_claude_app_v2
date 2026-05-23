import 'dart:ui' show Locale;

import 'package:flutter_claude_app_v2/core/storage/key_value_storage.dart' show KeyValueStorage;
import 'package:flutter_claude_app_v2/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_claude_app_v2/core/storage/storage_providers.dart'
    show keyValueStorageProvider;

/// 支持的语言（T08.4 / T08.5）。新增语言时在此追加并补 ARB 文件。
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('zh'),
];

/// 应用语言状态（T08.4 运行时切换 + T08.5 持久化）。
///
/// 语义：
/// - `null` = 跟随系统语言（首次启动默认）
/// - 非 null = 用户显式选择的语言，持久化到 [KeyValueStorage]
///
/// MaterialApp 绑定：
/// ```dart
/// final locale = ref.watch(localeProvider);
/// MaterialApp(
///   locale: locale,                       // null → Flutter 自动跟随系统
///   supportedLocales: kSupportedLocales,
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
/// );
/// ```
class LocaleNotifier extends Notifier<Locale?> {
  static const String storageKey = 'app.locale';

  @override
  Locale? build() {
    final storage = ref.read(keyValueStorageProvider);
    final code = storage.getString(storageKey);
    if (code == null || code.isEmpty) {
      return null; // 首次启动 → 跟随系统
    }
    return Locale(code);
  }

  /// 切换语言并持久化。传 `null` 恢复「跟随系统」。
  Future<void> setLocale(Locale? locale) async {
    final storage = ref.read(keyValueStorageProvider);
    if (locale == null) {
      await storage.remove(storageKey);
    } else {
      await storage.setString(storageKey, locale.languageCode);
    }
    state = locale;
  }

  /// 便捷方法：恢复跟随系统。
  Future<void> useSystemLocale() => setLocale(null);
}

final NotifierProvider<LocaleNotifier, Locale?> localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(
      LocaleNotifier.new,
      name: 'localeProvider',
    );
