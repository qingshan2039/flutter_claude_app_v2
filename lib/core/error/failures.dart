import 'package:flutter_claude_app_v2/core/error/error_mapper.dart' show ErrorMapper;
import 'package:flutter_claude_app_v2/core/error/exceptions.dart' show AppException;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// 领域层错误类型（Failure）。
///
/// 设计要点（T03.2）：
/// - 使用 freezed sealed class，支持 Dart 3 穷尽 pattern matching
/// - 提供 value equality（两个相同字段的 Failure 相等）
/// - 不携带 [StackTrace]：领域层不关心调试细节；调试信息在 data 层日志记录
/// - 与 data 层 [AppException] 的对应关系由 [ErrorMapper] 维护
///
/// 使用：
/// ```dart
/// final result = await repository.getUser();
/// switch (result) {
///   case Success(value: final user): showUser(user);
///   case Failed(failure: final f): switch (f) {
///     case NetworkFailure(): showOffline();
///     case ServerFailure(statusCode: final c, :final message): showError(c, message);
///     case UnauthorizedFailure(): redirectToLogin();
///     case ValidationFailure(:final field): highlightField(field);
///     case CacheFailure(): /* 缓存失败往往可忽略 */;
///     case UnknownFailure(:final message): showError(null, message);
///   };
/// }
/// ```
@freezed
sealed class Failure with _$Failure {
  /// 网络相关失败（断网、超时、DNS、TLS）。
  const factory Failure.network({
    @Default('Network error') String message,
  }) = NetworkFailure;

  /// 后端业务/HTTP 错误。[statusCode] 为 HTTP 状态码；[code] 为业务错误码。
  const factory Failure.server({
    required String message,
    int? statusCode,
    String? code,
  }) = ServerFailure;

  /// 本地缓存读写失败。
  const factory Failure.cache({
    @Default('Cache error') String message,
  }) = CacheFailure;

  /// 未授权（token 失效、未登录、权限不足）。
  const factory Failure.unauthorized({
    @Default('Unauthorized') String message,
  }) = UnauthorizedFailure;

  /// 表单/输入校验失败。[field] 出错字段名（可选，便于 UI 高亮）。
  const factory Failure.validation({
    required String message,
    String? field,
  }) = ValidationFailure;

  /// 未明确分类的失败。兜底。
  const factory Failure.unknown({
    @Default('Unknown error') String message,
  }) = UnknownFailure;
}

/// 从 sealed [Failure] 基类取面向用户的 [message]（各变体都带 message 字段，
/// 但基类不暴露；此扩展统一取出，便于 UI 直接 `failure.message`）。
extension FailureMessageX on Failure {
  String get message => switch (this) {
    NetworkFailure(:final message) => message,
    ServerFailure(:final message) => message,
    CacheFailure(:final message) => message,
    UnauthorizedFailure(:final message) => message,
    ValidationFailure(:final message) => message,
    UnknownFailure(:final message) => message,
  };
}
