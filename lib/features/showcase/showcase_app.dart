import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/i18n/locale_provider.dart';
import 'package:flutter_claude_app_v2/core/responsive/font_scaling.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme.dart';
import 'package:flutter_claude_app_v2/core/theme/theme_mode_provider.dart';
import 'package:flutter_claude_app_v2/features/showcase/showcase_gallery_page.dart';
import 'package:flutter_claude_app_v2/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Showcase 根 Widget。
///
/// 用普通 [MaterialApp]（非 go_router）+ 画廊首页，绕过主 App 的登录守卫，
/// 让人直接看到各模块效果。仍接 theme/locale，使主题/国际化 demo 能实时生效。
class ShowcaseApp extends ConsumerWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Showcase',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => ClampedTextScaling(child: child!),
      home: const ShowcaseGalleryPage(),
    );
  }
}
