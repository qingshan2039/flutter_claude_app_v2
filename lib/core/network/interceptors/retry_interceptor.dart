import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// 重试拦截器（T04.5）。
///
/// 策略：
/// - 仅对网络抖动类错误重试：connectionTimeout / receiveTimeout / sendTimeout
///   / connectionError / 5xx 响应
/// - 指数退避：`delay = baseDelay * 2^attempt + random_jitter`
/// - 重试次数到 [maxRetries] 后放弃，错误透传
/// - 通过 [RequestOptions.extra] 记录当前尝试次数，避免并发问题
///
/// 实际重发请求需要持有 [Dio] 引用：通过 [dio] setter 在 [NetworkModule] 构造完成
/// 之后注入（避免 DI 循环依赖）。
@lazySingleton
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
  });

  final int maxRetries;
  final Duration baseDelay;

  /// 抖动 RNG。生产用默认 [Random]；测试可注入 `Random(seed)` 以确定性。
  Random random = Random();

  /// 必须在 dio 构造完成后由 [NetworkModule.provideDio] 调用 setter 注入。
  Dio? dio;

  static const _attemptKey = 'retry_attempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;

    if (attempt >= maxRetries || !shouldRetry(err)) {
      return handler.next(err);
    }

    final delay = computeBackoff(attempt);
    await Future<void>.delayed(delay);

    final dio = this.dio;
    if (dio == null) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    options.extra[_attemptKey] = attempt + 1;
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// 判定该错误是否值得重试。公开以便测试与业务覆写。
  bool shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode ?? 0;
        return status >= 500 && status < 600;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  /// 指数退避：`baseDelay * 2^attempt + random_jitter`。公开以便测试。
  Duration computeBackoff(int attempt) {
    final factor = pow(2, attempt).toInt();
    final base = baseDelay * factor;
    final jitterMs = random.nextInt(baseDelay.inMilliseconds.clamp(1, 1000));
    return base + Duration(milliseconds: jitterMs);
  }
}
