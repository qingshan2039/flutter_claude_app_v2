import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User entity (freezed)', () {
    test('两个字段相同的实例 equals 为 true', () {
      const a = User(id: '1', name: 'Alice', email: 'alice@example.com');
      const b = User(id: '1', name: 'Alice', email: 'alice@example.com');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('字段不同 equals 为 false', () {
      const a = User(id: '1', name: 'Alice', email: 'alice@example.com');
      const b = User(id: '2', name: 'Alice', email: 'alice@example.com');
      expect(a, isNot(equals(b)));
    });

    test('copyWith 改字段返回新实例，未改字段保留', () {
      const original = User(id: '1', name: 'Alice', email: 'alice@example.com');
      final renamed = original.copyWith(name: 'Alicia');
      expect(renamed.name, 'Alicia');
      expect(renamed.id, original.id);
      expect(renamed.email, original.email);
      expect(identical(renamed, original), isFalse);
    });

    test('createdAt 为 null 时不影响 equals', () {
      const a = User(id: '1', name: 'A', email: 'a@b.com');
      const b = User(id: '1', name: 'A', email: 'a@b.com');
      expect(a.createdAt, isNull);
      expect(a, equals(b));
    });
  });
}
