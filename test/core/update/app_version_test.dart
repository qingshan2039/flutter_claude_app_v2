import 'package:flutter_claude_app_v2/core/update/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

/// T23.1：语义化版本号解析与比较。
void main() {
  group('AppVersion.parse (T23.1)', () {
    test('标准 major.minor.patch', () {
      final v = AppVersion.parse('1.2.3');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.build, isNull);
    });

    test('带前导 v 与 build', () {
      final v = AppVersion.parse('v2.0.0+15');
      expect(v.major, 2);
      expect(v.build, 15);
      expect(v.toString(), '2.0.0+15');
    });

    test('宽松：缺省段/非法段按 0', () {
      expect(AppVersion.parse('1').toString(), '1.0.0');
      expect(AppVersion.parse('1.x.2').minor, 0);
      expect(AppVersion.parse('').toString(), '0.0.0');
    });
  });

  group('AppVersion 比较 (T23.1)', () {
    test('按数值比较（非字典序）：1.9.0 < 1.10.0', () {
      expect(AppVersion.parse('1.9.0') < AppVersion.parse('1.10.0'), isTrue);
    });

    test('major > minor > patch > build 优先级', () {
      expect(AppVersion.parse('2.0.0') > AppVersion.parse('1.9.9'), isTrue);
      expect(AppVersion.parse('1.2.0') > AppVersion.parse('1.1.9'), isTrue);
      expect(AppVersion.parse('1.1.2') > AppVersion.parse('1.1.1'), isTrue);
      expect(
        AppVersion.parse('1.1.1+2') > AppVersion.parse('1.1.1+1'),
        isTrue,
      );
    });

    test('相等与 >= / <=', () {
      expect(AppVersion.parse('1.0.0') == AppVersion.parse('1.0.0'), isTrue);
      expect(AppVersion.parse('1.0.0') >= AppVersion.parse('1.0.0'), isTrue);
      expect(AppVersion.parse('1.0.0') <= AppVersion.parse('1.0.0'), isTrue);
    });

    test('build 缺省视为 0：1.0.0 == 1.0.0+0', () {
      expect(AppVersion.parse('1.0.0') == AppVersion.parse('1.0.0+0'), isTrue);
    });

    test('可用于排序', () {
      final list = <AppVersion>[
        AppVersion.parse('1.2.0'),
        AppVersion.parse('1.0.0'),
        AppVersion.parse('1.10.0'),
      ]..sort();
      expect(list.map((v) => v.toString()), <String>['1.0.0', '1.2.0', '1.10.0']);
    });
  });
}
