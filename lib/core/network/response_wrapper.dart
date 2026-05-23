import 'package:flutter_claude_app_v2/core/network/interceptors/error_interceptor.dart' show ApiErrorInterceptor;

/// 后端标准响应外壳：`{ code, message, data }`。
///
/// 设计要点（T04.8）：
/// - 业务约定 `code == 0` 视为成功，其它为业务错误
/// - 解包失败由 [ApiErrorInterceptor]（T04.4）抛 `ServerException`
/// - 泛型 `T` 由调用方提供 `fromJsonT` 反序列化函数；不强制依赖 json_serializable
///
/// 与 retrofit 配合：retrofit 默认会把响应整体当成 model 的 fromJson，要么：
/// - 直接让 model 包含 code/message/data 字段（破坏 model 纯净）
/// - 或在拦截器层先解包 envelope，让 retrofit 只看到 data 字段（**本模板采用**）
class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? data) fromJsonT,
  ) {
    final raw = json['data'];
    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String?,
      data: raw == null ? null : fromJsonT(raw),
    );
  }

  /// 业务成功码（默认 0）。后端约定一致即可。
  static const int kSuccessCode = 0;

  final int code;
  final String? message;
  final T? data;

  bool get isSuccess => code == kSuccessCode;
  bool get isFailure => !isSuccess;

  @override
  String toString() =>
      'ApiResponse(code: $code, message: $message, data: $data)';
}
