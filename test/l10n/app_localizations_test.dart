import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// 用一个隐藏的 Builder 抓到 [AppLocalizations] 实例做断言。
Future<AppLocalizations> _loadL10n(WidgetTester tester, Locale locale) async {
  late AppLocalizations l10n;
  await tester.pumpWidget(
    Localizations(
      locale: locale,
      delegates: AppLocalizations.localizationsDelegates,
      child: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return l10n;
}

void main() {
  group('AppLocalizations — supportedLocales', () {
    test('支持 en 与 zh', () {
      final codes = AppLocalizations.supportedLocales
          .map((l) => l.languageCode)
          .toSet();
      expect(codes, containsAll(<String>['en', 'zh']));
    });
  });

  group('英文 (en) 文案', () {
    testWidgets('简单 key', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('en'));
      expect(l10n.appTitle, 'Flutter Claude App');
      expect(l10n.ok, 'OK');
      expect(l10n.errorNetwork, contains('Network error'));
    });

    testWidgets('占位符 greetingNamed', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('en'));
      expect(l10n.greetingNamed('Alice'), 'Hello, Alice!');
    });

    testWidgets('复数 itemCount: 0 / 1 / many', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('en'));
      expect(l10n.itemCount(0), 'No items');
      expect(l10n.itemCount(1), '1 item');
      expect(l10n.itemCount(5), '5 items');
    });

    testWidgets('日期格式化 lastUpdated', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('en'));
      final text = l10n.lastUpdated(DateTime.utc(2026, 5, 18));
      expect(text, contains('2026'));
      expect(text, contains('Last updated'));
    });

    testWidgets('货币格式化 priceLabel', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('en'));
      final text = l10n.priceLabel(19.99);
      expect(text, contains(r'$19.99'));
    });

    testWidgets('百分比格式化 completionRate', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('en'));
      final text = l10n.completionRate(0.87);
      expect(text, contains('87'));
      expect(text, contains('%'));
    });
  });

  group('中文 (zh) 文案', () {
    testWidgets('简单 key 翻译正确', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('zh'));
      expect(l10n.appTitle, 'Flutter Claude 应用');
      expect(l10n.ok, '确定');
      expect(l10n.errorNetwork, contains('网络异常'));
    });

    testWidgets('占位符与复数', (tester) async {
      final l10n = await _loadL10n(tester, const Locale('zh'));
      expect(l10n.greetingNamed('小明'), '你好，小明！');
      expect(l10n.itemCount(0), '没有条目');
      expect(l10n.itemCount(3), '3 个条目');
    });
  });
}
