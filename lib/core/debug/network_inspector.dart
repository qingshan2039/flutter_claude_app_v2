import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// 一条网络请求记录（T29.4）。
@immutable
class NetworkRecord {
  const NetworkRecord({
    required this.method,
    required this.url,
    required this.time,
    this.statusCode,
    this.durationMs,
    this.requestBody,
    this.responseBody,
    this.error,
  });

  factory NetworkRecord.fromResponse(Response<dynamic> response, {int? durationMs}) {
    final req = response.requestOptions;
    return NetworkRecord(
      method: req.method,
      url: req.uri.toString(),
      time: DateTime.now(),
      statusCode: response.statusCode,
      durationMs: durationMs,
      requestBody: _stringify(req.data),
      responseBody: _stringify(response.data),
    );
  }

  factory NetworkRecord.fromError(DioException error, {int? durationMs}) {
    final req = error.requestOptions;
    return NetworkRecord(
      method: req.method,
      url: req.uri.toString(),
      time: DateTime.now(),
      statusCode: error.response?.statusCode,
      durationMs: durationMs,
      requestBody: _stringify(req.data),
      responseBody: _stringify(error.response?.data),
      error: error.message,
    );
  }

  final String method;
  final String url;
  final DateTime time;
  final int? statusCode;
  final int? durationMs;
  final String? requestBody;
  final String? responseBody;
  final String? error;

  bool get isError => error != null || (statusCode != null && statusCode! >= 400);

  static String? _stringify(Object? data) {
    if (data == null) return null;
    final s = data.toString();
    return s.length > 2000 ? '${s.substring(0, 2000)}…' : s;
  }
}

/// 网络抓包缓冲（T29.4）：环形保存最近请求，供 Debug 面板查看。
@lazySingleton
class NetworkInspector {
  NetworkInspector();

  int capacity = 100;

  final List<NetworkRecord> _records = <NetworkRecord>[];

  /// 最新在前。
  List<NetworkRecord> get records =>
      List<NetworkRecord>.unmodifiable(_records.reversed);

  int get length => _records.length;

  void add(NetworkRecord record) {
    _records.add(record);
    while (_records.length > capacity) {
      _records.removeAt(0);
    }
  }

  void clear() => _records.clear();
}

/// 把请求/响应记入 [NetworkInspector] 的 Dio 拦截器（T29.4）。
///
/// 接入：`dio.interceptors.add(NetworkInspectorInterceptor(getIt<NetworkInspector>()))`。
class NetworkInspectorInterceptor extends Interceptor {
  NetworkInspectorInterceptor(this._inspector);

  final NetworkInspector _inspector;

  static const String _startKey = 'network_inspector.start';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  int? _elapsed(RequestOptions options) {
    final start = options.extra[_startKey];
    if (start is! int) return null;
    return DateTime.now().millisecondsSinceEpoch - start;
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _inspector.add(
      NetworkRecord.fromResponse(
        response,
        durationMs: _elapsed(response.requestOptions),
      ),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _inspector.add(
      NetworkRecord.fromError(err, durationMs: _elapsed(err.requestOptions)),
    );
    handler.next(err);
  }
}
