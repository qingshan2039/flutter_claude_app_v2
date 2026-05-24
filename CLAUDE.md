# CLAUDE.md — AI 协作指南（flutter_claude_app_v2）

> 面向 Claude Code / Claude 等 AI 编码助手的项目级规则。**这是 AI 协作的权威来源**；
> `.cursorrules` 与 `.github/copilot-instructions.md` 是本文件的精简同步版本。
> 人类视角的总览见 [`docs/ai/AI_ASSISTED_DEV.md`](docs/ai/AI_ASSISTED_DEV.md)；
> 完整规范见 [`docs/CONVENTIONS.md`](docs/CONVENTIONS.md) 与 [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)。

## 1. 项目是什么

可商用的 Flutter 应用**模板**，按模块（M02…M32）逐步交付。Flutter 3.41.9 / Dart 3.11.5，
Material 3，Clean Architecture + Feature-First。代码库追求「开箱即用、约定优先、零隐式魔法」。

## 2. 架构与目录

- 分层：`domain`（纯 Dart 实体 + 抽象仓库 + 用例）→ `data`（模型/数据源/仓库实现）→
  `presentation`（页面/组件/Riverpod provider）。依赖只能由外向内。
- `lib/core/`：跨 feature 的基础设施（di、network、storage、theme、router、ai…）。
- `lib/features/<feature>/`：业务模块，**feature 之间禁止互相 import**；共享逻辑下沉 `core/`。
- `lib/features/showcase/`：各模块的可运行 demo 画廊（入口 `lib/main_showcase.dart`）。

## 3. 关键技术选型（不要擅自替换）

| 关注点 | 选型 |
|---|---|
| 依赖注入 | `get_it` 8.x + `injectable` 2.x（codegen） |
| 状态管理 | `riverpod` 2.6.x（手写 provider，不用 codegen 版） |
| 路由 | `go_router` 15.x |
| 数据模型 | `freezed` + `json_serializable`（DTO）；领域实体为不可变纯 Dart |
| 网络 | `dio` + retrofit（拦截器链 + 脱敏） |
| 测试 | `flutter_test` + `mocktail` |
| Lint | `very_good_analysis` 10.2.0 |

**零新增依赖优先**：平台/外部能力优先用抽象 + MethodChannel seam + 优雅降级（桩实现）落地，
只有 spec 明确点名某 package 时才 `flutter pub add`。

## 4. ⚠️ injectable / 代码生成的三个坑（务必牢记）

1. **构造函数不要用基本类型参数**（`int`/`String`/`bool`…）做注入依赖——injectable 无法解析。
   需要可配置标量时，改用**带默认值的 public 可变字段**（见 `RouterLogObserver`、
   `DebugLogStore.capacity`、`NetworkInspector.capacity` 的写法）。
2. **`@disposeMethod` 作用在以接口绑定的实现上时**，生成代码是 `dispose: (i) => i.dispose()`，
   其中 `i` 是**接口类型**——所以接口必须声明该方法，否则生成的 `*.config.dart` 编译失败。
3. **`flutter analyze` 不够**：`analysis_options.yaml` 把 `**/*.config.dart` 等生成代码排除在
   lint 外，所以生成代码里的编译错误 analyze 看不到，**只有 `flutter test`（走 kernel 编译）
   能暴露**。改了 DI / 模型后：先 `dart run build_runner build --delete-conflicting-outputs`，
   再 `flutter analyze`，**最后必须 `flutter test`**。

## 5. 编码约定（高频）

- 命名：文件 `lower_snake_case`、类 `UpperCamelCase`、成员 `lowerCamelmCase`、顶层常量 `kXxx`、
  私有 `_xxx`。角色后缀：`XxxRepository`(abstract)/`XxxRepositoryImpl`/`XxxModel`/`XxxUseCase`/
  `xxxProvider`/`XxxPage`。
- `const` 优先（lint 强制）。import 用 `package:` 绝对路径，顺序 dart→package→相对（自动排）。
- 错误处理：跨层返回 `Result<T>`，**不向上抛异常**；异常在 data 层经 `ErrorMapper` 归一为 `Failure`。
- 不可变：DTO 用 freezed；领域实体保持不可变。
- **不要盲目 `dart fix --apply`**：`avoid_redundant_argument_values` 与 `unnecessary_lambdas`
  两条的自动修复曾产生「能编译但行为错误」或「无法编译」的代码。改完务必 analyze + test 双绿。

## 6. 测试约定

- 单测/组件测优先复用 `test/_helpers/`（`InMemoryKeyValueStorage`、`RecordingAnalytics`、
  `FakeRemoteConfig` 等）；存储相关用 `storage_test_setup.dart`。
- Widget 测试用 `ProviderScope` 包裹；涉及 DI 时 `await getIt.reset(); await configureDependencies(environment:'dev')`。
- 流/异步 UI 断言前用 `await tester.pumpAndSettle()` 把微任务与帧排空。
- 新增 showcase 模块需同步更新 `showcase_gallery_test.dart` 的模块计数与回归遍历。

## 7. 每个任务的交付物（项目特有约定）

完成一个 spec 任务后必须：
1. 写验证报告 `docs/verification/T{XX.X}.md`（YAML frontmatter + 固定 8 段：TL;DR、任务目标、
   实际配置、快速上手、验收命令与实际输出、偏差与决策、关键文件清单、下一步、环境快照）。
2. 更新 `docs/verification/README.md`（frontmatter 的 completed_tasks/modules、报告表格行、模块进度）。
3. 若有可演示行为，在 showcase 画廊加一个 demo 页。

## 8. Git / 提交

- **未经用户明确指示，不要 `git commit`**。绝不提交密钥（`.env`、凭证）。
- 提交信息走 Conventional Commits：`<type>(<scope>): <描述>`（lefthook + CI 双重校验）。
- 生成代码随源码一起提交（CI 会重跑 build_runner 并 `git diff --exit-code`）。

## 9. 常用命令

```bash
dart run build_runner build --delete-conflicting-outputs   # 代码生成
flutter analyze                                            # 静态分析（不查生成代码）
flutter test                                               # 单测（会编译生成代码）
flutter run -t lib/main_showcase.dart --flavor dev         # 跑 showcase 画廊
```

## 10. AI 能力集成（M32，本模块自身）

- LLM 走 `lib/core/ai/llm_client.dart` 的 `LlmClient` 抽象（`complete` / `stream`）。当前为
  `StubLlmClient` 桩实现；接真实厂商（Anthropic/OpenAI/通义/文心…）时新增适配并改 DI 绑定即可，
  业务层不变。
- 流式 UI 用 `StreamingTextView`（消费 `Stream<String>` 增量）；SSE 解析用 `SseParser`。
- 多模态用 `MediaPicker` + `AttachmentPicker`（桩 `StubMediaPicker` 返回 null；生产接
  image_picker / file_picker）。
