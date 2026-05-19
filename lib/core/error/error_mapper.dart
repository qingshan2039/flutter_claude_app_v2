import 'dart:io';

import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:injectable/injectable.dart';

/// 把任意异常（自定义 [AppException] 或标准 [Exception]）映射为领域层 [Failure]。
///
/// 设计要点（T03.4）：
/// - 注册为 `@lazySingleton`，方便 Repository 实现注入：`final mapper = getIt<ErrorMapper>();`
/// - 覆盖 6 种 [AppException] 子类 + 3 类 dart:io 标准异常 + 兜底 [UnknownFailure]
/// - 第三方 SDK 异常（如 DioException）在引入对应 SDK 的模块（M04）中扩展
///
/// 典型使用（在 Repository 实现里）：
/// ```dart
/// try {
///   final user = await _remoteDataSource.fetchUser();
///   return Success(user);
/// } on Exception catch (e) {
///   return Failed(_mapper.map(e));
/// }
/// ```
@lazySingleton
class ErrorMapper {
  const ErrorMapper();

  /// 把 [error] 转换为对应的 [Failure]。
  Failure map(Object error) {
    return switch (error) {
      NetworkException(message: final m) => Failure.network(message: m),
      ServerException(
        message: final m,
        statusCode: final s,
        code: final c,
      ) =>
        Failure.server(message: m, statusCode: s, code: c),
      CacheException(message: final m) => Failure.cache(message: m),
      UnauthorizedException(message: final m) => Failure.unauthorized(
        message: m,
      ),
      ValidationException(message: final m, field: final f) =>
        Failure.validation(message: m, field: f),
      UnknownException(message: final m) => Failure.unknown(message: m),
      SocketException() => Failure.network(
        message: error.message.isEmpty
            ? 'Network unreachable'
            : error.message,
      ),
      HttpException() => Failure.network(message: error.message),
      FormatException() => Failure.validation(message: error.message),
      _ => Failure.unknown(message: error.toString()),
    };
  }
}
