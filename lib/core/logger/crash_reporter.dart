import 'package:injectable/injectable.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// 崩溃 / 异常上报抽象（T11.4）。
///
/// 业务与 [GlobalErrorHandler]（M03/T03.5）通过本抽象上报，不直接依赖 Sentry SDK。
/// 默认绑定 [NoopCrashReporter]（无 DSN 时安全空实现）；M13/T13.1 bootstrap 在
/// `SentryFlutter.init` 之后把绑定切到 [SentryCrashReporter]。
abstract class CrashReporter {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  });

  Future<void> addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  });

  Future<void> setUser(String? id);

  Future<void> setTag(String key, String value);
}

/// 默认空实现（T11.4）。无 Sentry DSN 时使用：所有调用安全 no-op。
///
/// `@LazySingleton(as: CrashReporter)` 让 DI 默认解析到本实现；接入真实 Sentry
/// 后在 bootstrap 用 `getIt.unregister` + 重新注册切到 [SentryCrashReporter]。
@LazySingleton(as: CrashReporter)
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace,
      {bool fatal = false}) async {}

  @override
  Future<void> addBreadcrumb(String message,
      {String? category, Map<String, dynamic>? data}) async {}

  @override
  Future<void> setUser(String? id) async {}

  @override
  Future<void> setTag(String key, String value) async {}
}

/// 基于 sentry_flutter 的实现（T11.4）。
///
/// 需先 `SentryFlutter.init(...)`（见 [SentryConfig.run]）。本类只封装运行时调用，
/// 把 [CrashReporter] 接口委托给 Sentry 静态 API。
class SentryCrashReporter implements CrashReporter {
  const SentryCrashReporter();

  @override
  Future<void> recordError(Object error, StackTrace? stackTrace,
      {bool fatal = false}) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) => scope.level = fatal ? SentryLevel.fatal : SentryLevel.error,
    );
  }

  @override
  Future<void> addBreadcrumb(String message,
      {String? category, Map<String, dynamic>? data}) async {
    await Sentry.addBreadcrumb(
      Breadcrumb(message: message, category: category, data: data),
    );
  }

  @override
  Future<void> setUser(String? id) async {
    await Sentry.configureScope(
      (scope) => scope.setUser(id == null ? null : SentryUser(id: id)),
    );
  }

  @override
  Future<void> setTag(String key, String value) async {
    await Sentry.configureScope((scope) => scope.setTag(key, value));
  }
}

/// Sentry 初始化助手（T11.4）。
///
/// 在 M13/T13.1 的 `main` 中使用：
/// ```dart
/// await SentryConfig.run(
///   dsn: const String.fromEnvironment('SENTRY_DSN'),
///   environment: 'prod',
///   appRunner: () => runApp(const MyApp()),
/// );
/// ```
///
/// DSN 为空（未配置）时跳过 Sentry，直接运行 appRunner，方便本地开发。
abstract final class SentryConfig {
  static Future<void> run({
    required String dsn,
    required String environment,
    required Future<void> Function() appRunner,
    double tracesSampleRate = 0.2,
  }) async {
    if (dsn.isEmpty) {
      await appRunner();
      return;
    }
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = environment;
        options.tracesSampleRate = tracesSampleRate;
      },
      appRunner: appRunner,
    );
  }
}
