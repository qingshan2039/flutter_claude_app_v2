---
doc_type: extend_guide
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
status: in_progress
note: "本文件由 T08.6 创建（含「新增语言」章节）。T20.5 会补全新增 feature / 权限 / 环境等章节。"
tags: [guide, extend, i18n, localization, T08, M08]
---

# 扩展指南（EXTEND_GUIDE）

> 本文档说明如何在模板基础上扩展常见能力。当前包含「新增语言」章节（T08.6）；
> 「新增 feature / 新增权限 / 新增环境」章节由 T20.5 补全。

## 目录

- [新增语言（i18n）](#新增语言i18n)
- 新增 feature _(T20.5)_
- 新增权限 _(T20.5)_
- 新增环境 _(T20.5)_

---

## 新增语言（i18n）

模板的国际化基于 `flutter_localizations` + `intl` + `flutter gen-l10n`（M08）。
ARB 文件在 `lib/l10n/`，生成的强类型 `AppLocalizations` 也在 `lib/l10n/`。

以新增**日语（ja）**为例，4 步完成：

### 第 1 步：新建 ARB 文件

复制模板 ARB `lib/l10n/app_en.arb` 为 `lib/l10n/app_ja.arb`，把 `@@locale` 改为 `ja`，
翻译所有 value。**只需 `@@locale` + 各 key 的翻译**，不需要重复 `@key` 元数据
（元数据只在 template-arb-file `app_en.arb` 中维护）。

```json
{
  "@@locale": "ja",
  "appTitle": "Flutter Claude アプリ",
  "ok": "OK",
  "cancel": "キャンセル",
  "greetingNamed": "こんにちは、{name}さん！",
  "itemCount": "{count, plural, =0{項目なし} other{{count} 件}}",
  "...": "（其余 key 同样翻译）"
}
```

> **复数（plural）注意**：不同语言的复数类别不同。英语有 `one` / `other`，
> 中文/日语只有 `other`，阿拉伯语有 6 类。按目标语言的 CLDR 规则写 `plural` 分支。

### 第 2 步：在支持列表中登记

编辑 [lib/core/i18n/locale_provider.dart](../lib/core/i18n/locale_provider.dart) 的 `kSupportedLocales`：

```dart
const List<Locale> kSupportedLocales = <Locale>[
  Locale('en'),
  Locale('zh'),
  Locale('ja'),   // ← 新增
];
```

如果在设置页有语言选择 UI，也要加一个 `languageJapanese` key 到所有 ARB，并在
选择列表中加一项。

### 第 3 步：重新生成

```bash
flutter gen-l10n
# 或 flutter pub get（generate: true 会自动触发）
```

会重新生成 `lib/l10n/app_localizations.dart` + `app_localizations_ja.dart`。

### 第 4 步：验证

```bash
flutter analyze        # 确认没有缺失的 key（缺 key 会编译报错）
flutter test           # 跑 i18n 测试
flutter run            # 在设置页切到日语，确认即时生效
```

### 缺失 key 怎么办

如果某个 ARB 漏译某 key，`flutter gen-l10n` 默认会**回退到 template 语言（en）**，
不会崩溃。要强制完整翻译，可在 `l10n.yaml` 加 `untranslated-messages-file: l10n_missing.txt`，
生成后检查该文件列出的缺失项。

### 运行时切换 + 持久化（已内置）

切换语言（M08/T08.4-T08.5 已实现）：

```dart
// 切到中文
ref.read(localeProvider.notifier).setLocale(const Locale('zh'));
// 恢复跟随系统
ref.read(localeProvider.notifier).useSystemLocale();
```

选择会自动写入 `KeyValueStorage`（key: `app.locale`），下次启动读取。首次启动
（无持久化值）返回 `null` = 跟随系统语言。

### 文案使用方式

```dart
final l10n = AppLocalizations.of(context);
Text(l10n.appTitle);                          // 简单 key
Text(l10n.greetingNamed('Alice'));            // 占位符
Text(l10n.itemCount(3));                      // 复数
Text(l10n.lastUpdated(DateTime.now()));       // 日期格式化
Text(l10n.priceLabel(19.99));                 // 货币格式化
```
