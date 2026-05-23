import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_claude_app_v2/core/storage/storage_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题模式状态（T10.4）— system / light / dark 三选一 + 持久化。
///
/// MaterialApp 绑定：
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ref.watch(themeModeProvider),
/// );
/// ```
///
/// 切换：
/// ```dart
/// ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String storageKey = 'app.theme_mode';

  @override
  ThemeMode build() {
    final stored = ref.read(keyValueStorageProvider).getString(storageKey);
    return _parse(stored);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(keyValueStorageProvider).setString(storageKey, mode.name);
    state = mode;
  }

  /// 在 light / dark 间快速切换（忽略 system）。当前是 dark → 切 light，否则切 dark。
  Future<void> toggle() async {
    final next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  static ThemeMode _parse(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system, // 默认 / 未持久化 → 跟随系统
    };
  }
}

final NotifierProvider<ThemeModeNotifier, ThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(
      ThemeModeNotifier.new,
      name: 'themeModeProvider',
    );
