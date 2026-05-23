import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/log_interceptor.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/retry_interceptor.dart';
import 'package:injectable/injectable.dart';

/// 网络层 Dio 客户端模块（T04.1）。
///
/// 通过 `@module` 把 Dio 注册到 DI；所有拦截器按职责顺序装入：
/// 1. [AuthInterceptor]：注入 token / 处理 401 刷新
/// 2. [LoggingInterceptor]：开发期打印（先于错误转换，便于看到原始响应）
/// 3. [RetryInterceptor]：网络抖动重试
/// 4. [ApiErrorInterceptor]：HTTP / 业务码 → AppException（**最后**装，确保
///    其它拦截器先处理）
///
/// `baseUrl` 与超时参数：M15/T15.1 完成后从 `EnvConfig` 读取；目前用编译常量占位。
@module
abstract class NetworkModule {
  /// 提供 [LoggingInterceptor]（用默认构造，[LoggingInterceptor.enabled] =
  /// `kDebugMode`）。
  ///
  /// 不在类上标 `@lazySingleton`：那样 injectable 会把默认值参数 `enabled`
  /// 当成需注入的依赖，生成 `gh<bool>()` 解析一个未注册的 bool 而在解析 Dio
  /// 时抛 `Object/factory with type bool is not registered`。
  @lazySingleton
  LoggingInterceptor provideLoggingInterceptor() => LoggingInterceptor();

  /// 提供 [RetryInterceptor]（用默认构造：maxRetries=3、baseDelay=500ms）。
  /// 同 [provideLoggingInterceptor]：避免 injectable 把默认值参数当依赖注入。
  @lazySingleton
  RetryInterceptor provideRetryInterceptor() => RetryInterceptor();

  /// 默认 base URL；M15/T15.1 完成后由 EnvConfig.apiBaseUrl 替换。
  ///
  /// 通过 `--dart-define API_BASE_URL=https://api.example.com` 可在编译期覆盖。
  @lazySingleton
  Dio provideDio(
    TokenStorage tokenStorage,
    TokenRefresher tokenRefresher,
    AuthEvents authEvents,
    LoggingInterceptor logInterceptor,
    RetryInterceptor retryInterceptor,
    ApiErrorInterceptor errorInterceptor,
  ) {
    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    );

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // AuthInterceptor 不走 DI（需要 dio 反向引用），手动 new
    final authInterceptor = AuthInterceptor(
      storage: tokenStorage,
      refresher: tokenRefresher,
      events: authEvents,
    );

    dio.interceptors.addAll([
      authInterceptor,
      logInterceptor,
      retryInterceptor,
      errorInterceptor,
    ]);

    // 把 dio 引用回填给需要重发请求的拦截器（避免循环依赖）
    authInterceptor.dio = dio;
    retryInterceptor.dio = dio;

    return dio;
  }
}
