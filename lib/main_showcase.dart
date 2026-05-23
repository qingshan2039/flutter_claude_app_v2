import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/error/global_error_handler.dart';
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:flutter_claude_app_v2/core/observer/provider_observer.dart';
import 'package:flutter_claude_app_v2/features/showcase/showcase_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Showcase 入口：直达模块效果画廊（不经登录守卫）。
///
/// ```bash
/// flutter run -t lib/main_showcase.dart
/// ```
///
/// 启动时完成 DI（各 demo 依赖 getIt），再渲染 [ShowcaseApp]。
void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await configureDependencies(environment: 'dev');
      final logger = getIt<AppLogger>();
      registerGlobalErrorHandlers(
        reporter: (error, stack) =>
            logger.e('Uncaught', error: error, stackTrace: stack),
      );
      logger.i('Showcase launching');
      runApp(
        ProviderScope(
          observers: <ProviderObserver>[getIt<AppProviderObserver>()],
          child: const ShowcaseApp(),
        ),
      );
    },
    (error, stack) {
      if (getIt.isRegistered<AppLogger>()) {
        getIt<AppLogger>().e('Zone error', error: error, stackTrace: stack);
      }
    },
  );
}
