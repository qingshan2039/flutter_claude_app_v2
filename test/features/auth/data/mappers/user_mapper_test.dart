import 'package:flutter_claude_app_v2/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserMapper', () {
    test('UserModel.toEntity 返回 User 类型', () {
      const model = UserModel(id: '1', name: 'Alice', email: 'a@b.com');
      final entity = model.toEntity();
      expect(entity, isA<User>());
      expect(entity, isNot(isA<UserModel>()));
    });

    test('UserModel.toEntity 字段值逐项保留', () {
      final model = UserModel(
        id: '1',
        name: 'Alice',
        email: 'a@b.com',
        createdAt: DateTime.utc(2026, 5, 18),
      );
      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.name, model.name);
      expect(entity.email, model.email);
      expect(entity.createdAt, model.createdAt);
    });

    test('User.toModel 返回 UserModel 类型', () {
      const entity = User(id: '1', name: 'A', email: 'a@b.com');
      final model = entity.toModel();
      expect(model, isA<UserModel>());
    });

    test('roundtrip: User → Model → User 保持 equals', () {
      final original = User(
        id: '1',
        name: 'Alice',
        email: 'a@b.com',
        createdAt: DateTime.utc(2026, 5, 18, 10),
      );
      final roundtrip = original.toModel().toEntity();
      expect(roundtrip, equals(original));
    });

    test('roundtrip: Model → User → Model 保持 equals', () {
      final original = UserModel(
        id: '1',
        name: 'Alice',
        email: 'a@b.com',
        createdAt: DateTime.utc(2026, 5, 18, 10),
      );
      final roundtrip = original.toEntity().toModel();
      expect(roundtrip, equals(original));
    });
  });
}
