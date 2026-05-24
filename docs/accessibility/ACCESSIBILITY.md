---
doc_type: accessibility_guide
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T22.1
module_id: M22
status: completed
audience: [human_developers, ai_agents]
tags: [accessibility, a11y, semantics, wcag, tap-target, focus, contrast, M22, T22.1]
---

# 无障碍规范（ACCESSIBILITY）

> 让 App 对屏幕阅读器、键盘、低视力用户可用。本文是 M22 无障碍的总规范。
> 配套：[屏幕阅读器测试清单](SCREEN_READER_CHECKLIST.md) · [响应式/字体缩放](../responsive/RESPONSIVE.md)。

## 1. 为什么做无障碍

- **覆盖更多用户**：视障/老花/运动障碍用户，以及临时场景（强光下、单手操作）。
- **合规**：上架与企业采购常要求满足 WCAG 2.1 AA。
- **质量副产物**：语义清晰、对比度达标、焦点有序的 UI，对所有人都更好用。

四条主线：**语义（Semantics）**、**对比度（Contrast）**、**点击区域（Tap Target）**、**焦点（Focus）**。

## 2. Semantics 规范（T22.1）

Flutter 把 Widget 树映射成语义树供 TalkBack/VoiceOver 读取。多数 Material 组件（Text/按钮/输入框）**自带语义**，无需手动加。需要手动处理的是：

### 2.1 必须加语义的场景

| 场景 | 做法 |
|---|---|
| 纯图标可点元素（无文字） | `IconButton(tooltip: '收藏')` 或 [`MinTapTarget(semanticLabel: ...)`](../../lib/shared/widgets/min_tap_target.dart) |
| 有意义的图片 | `AppImage(url, semanticLabel: '产品封面')`（装饰图不加，避免噪音） |
| 自绘 / GestureDetector 控件 | `Semantics(button: true, label: '...', child: ...)` |
| 一组拆散的信息要连读 | `MergeSemantics`（如「★ 4.8 分」合并成一句） |
| 纯装饰、重复朗读的元素 | `ExcludeSemantics` / `Semantics(excludeSemantics: true)` |
| 动态变化要播报 | `Semantics(liveRegion: true, ...)`（如表单错误、加载结果） |

### 2.2 语义标签规范

- **标签是「读给人听的话」**，不是技术名：用「返回」而非 `back_btn`；用「删除张三的评论」而非「删除」。
- **不要在 label 里写控件类型**：别写「收藏按钮」，`button: true` 已让阅读器念「按钮」，否则会重复成「收藏按钮 按钮」。
- **状态用语义属性**而非拼进 label：选中用 `selected: true`、开关用 `toggled`、禁用用 `enabled: false`。
- **图片** `image: true` + 描述性 label；纯装饰图**不加** label（让阅读器跳过）。
- **标题** 用 `header: true` 帮助阅读器按标题跳读。
- 文案随 i18n 走（M08），label 也应来自 `AppLocalizations`，不要硬编码中文。

### 2.3 本项目已内置的无障碍组件

| 组件 | 无障碍能力 |
|---|---|
| [`MinTapTarget`](../../lib/shared/widgets/min_tap_target.dart) | ≥48×48 命中区 + `button`/label 语义（T22.3） |
| [`AppImage`](../../lib/shared/widgets/app_image.dart) | `semanticLabel` → `Semantics(image: true, ...)`（T22.1） |
| [`WcagContrast`](../../lib/core/theme/a11y/wcag_contrast.dart) | 运行时/测试期对比度校验（T22.2） |
| [`FocusManagementPage`](../../lib/features/examples/a11y/focus_management_page.dart) | 焦点顺序与手动聚焦示例（T22.5） |

## 3. 颜色对比度（T22.2）

正文文字与背景对比度须满足 **WCAG AA**：普通文字 ≥ **4.5:1**，大文字（≥18pt 或 14pt 粗）≥ **3:1**。

- 用 [`WcagContrast`](../../lib/core/theme/a11y/wcag_contrast.dart) 计算/校验：`WcagContrast.meetsAA(foreground: fg, background: bg)`。
- 业务语义色（success/warning/info）已由单测验证达 AA（见 [对比度报告 T22.2](../verification/T22.2.md)）：success 5.13:1、warning 7.93:1、info 4.80:1。
- M3 `ColorScheme.fromSeed` 生成的角色对（primary/onPrimary 等）天然满足对比度——优先用配对的 `on*` 颜色。
- **不要只靠颜色传递信息**（如只用红/绿区分对错），要叠加图标/文字。

## 4. 最小点击区域（T22.3）

可交互元素命中区 ≥ **48×48 dp**（Material / WCAG 2.5.5）。

- Material 按钮（IconButton/TextButton…）已内置 `MaterialTapTargetSize.padded`（48 命中区），无需额外处理。
- 自定义可点元素（小图标、GestureDetector）用 [`MinTapTarget`](../../lib/shared/widgets/min_tap_target.dart)，在不改变视觉尺寸的前提下把命中区撑到 48。

```dart
MinTapTarget(
  onTap: _onClose,
  semanticLabel: '关闭',
  child: const Icon(Icons.close, size: 16),
);
```

## 5. 焦点管理（T22.5）

- 键盘/辅助技术按**焦点顺序**移动。默认顺序≈控件出现顺序；需自定义时用
  `FocusTraversalGroup(policy: OrderedTraversalPolicy())` + `FocusTraversalOrder(order: NumericFocusOrder(n))`。
- 用 `FocusNode.requestFocus()` 主动聚焦（如错误字段）；`FocusScope.of(context).unfocus()` 收起键盘/清焦点。
- 对话框/弹层注意焦点陷阱与关闭后焦点回归。
- 示例见 [`FocusManagementPage`](../../lib/features/examples/a11y/focus_management_page.dart) 与 showcase「M22 无障碍」。

## 6. 字体缩放

尊重系统字体放大（老花/低视力常调到 1.3–2.0×）。M12 已处理（`MediaQuery.textScaler`，见 [RESPONSIVE](../responsive/RESPONSIVE.md)）：

- 用相对/弹性布局，避免写死高度导致大字号被截断。
- 关键文案别设 `maxLines: 1` + `TextOverflow.ellipsis` 把信息截没。

## 7. 测试与验证

- **语义断言**：widget 测试用 `matchesSemantics(...)` / `tester.getSemantics(...)`（见 `min_tap_target_test.dart`、`app_image_test.dart`）。
- **对比度断言**：`WcagContrast` 单测（`wcag_contrast_test.dart`）。
- **手动测**：开 TalkBack/VoiceOver 走核心流程，照 [屏幕阅读器测试清单](SCREEN_READER_CHECKLIST.md)。
- DevTools 也可查看语义树（见 [DEVTOOLS_GUIDE](../DEVTOOLS_GUIDE.md)）。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · WCAG 2.1 AA · Semantics · macOS。
