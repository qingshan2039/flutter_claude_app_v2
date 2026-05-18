import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel (freezed + json_serializable)', () {
    test('fromJson 解析后端 snake_case → 模型 camelCase', () {
      final json = <String, dynamic>{
        'id': '1',
        'name': 'Alice',
        'email': 'alice@example.com',
        'created_at': '2026-05-18T10:00:00.000Z',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, '1');
      expect(model.name, 'Alice');
      expect(model.email, 'alice@example.com');
      expect(model.createdAt, DateTime.parse('2026-05-18T10:00:00.000Z'));
    });

    test('createdAt 缺失时容忍 null', () {
      final json = <String, dynamic>{
        'id': '1',
        'name': 'Alice',
        'email': 'alice@example.com',
      };

      final model = UserModel.fromJson(json);

      expect(model.createdAt, isNull);
    });

    test('toJson 输出 snake_case 字段名（与后端协议一致）', () {
      final model = UserModel(
        id: '1',
        name: 'Alice',
        email: 'alice@example.com',
        createdAt: DateTime.utc(2026, 5, 18, 10),
      );

      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Alice');
      expect(json['email'], 'alice@example.com');
      expect(json.containsKey('created_at'), isTrue);
      expect(json.containsKey('createdAt'), isFalse);
    });

    test('JSON 往返一致（fromJson → toJson）', () {
      final original = <String, dynamic>{
        'id': '1',
        'name': 'Alice',
        'email': 'alice@example.com',
        'created_at': '2026-05-18T10:00:00.000Z',
      };

      final model = UserModel.fromJson(original);
      final roundtrip = model.toJson();

      expect(roundtrip['id'], original['id']);
      expect(roundtrip['name'], original['name']);
      expect(roundtrip['email'], original['email']);
      expect(
        DateTime.parse(roundtrip['created_at']! as String),
        DateTime.parse(original['created_at']! as String),
      );
    });

    test('同字段值的 UserModel 相等（freezed value equality）', () {
      const a = UserModel(id: '1', name: 'A', email: 'a@b.com');
      const b = UserModel(id: '1', name: 'A', email: 'a@b.com');
      expect(a, equals(b));
    });
  });
}
