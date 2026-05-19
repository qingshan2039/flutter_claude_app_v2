/// 应用层异常基类。所有自定义异常继承自此。
///
/// 设计要点（T03.1）：
/// - 实现 [Exception] 接口，可以被 `throw` / `catch (Exception e)`
/// - 携带 [code]（业务/HTTP 错误码）、[message]（人类可读说明）、[cause]
///   （原始底层异常）、[stackTrace]（调试用）
/// - 子类通常用 `const` 构造，保证可以在 freezed 等不可变场景中复用
/// - 与领域层 [Failure] 解耦：data 层抛 Exception，由 [ErrorMapper] 转 Failure 给上层
abstract class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  final String code;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// 网络相关异常：断网、超时、TLS 失败、DNS 失败、SocketException 等。
///
/// 由 dio 拦截器（M04 / T04.4）捕获并构造。
class NetworkException extends AppException {
  const NetworkException({
    super.code = 'NETWORK',
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// 后端业务/HTTP 错误：5xx 状态码、业务 code 非 0、协议解析失败。
///
/// [statusCode] 为 HTTP 状态码；[code] 为业务错误码（后端协议返回的 code 字段）。
class ServerException extends AppException {
  const ServerException({
    required super.code,
    required super.message,
    this.statusCode,
    super.cause,
    super.stackTrace,
  });

  final int? statusCode;

  @override
  String toString() =>
      'ServerException(code: $code, status: $statusCode, message: $message)';
}

/// 本地缓存读写失败（SharedPreferences、Hive、Isar 等存储抛出）。
class CacheException extends AppException {
  const CacheException({
    super.code = 'CACHE',
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// 未授权：token 失效、未登录、被强制登出、权限不足等。
///
/// 通常由 AuthInterceptor（M04 / T04.3）在收到 401 时构造，触发重登流程。
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.code = 'UNAUTHORIZED',
    super.message = 'Unauthorized',
    super.cause,
    super.stackTrace,
  });
}

/// 表单/输入校验失败。[field] 记录出错字段名，便于 UI 高亮。
class ValidationException extends AppException {
  const ValidationException({
    super.code = 'VALIDATION',
    required super.message,
    this.field,
    super.cause,
    super.stackTrace,
  });

  final String? field;

  @override
  String toString() =>
      'ValidationException(code: $code, field: $field, message: $message)';
}

/// 未明确分类的应用异常。兜底类型。
class UnknownException extends AppException {
  const UnknownException({
    super.code = 'UNKNOWN',
    required super.message,
    super.cause,
    super.stackTrace,
  });
}
