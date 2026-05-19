import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException 基类', () {
    test('所有子类 implements Exception 接口', () {
      const exceptions = <Exception>[
        NetworkException(message: 'n'),
        ServerException(code: 'SRV', message: 's'),
        CacheException(message: 'c'),
        UnauthorizedException(),
        ValidationException(message: 'v'),
        UnknownException(message: 'u'),
      ];
      for (final e in exceptions) {
        expect(e, isA<Exception>());
        expect(e, isA<AppException>());
      }
    });
  });

  group('NetworkException', () {
    test('默认 code = NETWORK', () {
      const e = NetworkException(message: 'timeout');
      expect(e.code, 'NETWORK');
      expect(e.message, 'timeout');
    });

    test('toString 含类名/code/message', () {
      const e = NetworkException(message: 'timeout');
      final s = e.toString();
      expect(s, contains('NetworkException'));
      expect(s, contains('NETWORK'));
      expect(s, contains('timeout'));
    });
  });

  group('ServerException', () {
    test('携带 statusCode 与业务 code', () {
      const e = ServerException(
        code: 'USER_NOT_FOUND',
        message: 'No such user',
        statusCode: 404,
      );
      expect(e.code, 'USER_NOT_FOUND');
      expect(e.statusCode, 404);
      expect(e.toString(), contains('status: 404'));
    });
  });

  group('UnauthorizedException', () {
    test('默认 code = UNAUTHORIZED, message = Unauthorized', () {
      const e = UnauthorizedException();
      expect(e.code, 'UNAUTHORIZED');
      expect(e.message, 'Unauthorized');
    });
  });

  group('ValidationException', () {
    test('携带 field 字段并出现在 toString', () {
      const e = ValidationException(message: 'too short', field: 'password');
      expect(e.field, 'password');
      expect(e.toString(), contains('password'));
    });
  });

  group('cause / stackTrace 透传', () {
    test('cause 保留底层异常引用', () {
      final original = Exception('low-level');
      final e = NetworkException(message: 'wrapped', cause: original);
      expect(e.cause, same(original));
    });

    test('stackTrace 可注入', () {
      final stack = StackTrace.current;
      final e = CacheException(message: 'io', stackTrace: stack);
      expect(e.stackTrace, same(stack));
    });
  });
}
