import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Success / Failed 构造', () {
    test('Success 持有值', () {
      const r = Success<int>(42);
      expect(r.value, 42);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
    });

    test('Failed 持有 Failure', () {
      const f = NetworkFailure(message: 'lost');
      const r = Failed<int>(f);
      expect(r.failure, f);
      expect(r.isSuccess, isFalse);
      expect(r.isFailure, isTrue);
    });

    test('Success value equality', () {
      const a = Success<int>(1);
      const b = Success<int>(1);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('Failed value equality 基于内部 Failure', () {
      const a = Failed<int>(NetworkFailure(message: 'x'));
      const b = Failed<int>(NetworkFailure(message: 'x'));
      expect(a, equals(b));
    });

    test('toString 含 Success/Failed 标签', () {
      expect(const Success<int>(1).toString(), contains('Success'));
      expect(
        const Failed<int>(NetworkFailure()).toString(),
        contains('Failed'),
      );
    });
  });

  group('fold', () {
    test('Success 路径调用 onSuccess', () {
      const Result<int> r = Success(10);
      final out = r.fold((v) => 'ok-$v', (f) => 'err-${f.message}');
      expect(out, 'ok-10');
    });

    test('Failed 路径调用 onFailure', () {
      const Result<int> r = Failed(NetworkFailure(message: 'net'));
      final out = r.fold((v) => 'ok-$v', (f) => 'err-${f.message}');
      expect(out, 'err-net');
    });
  });

  group('map', () {
    test('Success 时变换值', () {
      const Result<int> r = Success(2);
      final r2 = r.map((v) => v * 10);
      expect(r2, isA<Success<int>>());
      expect((r2 as Success<int>).value, 20);
    });

    test('Failed 原样穿透', () {
      const Result<int> r = Failed(NetworkFailure(message: 'net'));
      final r2 = r.map((v) => v * 10);
      expect(r2, isA<Failed<int>>());
      expect((r2 as Failed<int>).failure, isA<NetworkFailure>());
    });

    test('类型可变（int → String）', () {
      const Result<int> r = Success(42);
      final r2 = r.map((v) => 'value=$v');
      expect((r2 as Success<String>).value, 'value=42');
    });
  });

  group('flatMap', () {
    Result<int> doubleIfPositive(int v) =>
        v > 0 ? Success<int>(v * 2) : const Failed(ValidationFailure(message: 'neg'));

    test('Success → 链式 Success', () {
      const Result<int> r = Success(3);
      final r2 = r.flatMap(doubleIfPositive);
      expect((r2 as Success<int>).value, 6);
    });

    test('Success → 链式 Failed', () {
      const Result<int> r = Success(-1);
      final r2 = r.flatMap(doubleIfPositive);
      expect(r2, isA<Failed<int>>());
      expect((r2 as Failed<int>).failure, isA<ValidationFailure>());
    });

    test('Failed → 跳过 transform 原样穿透', () {
      const Result<int> r = Failed(NetworkFailure());
      var called = false;
      final r2 = r.flatMap((v) {
        called = true;
        return Success(v);
      });
      expect(called, isFalse);
      expect(r2, isA<Failed<int>>());
    });
  });

  group('valueOrNull / failureOrNull', () {
    test('Success.valueOrNull 返回值，failureOrNull 返回 null', () {
      const Result<int> r = Success(7);
      expect(r.valueOrNull, 7);
      expect(r.failureOrNull, isNull);
    });

    test('Failed.valueOrNull 返回 null，failureOrNull 返回 Failure', () {
      const Result<int> r = Failed(NetworkFailure(message: 'x'));
      expect(r.valueOrNull, isNull);
      expect(r.failureOrNull, isA<NetworkFailure>());
    });
  });
}
