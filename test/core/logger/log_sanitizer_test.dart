import 'package:flutter_claude_app_v2/core/logger/log_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sanitizer = LogSanitizer();

  group('LogSanitizer 默认规则', () {
    test('JSON password 脱敏', () {
      final out = sanitizer.sanitize('{"password":"p@ssw0rd","name":"alice"}');
      expect(out, contains('"password":"***"'));
      expect(out, contains('"name":"alice"'));
    });

    test('token / access_token / secret 脱敏', () {
      expect(sanitizer.sanitize('token=abc123'), contains('token=***'));
      expect(
        sanitizer.sanitize('{"access_token":"xyz"}'),
        contains('"access_token":"***"'),
      );
      expect(sanitizer.sanitize('secret = mysecret'), contains('***'));
    });

    test('大小写不敏感（Password / TOKEN）', () {
      expect(sanitizer.sanitize('Password: "x"'), contains('***'));
      expect(sanitizer.sanitize('TOKEN=y'), contains('***'));
    });

    test('Bearer token 脱敏', () {
      final out = sanitizer.sanitize('Authorization: Bearer eyJhbGciOiJIUzI1');
      expect(out, contains('Bearer ***'));
      expect(out, isNot(contains('eyJhbGciOiJIUzI1')));
    });

    test('email 部分脱敏（保留首字母 + 域名）', () {
      final out = sanitizer.sanitize('user alice@example.com logged in');
      expect(out, contains('a***@example.com'));
      expect(out, isNot(contains('alice@example.com')));
    });

    test('手机号脱敏（保留前 3 后 2）', () {
      final out = sanitizer.sanitize('phone 13812345678 ok');
      expect(out, contains('138****78'));
      expect(out, isNot(contains('13812345678')));
    });

    test('无敏感信息原样返回', () {
      const msg = 'User navigated to home page';
      expect(sanitizer.sanitize(msg), msg);
    });
  });

  group('LogSanitizer 自定义规则', () {
    test('extraRules 追加生效', () {
      final custom = LogSanitizer(
        extraRules: <RedactionRule>[
          RedactionRule(
            pattern: RegExp(r'card-\d+'),
            replace: (_) => 'card-***',
          ),
        ],
      );
      expect(custom.sanitize('paid with card-12345'), contains('card-***'));
    });

    test('自定义规则与默认规则叠加', () {
      final custom = LogSanitizer(
        extraRules: <RedactionRule>[
          RedactionRule(pattern: RegExp(r'ssn-\d+'), replace: (_) => 'ssn-***'),
        ],
      );
      final out = custom.sanitize('{"password":"x"} ssn-999');
      expect(out, contains('***')); // password
      expect(out, contains('ssn-***')); // custom
    });
  });
}
