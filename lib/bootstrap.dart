import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/app.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';
import 'package:flutter_claude_app_v2/core/error/global_error_handler.dart';
import 'package:flutter_claude_app_v2/core/logger/app_logger.dart';
import 'package:flutter_claude_app_v2/core/logger/crash_reporter.dart';
import 'package:flutter_claude_app_v2/core/observer/provider_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 统一启动编排（T13.1 / T13.3）。
///
/// 由各环境入口调用：`void main() => bootstrap(AppEnvironment.dev);`
///
/// 执行顺序（关键路径 = 阻塞首帧；非关键 = 首帧后延迟）：
/// 1. **关键**：binding 初始化 → DI 解析（含 SharedPreferences/Hive @preResolve）
/// 2. **关键**：安装全局错误处理（M03）+ 接入 AppLogger/CrashReporter（M11）
/// 3. **关键**：runApp（首帧）
/// 4. **非关键**：首帧后清理过期日志等（不阻塞启动）
///
/// 整个流程在 [runZonedGuarded] 内，捕获所有未处理异步异常。
void bootstrap(AppEnvironment environment) {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ── 关键路径 1：依赖注入（含存储 @preResolve）──
      await configureDependencies(environment: environment.injectableName);

      final logger = getIt<AppLogger>();
      final crashReporter = getIt<CrashReporter>();

      // ── 关键路径 2：全局错误处理接入 AppLogger + CrashReporter（M03 + M11 回填）──
      void report(Object error, StackTrace stackTrace) {
        logger.e('Uncaught error', error: error, stackTrace: stackTrace);
        unawaited(crashReporter.recordError(error, stackTrace, fatal: true));
      }

      registerGlobalErrorHandlers(reporter: report);
      listenIsolateErrors(reporter: report);
      await crashReporter.setTag('environment', environment.name);

      logger.i('Bootstrapping app in ${environment.name} environment');

      // ── 关键路径 3：首帧 ──
      runApp(
        ProviderScope(
          observers: <ProviderObserver>[getIt<AppProviderObserver>()],
          child: const App(),
        ),
      );

      // ── 非关键路径：首帧后延迟，不阻塞启动（T13.3）──
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_initDeferred(logger));
      });
    },
    (Object error, StackTrace stackTrace) {
      // zone 兜底：DI 可能尚未就绪，故防御性检查。
      if (getIt.isRegistered<AppLogger>()) {
        getIt<AppLogger>().e('Zone error', error: error, stackTrace: stackTrace);
      } else {
        // ignore: avoid_print
        debugPrint('[bootstrap] zone error before DI ready: $error');
      }
      if (getIt.isRegistered<CrashReporter>()) {
        unawaited(
          getIt<CrashReporter>().recordError(error, stackTrace, fatal: true),
        );
      }
    },
  );
}

/// 非关键初始化（T13.3）：首帧渲染后执行，不阻塞启动。
///
/// 这里放「可以晚一点」的工作：日志清理、缓存预热、远程配置拉取（M28）、
/// 埋点初始化（M27）等。失败不应影响应用可用性。
Future<void> _initDeferred(AppLogger logger) async {
  try {
    // 示例：M11 文件日志清理在此触发（M13 未默认启用文件日志，留作接入点）。
    // 例如：await getIt<LogFileManager>().cleanupExpired();
    logger.d('Deferred (non-critical) initialization complete');
  } catch (e, st) {
    logger.w('Deferred init failed (non-fatal): $e');
    logger.t('stack', stackTrace: st);
  }
}
