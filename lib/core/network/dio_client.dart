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
