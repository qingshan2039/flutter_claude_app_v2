import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_claude_app_v2/core/network/dio_client.dart' show NetworkModule;

/// 应用日志拦截器（T04.2）。
///
/// 设计要点：
/// - 仅在 `kDebugMode` 输出（生产构建零开销）
/// - 自动脱敏 [sensitiveHeaders] 与 [sensitiveBodyKeys]，避免 token/password 落日志
/// - 通过构造参数注入额外脱敏字段，便于业务扩展
/// - 输出格式：单行 method+url + headers + body 多行；JSON body 时美化
///
/// M11/T11.4 完成后，可注入 `AppLogger`/Sentry breadcrumb 替代 [debugPrint]。
///
/// DI：本类不直接标注 `@lazySingleton`（构造参数 [enabled] 默认 `kDebugMode`，
/// 若让 injectable 自动注入会生成 `gh<bool>()` 解析一个未注册的 bool 而抛错）。
/// 改由 [NetworkModule.provideLoggingInterceptor] 用默认构造提供。
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.enabled = kDebugMode,
    Set<String>? extraSensitiveHeaders,
    Set<String>? extraSensitiveBodyKeys,
  }) : sensitiveHeaders = {
         'authorization',
         'cookie',
         'set-cookie',
         'x-api-key',
         ...?extraSensitiveHeaders,
       },
       sensitiveBodyKeys = {
         'password',
         'token',
         'access_token',
         'refresh_token',
         'secret',
         'apiKey',
         'api_key',
         ...?extraSensitiveBodyKeys,
       };

  final bool enabled;
  final Set<String> sensitiveHeaders;
  final Set<String> sensitiveBodyKeys;

  static const String _redacted = '***';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enabled) {
      _log('→ ${options.method} ${options.uri}');
      _logHeaders(options.headers);
      if (options.data != null) {
        _logBody('request body', options.data);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (enabled) {
      _log('← ${response.statusCode} ${response.requestOptions.uri}');
      if (response.data != null) {
        _logBody('response body', response.data);
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enabled) {
      _log('✗ ${err.type} ${err.requestOptions.uri}');
      _log('  message: ${err.message}');
      if (err.response?.data != null) {
        _logBody('error body', err.response!.data);
      }
    }
    handler.next(err);
  }

  void _log(String line) => debugPrint(line);

  void _logHeaders(Map<String, dynamic> headers) {
    for (final entry in headers.entries) {
      final value = sensitiveHeaders.contains(entry.key.toLowerCase())
          ? _redacted
          : entry.value;
      _log('  ${entry.key}: $value');
    }
  }

  void _logBody(String label, Object? body) {
    final sanitized = sanitizeBody(body);
    final pretty = _prettyJson(sanitized);
    _log('  $label:');
    for (final line in pretty.split('\n')) {
      _log('    $line');
    }
  }

  /// 对 body 做脱敏处理；公开以便单元测试。
  Object? sanitizeBody(Object? body) {
    if (body is Map) {
      final result = <String, dynamic>{};
      body.forEach((dynamic key, dynamic value) {
        final k = key.toString();
        if (sensitiveBodyKeys.contains(k)) {
          result[k] = _redacted;
        } else {
          result[k] = sanitizeBody(value);
        }
      });
      return result;
    }
    if (body is List) {
      return body.map(sanitizeBody).toList();
    }
    return body;
  }

  String _prettyJson(Object? obj) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(obj);
    } catch (_) {
      return obj.toString();
    }
  }
}
