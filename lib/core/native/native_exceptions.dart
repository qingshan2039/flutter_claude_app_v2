// 原生互操作异常（M26）。

/// 当前平台未实现该原生方法（非移动端 / 未接入原生 / 测试环境）。
class NativeUnavailableException implements Exception {
  const NativeUnavailableException(this.method);

  final String method;

  @override
  String toString() =>
      'NativeUnavailableException: "$method" 在当前平台未实现';
}

/// 原生侧返回了错误（PlatformException 归一化）。
class NativeCallException implements Exception {
  const NativeCallException({
    required this.method,
    required this.code,
    this.message,
  });

  final String method;
  final String code;
  final String? message;

  @override
  String toString() => 'NativeCallException($method): [$code] ${message ?? ''}';
}
