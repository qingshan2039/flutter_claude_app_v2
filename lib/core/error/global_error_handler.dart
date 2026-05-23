import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart' show WidgetsFlutterBinding;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show WidgetsFlutterBinding;
import 'package:flutter/widgets.dart' show WidgetsFlutterBinding;

/// 全局未捕获异常回调签名。M11/T11.4 完成后会替换默认实现为 Sentry / Crashlytics 上报。
typedef ErrorReporter = void Function(Object error, StackTrace stackTrace);

void _defaultReporter(Object error, StackTrace stackTrace) {
  debugPrint('[GlobalError] $error');
  debugPrint(stackTrace.toString());
}

/// 全局异常捕获工具（T03.5）。覆盖 4 个错误源：
///
/// 1. [FlutterError.onError] — Widget build/layout/paint 异常
/// 2. [PlatformDispatcher.instance.onError] — 未被 zone 捕获的异步异常
/// 3. [runZonedGuarded] — 包裹整个 `main` 的 zone（由 [runAppGuarded] 提供便利封装）
/// 4. [Isolate.current.addErrorListener] — 主 isolate 中的未处理异常
///
/// 使用模式（在 `main.dart` / `bootstrap.dart`，由 T13.1 接入）：
/// ```dart
/// void main() {
///   runAppGuarded(() {
///     WidgetsFlutterBinding.ensureInitialized();
///     registerGlobalErrorHandlers();
///     listenIsolateErrors();
///     runApp(const MyApp());
///   });
/// }
/// ```
class GlobalErrorHandler {
  const GlobalErrorHandler._();
}

/// 安装 [FlutterError.onError] 与 [PlatformDispatcher.instance.onError]。
///
/// 这是覆盖**同步 Widget 异常**与**异步未捕获异常**的两个主要入口。
/// 调用方应在 [WidgetsFlutterBinding.ensureInitialized] 之后调用本函数。
void registerGlobalErrorHandlers({ErrorReporter? reporter}) {
  final report = reporter ?? _defaultReporter;

  FlutterError.onError = (details) {
    report(details.exception, details.stack ?? StackTrace.current);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    report(error, stackTrace);
    return true; // 已处理；阻止进一步传播
  };
}

/// 监听主 isolate 的未处理错误。返回 [ReceivePort]，调用方负责在合适时机
/// 调用 `port.close()` 与 `Isolate.current.removeErrorListener(port.sendPort)`
/// （生产中通常应用整个生命周期持有，无需主动清理）。
///
/// Isolate.addErrorListener 发送的消息格式为 `[String errorString, String stackString]`。
ReceivePort listenIsolateErrors({ErrorReporter? reporter}) {
  final report = reporter ?? _defaultReporter;
  final port = ReceivePort();
  port.listen((dynamic data) {
    final parsed = parseIsolateMessage(data);
    if (parsed != null) {
      report(parsed.error, parsed.stackTrace);
    }
  });
  Isolate.current.addErrorListener(port.sendPort);
  return port;
}

/// 解析 [Isolate.addErrorListener] 投递的消息。
///
/// 格式：`[errorString, stackString]`。其它形态返回 null。
/// 单独抽出为顶层函数，便于纯单元测试（不依赖真实 isolate）。
({Object error, StackTrace stackTrace})? parseIsolateMessage(Object? data) {
  if (data is! List) return null;
  if (data.length != 2) return null;
  final error = data[0] ?? 'Unknown isolate error';
  final stackString = data[1] as String? ?? '';
  return (error: error, stackTrace: StackTrace.fromString(stackString));
}

/// 用 [runZonedGuarded] 包裹应用入口，捕获 zone 内所有未处理异步异常。
///
/// 与 [PlatformDispatcher.instance.onError] 的关系：
/// - PlatformDispatcher 是 Flutter 引擎层的兜底
/// - runZonedGuarded 是 Dart zone 级别的捕获，更早一层
/// - 两者协作覆盖全部异步错误路径
void runAppGuarded(void Function() body, {ErrorReporter? reporter}) {
  final report = reporter ?? _defaultReporter;
  runZonedGuarded(body, report);
}
