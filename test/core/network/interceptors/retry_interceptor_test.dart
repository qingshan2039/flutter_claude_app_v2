import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/retry_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_mock_adapter.dart';

void main() {
  group('shouldRetry 分类', () {
    final interceptor = RetryInterceptor();

    DioException make(DioExceptionType type, {int? status}) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: type,
      response: status == null
          ? null
          : Response<dynamic>(
              requestOptions: RequestOptions(path: '/x'),
              statusCode: status,
            ),
    );

    test('connectionTimeout / receiveTimeout / sendTimeout → 重试', () {
      expect(interceptor.shouldRetry(make(DioExceptionType.connectionTimeout)), isTrue);
      expect(interceptor.shouldRetry(make(DioExceptionType.receiveTimeout)), isTrue);
      expect(interceptor.shouldRetry(make(DioExceptionType.sendTimeout)), isTrue);
    });

    test('connectionError → 重试', () {
      expect(interceptor.shouldRetry(make(DioExceptionType.connectionError)), isTrue);
    });

    test('badResponse 5xx → 重试', () {
      expect(interceptor.shouldRetry(make(DioExceptionType.badResponse, status: 500)), isTrue);
      expect(interceptor.shouldRetry(make(DioExceptionType.badResponse, status: 503)), isTrue);
    });

    test('badResponse 4xx → 不重试', () {
      expect(interceptor.shouldRetry(make(DioExceptionType.badResponse, status: 400)), isFalse);
      expect(interceptor.shouldRetry(make(DioExceptionType.badResponse, status: 404)), isFalse);
    });

    test('cancel / badCertificate / unknown → 不重试', () {
      expect(interceptor.shouldRetry(make(DioExceptionType.cancel)), isFalse);
      expect(interceptor.shouldRetry(make(DioExceptionType.badCertificate)), isFalse);
      expect(interceptor.shouldRetry(make(DioExceptionType.unknown)), isFalse);
    });
  });

  group('computeBackoff 指数增长', () {
    test('attempt 越大延迟越大', () {
      final interceptor = RetryInterceptor(baseDelay: const Duration(milliseconds: 100))
        ..random = Random(0); // 固定种子
      final d0 = interceptor.computeBackoff(0);
      final d1 = interceptor.computeBackoff(1);
      final d2 = interceptor.computeBackoff(2);
      // base*1 vs base*2 vs base*4，加抖动后仍递增（极小概率反序，固定 seed 保证可重复）
      expect(d1 >= d0, isTrue);
      expect(d2 >= d1, isTrue);
      expect(d0.inMilliseconds >= 100, isTrue);   // 100 + jitter
    });
  });

  group('实际重试流程', () {
    test('5xx → 重试一次后 200 成功', () async {
      final adapter = MockAdapter((options, idx) {
        if (idx == 0) return jsonResponse(503, {'err': 'down'});
        return jsonResponse(200, {'ok': true});
      });

      final retry = RetryInterceptor(
        maxRetries: 3,
        baseDelay: const Duration(milliseconds: 1),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(retry);
      retry.dio = dio;

      final r = await dio.get<dynamic>('/foo');
      expect(r.statusCode, 200);
      expect(adapter.callCount, 2);
    });

    test('持续 503 → 重试到 maxRetries 后放弃', () async {
      final adapter = MockAdapter((options, idx) => jsonResponse(503, {}));

      final retry = RetryInterceptor(
        maxRetries: 2,
        baseDelay: const Duration(milliseconds: 1),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(retry);
      retry.dio = dio;

      await expectLater(
        dio.get<dynamic>('/foo'),
        throwsA(isA<DioException>()),
      );
      // 1 初始 + 2 重试
      expect(adapter.callCount, 3);
    });

    test('4xx → 不重试', () async {
      final adapter = MockAdapter((options, idx) => jsonResponse(400, {}));

      final retry = RetryInterceptor(
        maxRetries: 3,
        baseDelay: const Duration(milliseconds: 1),
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
        ..httpClientAdapter = adapter
        ..interceptors.add(retry);
      retry.dio = dio;

      await expectLater(
        dio.get<dynamic>('/foo'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.callCount, 1);
    });
  });
}
