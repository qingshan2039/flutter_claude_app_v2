import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure (freezed sealed)', () {
    test('六个变体可分别构造', () {
      const variants = <Failure>[
        NetworkFailure(),
        ServerFailure(message: 'oops'),
        CacheFailure(),
        UnauthorizedFailure(),
        ValidationFailure(message: 'bad'),
        UnknownFailure(),
      ];
      expect(variants.length, 6);
    });

    test('value equality（同字段 → 相等）', () {
      const a = NetworkFailure(message: 'lost');
      const b = NetworkFailure(message: 'lost');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('不同变体 → 不相等', () {
      const a = NetworkFailure(message: 'x');
      const b = CacheFailure(message: 'x');
      expect(a, isNot(equals(b)));
    });

    test('NetworkFailure 默认 message', () {
      const f = NetworkFailure();
      expect(f.message, 'Network error');
    });

    test('ServerFailure 保留 statusCode 与业务 code', () {
      const f = ServerFailure(
        message: 'not found',
        statusCode: 404,
        code: 'USER_NOT_FOUND',
      );
      expect(f.statusCode, 404);
      expect(f.code, 'USER_NOT_FOUND');
      expect(f.message, 'not found');
    });

    test('ValidationFailure 保留 field', () {
      const f = ValidationFailure(message: 'too short', field: 'password');
      expect(f.field, 'password');
    });

    test('switch 模式匹配穷尽（sealed 强制）', () {
      String describe(Failure f) => switch (f) {
        NetworkFailure() => 'network',
        ServerFailure(:final statusCode) => 'server-$statusCode',
        CacheFailure() => 'cache',
        UnauthorizedFailure() => 'unauthorized',
        ValidationFailure(:final field) => 'validation-$field',
        UnknownFailure() => 'unknown',
      };

      expect(describe(const NetworkFailure()), 'network');
      expect(describe(const ServerFailure(message: 'x', statusCode: 500)),
          'server-500');
      expect(describe(const UnauthorizedFailure()), 'unauthorized');
      expect(
        describe(const ValidationFailure(message: 'm', field: 'email')),
        'validation-email',
      );
      expect(describe(const UnknownFailure()), 'unknown');
    });

    test('copyWith 改字段返回新实例（freezed 通用能力）', () {
      const f = NetworkFailure(message: 'a');
      final f2 = f.copyWith(message: 'b');
      expect(f2.message, 'b');
      expect(f.message, 'a'); // 原始不变
    });
  });
}
