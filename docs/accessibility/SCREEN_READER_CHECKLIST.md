---
doc_type: screen_reader_checklist
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T22.4
module_id: M22
status: completed
audience: [human_developers, qa]
tags: [accessibility, a11y, talkback, voiceover, screen-reader, checklist, M22, T22.4]
---

# 屏幕阅读器测试清单（TalkBack / VoiceOver）

> 上线前用真机过一遍。屏幕阅读器是无障碍最硬的验收手段——很多语义问题只有「听」才能发现。
> 配套：[无障碍规范](ACCESSIBILITY.md)。

## 1. 开启屏幕阅读器

### Android · TalkBack
- 开启：设置 → 无障碍 → TalkBack → 打开（或音量上+下键长按，若已配置快捷方式）。
- 关闭：同路径关闭（关时用「双击」确认）。
- 常用手势：
  | 手势 | 作用 |
  |---|---|
  | 右滑 / 左滑 | 下一个 / 上一个元素 |
  | 双击 | 激活当前元素 |
  | 两指上下滑 | 滚动 |
  | 从下向上再向右滑 | 全局菜单 |

### iOS · VoiceOver
- 开启：设置 → 辅助功能 → VoiceOver → 打开（或「三击侧边/主屏键」快捷方式）。
- 常用手势：
  | 手势 | 作用 |
  |---|---|
  | 右滑 / 左滑 | 下一个 / 上一个元素 |
  | 双击 | 激活当前元素 |
  | 三指滑动 | 滚动 |
  | 两指转动（转子） | 切换浏览粒度 |

> 建议：首次测试前先在系统自带 App 熟悉手势 5 分钟，避免把「不会用」当成「App 的 bug」。

## 2. 通用检查项（每屏都过）

- [ ] **每个可见且有意义的元素都能被聚焦并朗读**（右滑能走到）。
- [ ] **朗读内容有意义**：图标按钮念出用途（如「返回」），而不是「按钮」或空白。
- [ ] **不重复、不冗余**：没有「收藏按钮 按钮」这类重复；装饰性元素被跳过。
- [ ] **朗读顺序合理**：从上到下、从左到右，符合视觉阅读顺序（必要时用 `FocusTraversalOrder` 调整）。
- [ ] **状态可感知**：选中/禁用/开关/展开状态被念出（selected/disabled/toggled/expanded）。
- [ ] **图片**：有信息的图念出描述；纯装饰图被跳过。
- [ ] **标题**：页面/分区标题被识别为 header，可用转子/标题导航跳读。
- [ ] **触摸目标**：双击能稳定命中（≥48×48，见 [T22.3](ACCESSIBILITY.md#4-最小点击区域t223)）。
- [ ] **焦点不丢失**：打开/关闭对话框、底部弹层后焦点落点合理，不会跳回顶部或消失。
- [ ] **动态变化被播报**：表单校验错误、加载完成、Toast/SnackBar 用 `liveRegion` 播报。
- [ ] **无纯颜色依赖**：对/错、状态不只靠颜色，叠加了图标或文字。
- [ ] **大字号**：系统字体放大到 ~200% 时文字不被截断、布局不崩。

## 3. 关键流程逐屏清单（本模板）

### 登录页（features/auth）
- [ ] 邮箱/密码输入框念出标签（「邮箱」「密码」）与当前值/占位。
- [ ] 校验失败时错误文案被播报（liveRegion）。
- [ ] 「登录」按钮念出名称与 loading/禁用状态。

### 首页（features/home）
- [ ] 列表项作为整体朗读（标题+副标题合并，见 MergeSemantics），可双击进入。
- [ ] 下拉刷新 / 上拉加载有可感知反馈。

### 详情页（features/detail）
- [ ] 标题为 header；正文可连续朗读。
- [ ] 返回按钮念出「返回」。

### 设置页（features/settings）
- [ ] 语言/主题分段控件念出当前选中项与可选项。
- [ ] 「退出登录」「注销账户」念出名称；危险操作有二次确认且可被朗读。

### 权限演示页（features/permission_demo）
- [ ] 每个权限项念出名称与当前状态。

## 4. 自动化兜底（补充而非替代）

手测之外，CI 用 widget 测试守住语义回归：
- `matchesSemantics(...)` 断言关键控件的 label/role（见 `test/shared/widgets/min_tap_target_test.dart`、`app_image_test.dart`）。
- `WcagContrast` 单测守住对比度（`test/core/theme/a11y/wcag_contrast_test.dart`）。
- Flutter 还提供 `meetsGuideline(textContrastGuideline)` / `androidTapTargetGuideline` / `labeledTapTargetGuideline` 等 `accessibilityGuideline` 断言，可在页面级 widget 测试中调用。

## 5. 验收标准

- [ ] 核心流程（登录→首页→详情→设置）TalkBack 与 VoiceOver 各走通一遍，无「读不出/读错/点不到/焦点丢」。
- [ ] 自动化语义/对比度测试全绿。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · Android TalkBack · iOS VoiceOver。
