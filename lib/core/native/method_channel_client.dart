import 'package:flutter/services.dart';
import 'package:flutter_claude_app_v2/core/native/native_exceptions.dart';

/// MethodChannel 通用封装（T26.1）：统一**双向调用**与错误处理。
///
/// - Dart → 原生：[invoke]（错误归一化为 [NativeUnavailableException] /
///   [NativeCallException]）、[invokeOr]（出错返回兜底值，不抛）。
/// - 原生 → Dart：[setCallHandler] 注册回调（双向通信）。
///
/// 测试：channels 以名称标识，单测里 `setMockMethodCallHandler(MethodChannel(name), ...)`
/// 即可拦截本类发出的调用。
class MethodChannelClient {
  MethodChannelClient(String name) : channel = MethodChannel(name);

  /// 注入已有 channel（主要用于测试）。
  MethodChannelClient.fromChannel(this.channel);

  final MethodChannel channel;

  /// Dart→原生调用。失败抛归一化异常。
  Future<T?> invoke<T>(String method, [Object? arguments]) async {
    try {
      return await channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      throw NativeUnavailableException(method);
    } on PlatformException catch (e) {
      throw NativeCallException(
        method: method,
        code: e.code,
        message: e.message,
      );
    }
  }

  /// invoke 的安全版：平台未实现或出错时返回 [fallback]（不抛）。
  Future<T> invokeOr<T>(
    String method,
    T fallback, [
    Object? arguments,
  ]) async {
    try {
      return await invoke<T>(method, arguments) ?? fallback;
    } on NativeUnavailableException {
      return fallback;
    } on NativeCallException {
      return fallback;
    }
  }

  /// 注册原生→Dart 回调（双向通信）。传 null 取消。
  void setCallHandler(
    Future<Object?> Function(MethodCall call)? handler,
  ) =>
      channel.setMethodCallHandler(handler);
}
