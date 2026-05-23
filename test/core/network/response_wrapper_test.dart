import 'package:flutter_claude_app_v2/core/network/response_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse', () {
    test('isSuccess: code == 0', () {
      const r = ApiResponse<String>(code: 0, message: 'ok');
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
    });

    test('isFailure: code != 0', () {
      const r = ApiResponse<String>(code: 1001, message: 'oops');
      expect(r.isSuccess, isFalse);
      expect(r.isFailure, isTrue);
    });

    test('fromJson 解析基础字段', () {
      final json = <String, dynamic>{
        'code': 0,
        'message': 'ok',
        'data': 'hello',
      };
      final r = ApiResponse<String>.fromJson(json, (d) => d! as String);
      expect(r.code, 0);
      expect(r.message, 'ok');
      expect(r.data, 'hello');
    });

    test('fromJson 对 data 应用 fromJsonT', () {
      final json = <String, dynamic>{
        'code': 0,
        'data': <String, dynamic>{'id': 1, 'name': 'A'},
      };
      final r = ApiResponse<_Foo>.fromJson(
        json,
        (d) => _Foo.fromJson(d! as Map<String, dynamic>),
      );
      expect(r.data, isA<_Foo>());
      expect(r.data!.id, 1);
      expect(r.data!.name, 'A');
    });

    test('fromJson 容忍 data 为 null', () {
      final json = <String, dynamic>{'code': 0, 'data': null};
      final r = ApiResponse<String>.fromJson(json, (d) => d! as String);
      expect(r.data, isNull);
    });
  });
}

class _Foo {
  _Foo({required this.id, required this.name});
  factory _Foo.fromJson(Map<String, dynamic> json) =>
      _Foo(id: json['id'] as int, name: json['name'] as String);
  final int id;
  final String name;
}
