import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/i18n/locale_provider.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_claude_app_v2/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// M08 国际化 — 可视化演示（实时切换语言）。
class I18nDemoPage extends ConsumerWidget {
  const I18nDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return DemoScaffold(
      title: '国际化',
      moduleId: 'M08',
      children: <Widget>[
        DemoSection(
          title: '运行时切换语言',
          description: '点按钮立即切换，整个 App 文本随之更新（含本页）',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'en', label: Text('English')),
                  ButtonSegment<String>(value: 'zh', label: Text('简体中文')),
                  ButtonSegment<String>(value: 'system', label: Text('系统')),
                ],
                selected: <String>{currentLocale?.languageCode ?? 'system'},
                onSelectionChanged: (sel) {
                  final v = sel.first;
                  final notifier = ref.read(localeProvider.notifier);
                  if (v == 'system') {
                    notifier.useSystemLocale();
                  } else {
                    notifier.setLocale(Locale(v));
                  }
                },
              ),
              const SizedBox(height: 8),
              DemoResultRow('当前 locale', currentLocale?.toString() ?? '跟随系统'),
            ],
          ),
        ),
        DemoSection(
          title: '简单文案',
          description: '随语言切换',
          child: Column(
            children: <Widget>[
              DemoResultRow('appTitle', l10n.appTitle),
              DemoResultRow('ok / cancel', '${l10n.ok} / ${l10n.cancel}'),
              DemoResultRow('errorNetwork', l10n.errorNetwork),
            ],
          ),
        ),
        DemoSection(
          title: '复杂场景（占位符 / 复数 / 日期 / 货币）',
          child: Column(
            children: <Widget>[
              DemoResultRow('greeting(Alice)', l10n.greetingNamed('Alice')),
              DemoResultRow('itemCount(0)', l10n.itemCount(0)),
              DemoResultRow('itemCount(5)', l10n.itemCount(5)),
              DemoResultRow('lastUpdated', l10n.lastUpdated(DateTime(2026, 5, 18))),
              DemoResultRow('priceLabel(19.99)', l10n.priceLabel(19.99)),
              DemoResultRow('completionRate(0.87)', l10n.completionRate(0.87)),
            ],
          ),
        ),
      ],
    );
  }
}
