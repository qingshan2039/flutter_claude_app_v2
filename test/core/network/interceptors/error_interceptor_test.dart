import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_mock_adapter.dart';

void main() {
  Dio buildDio(HttpClientAdapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(const ApiErrorInterceptor());
    return dio;
  }

  Future<DioException> captureError(Dio dio, String path) async {
    try {
      await dio.get<dynamic>(path);
      fail('Expected DioException to be thrown');
    } on DioException catch (e) {
      return e;
    }
  }

  test('5xx → ServerException with statusCode', () async {
    final adapter = MockAdapter((options, idx) => jsonResponse(503, {'msg': 'down'}));
    final dio = buildDio(adapter);

    final err = await captureError(dio, '/foo');
    expect(err.error, isA<ServerException>());
    final se = err.error! as ServerException;
    expect(se.statusCode, 503);
  });

  test('401 → UnauthorizedException', () async {
    final adapter = MockAdapter(
      (options, idx) => jsonResponse(401, {'msg': 'unauthorized'}),
    );
    final dio = buildDio(adapter);

    final err = await captureError(dio, '/foo');
    expect(err.error, isA<UnauthorizedException>());
  });

  test('connection error 类型 → NetworkException(code: CONNECTION)', () async {
    // 故意 fetch 抛 connection error
    final adapter = _ThrowingAdapter(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/foo'),
        reason: 'simulated',
      ),
    );
    final dio = buildDio(adapter);

    final err = await captureError(dio, '/foo');
    expect(err.error, isA<NetworkException>());
    expect((err.error! as NetworkException).code, 'CONNECTION');
  });

  test('业务 code != 0 → reject 为 ServerException', () async {
    final adapter = MockAdapter(
      (options, idx) => jsonResponse(200, {
        'code': 4001,
        'message': 'business error',
        'data': null,
      }),
    );
    final dio = buildDio(adapter);

    final err = await captureError(dio, '/foo');
    expect(err.error, isA<ServerException>());
    final se = err.error! as ServerException;
    expect(se.code, '4001');
    expect(se.message, 'business error');
  });

  test('业务 code == 0 → 正常返回', () async {
    final adapter = MockAdapter(
      (options, idx) => jsonResponse(200, {
        'code': 0,
        'message': 'ok',
        'data': {'x': 1},
      }),
    );
    final dio = buildDio(adapter);

    final r = await dio.get<dynamic>('/foo');
    expect(r.statusCode, 200);
    expect((r.data as Map)['code'], 0);
  });

  test('已附 AppException 的 DioException 透传不被覆盖', () async {
    const original = CacheException(message: 'preset');
    final adapter = _ThrowingAdapter(
      DioException(
        requestOptions: RequestOptions(path: '/foo'),
        error: original,
      ),
    );
    final dio = buildDio(adapter);

    final err = await captureError(dio, '/foo');
    expect(err.error, same(original));
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.exception);
  final DioException exception;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    throw exception;
  }

  @override
  void close({bool force = false}) {}
}
