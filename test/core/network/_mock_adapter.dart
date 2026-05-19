import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 测试用 Dio HttpClientAdapter：
/// - 记录所有 fetch 调用的 [requests]
/// - 由 [responseBuilder] 决定每次返回的响应（按调用顺序）
class MockAdapter implements HttpClientAdapter {
  MockAdapter(this.responseBuilder);

  final ResponseBody Function(RequestOptions options, int callIndex)
  responseBuilder;
  final List<RequestOptions> requests = <RequestOptions>[];

  int get callCount => requests.length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final index = requests.length;
    requests.add(options);
    return responseBuilder(options, index);
  }

  @override
  void close({bool force = false}) {}
}

/// 便捷构造一个 JSON ResponseBody。
ResponseBody jsonResponse(int statusCode, Object body) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    statusCode,
    headers: <String, List<String>>{
      'content-type': <String>['application/json'],
    },
  );
}
