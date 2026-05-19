import 'package:flutter_claude_app_v2/core/network/interceptors/log_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggingInterceptor.sanitizeBody', () {
    final interceptor = LoggingInterceptor();

    test('替换 password / token 等敏感字段为 ***', () {
      final result = interceptor.sanitizeBody(<String, dynamic>{
        'username': 'alice',
        'password': 'p@ssw0rd',
        'token': 'jwt.abc',
      });
      expect(result, <String, dynamic>{
        'username': 'alice',
        'password': '***',
        'token': '***',
      });
    });

    test('嵌套对象内的敏感字段也被脱敏', () {
      final result = interceptor.sanitizeBody(<String, dynamic>{
        'user': <String, dynamic>{
          'name': 'alice',
          'secret': 'shh',
        },
      });
      expect(result, <String, dynamic>{
        'user': <String, dynamic>{
          'name': 'alice',
          'secret': '***',
        },
      });
    });

    test('List 中元素递归脱敏', () {
      final result = interceptor.sanitizeBody(<dynamic>[
        <String, dynamic>{'token': 't1', 'id': 1},
        <String, dynamic>{'token': 't2', 'id': 2},
      ]);
      expect(result, <dynamic>[
        <String, dynamic>{'token': '***', 'id': 1},
        <String, dynamic>{'token': '***', 'id': 2},
      ]);
    });

    test('原始 String / 数字 / null 不被处理', () {
      expect(interceptor.sanitizeBody('plain'), 'plain');
      expect(interceptor.sanitizeBody(42), 42);
      expect(interceptor.sanitizeBody(null), isNull);
    });

    test('自定义敏感字段也被脱敏', () {
      final custom = LoggingInterceptor(
        extraSensitiveBodyKeys: {'creditCard'},
      );
      final result = custom.sanitizeBody(<String, dynamic>{
        'creditCard': '4111-1111-1111-1111',
        'name': 'alice',
      });
      expect((result! as Map)['creditCard'], '***');
      expect((result as Map)['name'], 'alice');
    });
  });
}
