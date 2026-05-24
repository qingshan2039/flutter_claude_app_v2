---
doc_type: ai_assisted_dev
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T32.4
module_id: M32
status: completed
audience: [human_developers, ai_agents]
tags: [ai, cursor, claude, copilot, llm, conventions, M32, T32.4]
---

# AI 辅助开发指南（AI_ASSISTED_DEV）

> 本项目内置面向主流 AI 编码助手的统一规则文件，让 Cursor / Claude / GitHub Copilot
> 在生成代码时**自动遵循本仓库的架构与约定**，新成员（人或 AI）即开即用。

## 1. 配置文件一览

| 工具 | 读取的文件 | 内容 |
|---|---|---|
| **Cursor** | [`.cursorrules`](../../.cursorrules) | 精简要点（架构/选型/DI 坑/编码/测试/交付） |
| **Claude**（Claude Code / Claude 等） | [`CLAUDE.md`](../../CLAUDE.md) | **权威详版**，含坑位说明与命令 |
| **GitHub Copilot** | [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md) | 精简要点 |
| 人类总览 | 本文件 | 用法、协作流程、最佳实践 |

> 三份助手规则保持同源：以 `CLAUDE.md` 为准，`.cursorrules` 与 `copilot-instructions.md`
> 是其精简同步版。改了约定请**三处一起更新**，避免不同助手给出冲突建议。

完整规范仍以 [`docs/CONVENTIONS.md`](../CONVENTIONS.md) 与 [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md)
为最终依据；助手规则只是把高频要点前置给 AI。

## 2. 各工具如何启用

- **Cursor**：打开仓库即自动加载根目录 `.cursorrules`，无需配置。
- **Claude Code**：在仓库根运行，自动读取 `CLAUDE.md` 作为项目记忆。
- **GitHub Copilot**：在 VS Code 启用 *Use Instruction Files* 后，自动读取
  `.github/copilot-instructions.md`（Copilot Chat 生效）。

## 3. 给 AI 的协作流程（推荐）

1. **先让 AI 读约定**：指向 `CLAUDE.md` / `docs/CONVENTIONS.md`，再描述需求。
2. **小步交付**：一次实现一个任务（对应 spec 的 `T{XX.X}`），便于 review 与回滚。
3. **改 DI/模型后跑生成**：`dart run build_runner build --delete-conflicting-outputs`。
4. **双绿验收**：`flutter analyze` + `flutter test`（缺一不可，原因见 §4）。
5. **补交付物**：写 `docs/verification/T{XX.X}.md` 并更新索引；有可演示行为则加 showcase demo 页。

## 4. AI 最容易踩的三个坑（务必让助手知道）

1. **injectable 不吃基本类型构造参数**（`int`/`String`/`bool`）——用带默认值的 public 可变字段代替。
2. **`@disposeMethod` 以接口绑定时**生成 `i.dispose()`（`i` 是接口类型）——接口必须声明该方法。
3. **`flutter analyze` 看不到生成代码错误**（`*.config.dart` 被 lint 排除）——必须再跑 `flutter test`
   （走 kernel 编译）才能暴露生成代码里的编译错误。

> 还有一条红线：**不要让 AI 盲目 `dart fix --apply`**。`avoid_redundant_argument_values` 与
> `unnecessary_lambdas` 两条的自动修复在本仓库曾产生「能编译但行为错误」或「无法编译」的代码。

## 5. 应用内的 AI 能力（M32）

模板已预留可直接替换为真实大模型的接入层（见 [`CLAUDE.md` §10](../../CLAUDE.md)）：

- `lib/core/ai/llm_client.dart`：`LlmClient` 抽象（`complete` 非流式 / `stream` 流式），桩实现
  `StubLlmClient` 本地模拟。接 Anthropic / OpenAI / 通义 / 文心等只需新增适配 + 改 DI 绑定。
- `lib/core/ai/sse_parser.dart` + `streaming_text_view.dart`：SSE 解析 + 流式逐字 UI。
- `lib/core/ai/media_picker.dart` + `attachment_picker.dart`：多模态附件选取/展示（桩 + 生产 seam）。

运行 `flutter run -t lib/main_showcase.dart --flavor dev` 进入「M32 · AI 能力集成预留」可现场体验。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · Cursor / Claude / GitHub Copilot · very_good_analysis 10.2.0。
