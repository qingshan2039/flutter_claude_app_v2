import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/network/response_wrapper.dart';
import 'package:injectable/injectable.dart';

/// 错误归一化拦截器（T04.4）。
///
/// 职责：
/// 1. HTTP 错误码（5xx / 4xx）→ 对应 [AppException]
/// 2. 业务错误码（响应 envelope 中 `code != 0`）→ [ServerException]
/// 3. dio 自身错误类型（timeout / cancel / connection）→ [NetworkException]
///
/// 上层（Repository）只需 `on AppException catch (e)` 即可，不直接耦合 [DioException]。
@lazySingleton
class ApiErrorInterceptor extends Interceptor {
  const ApiErrorInterceptor();

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    // 业务错误码：响应 body 是 envelope 且 code != 0
    final data = response.data;
    if (data is Map && data.containsKey('code')) {
      final code = data['code'];
      if (code is int && code != ApiResponse.kSuccessCode) {
        final message = (data['message'] as String?) ?? 'Business error';
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: ServerException(
              code: code.toString(),
              message: message,
              statusCode: response.statusCode,
            ),
          ),
          true, // call subsequent error interceptors
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 已经被前置拦截器附上的 AppException 直接透传
    if (err.error is AppException) {
      return handler.next(err);
    }

    final appException = _convert(err);
    handler.next(
      err.copyWith(error: appException),
    );
  }

  AppException _convert(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          code: 'TIMEOUT',
          message: err.message ?? 'Request timed out',
          cause: err,
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          code: 'CONNECTION',
          message: err.message ?? 'Connection error',
          cause: err,
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.cancel:
        return NetworkException(
          code: 'CANCELLED',
          message: 'Request cancelled',
          cause: err,
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.badCertificate:
        return NetworkException(
          code: 'BAD_CERT',
          message: err.message ?? 'Bad certificate',
          cause: err,
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        if (status == 401) {
          return UnauthorizedException(
            cause: err,
            stackTrace: err.stackTrace,
          );
        }
        return ServerException(
          code: status?.toString() ?? 'BAD_RESPONSE',
          message: err.message ?? 'Server error',
          statusCode: status,
          cause: err,
          stackTrace: err.stackTrace,
        );
      case DioExceptionType.unknown:
        return UnknownException(
          message: err.message ?? err.toString(),
          cause: err,
          stackTrace: err.stackTrace,
        );
    }
  }
}
