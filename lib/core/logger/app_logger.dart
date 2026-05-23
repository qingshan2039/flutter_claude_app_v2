import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/logger/log_sanitizer.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

/// 应用日志门面（T11.1）。
///
/// 分级：t(trace/verbose) / d(debug) / i(info) / w(warning) / e(error)。
/// 业务只依赖本抽象，不直接 import logger 包，便于切换实现 / 测试。
///
/// 所有消息在输出前经 [LogSanitizer]（T11.3）脱敏。
abstract class AppLogger {
  void t(String message, {Object? error, StackTrace? stackTrace});
  void d(String message, {Object? error, StackTrace? stackTrace});
  void i(String message, {Object? error, StackTrace? stackTrace});
  void w(String message, {Object? error, StackTrace? stackTrace});
  void e(String message, {Object? error, StackTrace? stackTrace});
}

/// 基于 `logger` 包的实现。
///
/// dev/prod 策略：debug 构建输出 trace 及以上（全量）；release 构建只输出
/// warning 及以上（减少噪声 + 不泄露细节）。
@LazySingleton(as: AppLogger)
class LoggerImpl implements AppLogger {
  /// 生产构造（injectable 使用）。控制台输出 + 默认脱敏。
  LoggerImpl()
    : _logger = _buildDefaultLogger(),
      _sanitizer = const LogSanitizer();

  /// 测试构造：注入自定义 [Logger]（如带 MemoryOutput）与 [LogSanitizer]。
  @visibleForTesting
  LoggerImpl.withLogger(this._logger, {LogSanitizer? sanitizer})
    : _sanitizer = sanitizer ?? const LogSanitizer();

  final Logger _logger;
  final LogSanitizer _sanitizer;

  static Logger _buildDefaultLogger() {
    return Logger(
      level: kReleaseMode ? Level.warning : Level.trace,
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 100,
        colors: !kReleaseMode,
        printEmojis: !kReleaseMode,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  @override
  void t(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.t(_sanitizer.sanitize(message), error: error, stackTrace: stackTrace);

  @override
  void d(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(_sanitizer.sanitize(message), error: error, stackTrace: stackTrace);

  @override
  void i(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(_sanitizer.sanitize(message), error: error, stackTrace: stackTrace);

  @override
  void w(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(_sanitizer.sanitize(message), error: error, stackTrace: stackTrace);

  @override
  void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(_sanitizer.sanitize(message), error: error, stackTrace: stackTrace);
}
