import 'dart:io';

import 'package:flutter_claude_app_v2/core/error/error_mapper.dart';
import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = ErrorMapper();

  group('ErrorMapper.map: AppException 子类', () {
    test('NetworkException → NetworkFailure', () {
      const e = NetworkException(message: 'timeout');
      final f = mapper.map(e);
      expect(f, isA<NetworkFailure>());
      expect((f as NetworkFailure).message, 'timeout');
    });

    test('ServerException → ServerFailure（保留 statusCode 与 code）', () {
      const e = ServerException(
        code: 'USER_NOT_FOUND',
        message: 'no user',
        statusCode: 404,
      );
      final f = mapper.map(e);
      expect(f, isA<ServerFailure>());
      f as ServerFailure;
      expect(f.statusCode, 404);
      expect(f.code, 'USER_NOT_FOUND');
      expect(f.message, 'no user');
    });

    test('CacheException → CacheFailure', () {
      const e = CacheException(message: 'disk full');
      final f = mapper.map(e);
      expect(f, isA<CacheFailure>());
      expect((f as CacheFailure).message, 'disk full');
    });

    test('UnauthorizedException → UnauthorizedFailure', () {
      const e = UnauthorizedException();
      final f = mapper.map(e);
      expect(f, isA<UnauthorizedFailure>());
    });

    test('ValidationException → ValidationFailure（保留 field）', () {
      const e = ValidationException(message: 'too short', field: 'password');
      final f = mapper.map(e);
      expect(f, isA<ValidationFailure>());
      expect((f as ValidationFailure).field, 'password');
    });

    test('UnknownException → UnknownFailure', () {
      const e = UnknownException(message: 'mystery');
      final f = mapper.map(e);
      expect(f, isA<UnknownFailure>());
      expect((f as UnknownFailure).message, 'mystery');
    });
  });

  group('ErrorMapper.map: dart:io 标准异常', () {
    test('SocketException → NetworkFailure', () {
      const e = SocketException('connection refused');
      final f = mapper.map(e);
      expect(f, isA<NetworkFailure>());
      expect((f as NetworkFailure).message, 'connection refused');
    });

    test('SocketException with empty message → 兜底 message', () {
      const e = SocketException('');
      final f = mapper.map(e);
      expect(f, isA<NetworkFailure>());
      expect((f as NetworkFailure).message, 'Network unreachable');
    });

    test('HttpException → NetworkFailure', () {
      const e = HttpException('bad gateway');
      final f = mapper.map(e);
      expect(f, isA<NetworkFailure>());
      expect((f as NetworkFailure).message, 'bad gateway');
    });

    test('FormatException → ValidationFailure', () {
      const e = FormatException('invalid json');
      final f = mapper.map(e);
      expect(f, isA<ValidationFailure>());
      expect((f as ValidationFailure).message, 'invalid json');
    });
  });

  group('ErrorMapper.map: 兜底', () {
    test('未识别 Object → UnknownFailure（toString）', () {
      final f = mapper.map('plain string error');
      expect(f, isA<UnknownFailure>());
      expect((f as UnknownFailure).message, contains('plain string error'));
    });

    test('未识别 Exception → UnknownFailure', () {
      final f = mapper.map(Exception('mystery'));
      expect(f, isA<UnknownFailure>());
    });
  });
}
