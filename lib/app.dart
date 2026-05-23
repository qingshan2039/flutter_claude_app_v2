import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/i18n/locale_provider.dart';
import 'package:flutter_claude_app_v2/core/lifecycle/app_lifecycle.dart';
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:flutter_claude_app_v2/core/responsive/font_scaling.dart';
import 'package:flutter_claude_app_v2/core/router/app_router.dart';
import 'package:flutter_claude_app_v2/core/router/router_log_observer.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme.dart';
import 'package:flutter_claude_app_v2/core/theme/theme_mode_provider.dart';
import 'package:flutter_claude_app_v2/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 根 Widget（T13.1，原 T01.2 预留的 app.dart）。
///
/// 把此前各模块在 [MaterialApp.router] 上汇聚：
/// - M07 路由：`routerConfig`（含 Shell / guard / 404 / observer）
/// - M08 国际化：`locale` + `localizationsDelegates` + `supportedLocales`
/// - M10 主题：`theme` / `darkTheme` / `themeMode`
/// - M12 字体缩放：`builder` 包 [ClampedTextScaling]
/// - M13 生命周期：initState 注册 [AppLifecycleObserver]
class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final GoRouter _router;
  late final AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    // 路由需要 ProviderContainer（守卫读 isLoggedInProvider）+ 日志 observer。
    _router = createAppRouter(
      container: ProviderScope.containerOf(context, listen: false),
      observer: getIt<RouterLogObserver>(),
    );
    // 生命周期监听（T13.5）
    _lifecycleObserver = AppLifecycleObserver(logger: getIt<AppLogger>());
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
      builder: (context, child) => ClampedTextScaling(child: child!),
    );
  }
}
