import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/core/debug/network_inspector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkRecord (T29.4)', () {
    test('fromResponse 映射方法/URL/状态/耗时', () {
      final resp = Response<dynamic>(
        requestOptions: RequestOptions(
          path: '/users',
          baseUrl: 'https://api.test',
          method: 'GET',
        ),
        statusCode: 200,
        data: const {'ok': true},
      );
      final rec = NetworkRecord.fromResponse(resp, durationMs: 12);
      expect(rec.method, 'GET');
      expect(rec.url, 'https://api.test/users');
      expect(rec.statusCode, 200);
      expect(rec.durationMs, 12);
      expect(rec.isError, isFalse);
    });

    test('fromError 记录错误信息且 isError', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/x', method: 'POST'),
        message: 'boom',
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 500,
        ),
      );
      final rec = NetworkRecord.fromError(err);
      expect(rec.isError, isTrue);
      expect(rec.statusCode, 500);
      expect(rec.error, 'boom');
    });

    test('4xx 状态视为错误', () {
      final resp = Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 404,
      );
      expect(NetworkRecord.fromResponse(resp).isError, isTrue);
    });
  });

  group('NetworkInspector (T29.4)', () {
    NetworkRecord rec(String url) =>
        NetworkRecord(method: 'GET', url: url, time: DateTime.now());

    test('add + records 最新在前', () {
      final inspector = NetworkInspector()
        ..add(rec('/a'))
        ..add(rec('/b'));
      expect(inspector.records.map((r) => r.url), <String>['/b', '/a']);
    });

    test('环形缓冲：超出 capacity 丢弃最旧', () {
      final inspector = NetworkInspector()..capacity = 2;
      inspector
        ..add(rec('/1'))
        ..add(rec('/2'))
        ..add(rec('/3'));
      expect(inspector.length, 2);
      expect(inspector.records.map((r) => r.url), <String>['/3', '/2']);
    });

    test('clear', () {
      final inspector = NetworkInspector()..add(rec('/a'));
      inspector.clear();
      expect(inspector.length, 0);
    });
  });
}
