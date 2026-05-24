---
doc_type: conventions
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T20.4
module_id: M20
status: completed
audience: [human_developers, ai_agents]
tags: [conventions, naming, code-style, very-good-analysis, git, conventional-commits, lefthook, M20, T20.4]
---

# 约定规范（CONVENTIONS）

> 命名、代码风格、Git 提交三套规范。提交前由 [lefthook](../lefthook.yml) 自动校验，CI 再次把关。
> 配套阅读：[架构](ARCHITECTURE.md) · [上手指南](GETTING_STARTED.md) · [CI/CD](cicd/CICD.md)。

## 1. 命名规范

| 对象 | 规则 | 示例 |
|---|---|---|
| 文件 / 目录 | `lower_snake_case.dart` | `auth_repository_impl.dart` |
| 类 / 枚举 / typedef | `UpperCamelCase` | `SignInUseCase`、`AppPermission` |
| 变量 / 方法 / 参数 | `lowerCamelCase` | `signIn`、`accessToken` |
| 常量 | `lowerCamelCase`（顶层常量可加 `k` 前缀） | `kSupportedLocales` |
| 私有成员 | 前缀 `_` | `_LoginPageState`、`_loadPage` |
| 类型参数 | 单大写或描述性 | `Result<T>`、`AsyncNotifier<HomeFeedState>` |

**分层 / 角色命名约定**（与 [架构](ARCHITECTURE.md) 对应）：

| 角色 | 后缀 / 模式 | 位置 |
|---|---|---|
| 领域实体 | `Xxx`（无后缀，纯 Dart） | `domain/entities/` |
| 数据模型 | `XxxModel`（freezed + json） | `data/models/` |
| 仓库接口 | `XxxRepository`（abstract） | `domain/repositories/` |
| 仓库实现 | `XxxRepositoryImpl` | `data/repositories/` |
| 数据源 | `XxxRemoteDataSource` / `XxxLocalDataSource` | `data/datasources/` |
| 用例 | `XxxUseCase`（`call(...)` 单一职责） | `domain/use_cases/` |
| Riverpod Provider | `xxxProvider` | `presentation/providers/` |
| Controller/Notifier | `XxxController extends (AutoDispose)Notifier/AsyncNotifier` | `presentation/providers/` |
| 页面 / 组件 | `XxxPage` / `XxxWidget` / `XxxView` | `presentation/pages\|widgets/` |

## 2. 代码风格

### 2.1 格式化

统一用 `dart format`（默认 80 列 page width）。提交前 lefthook 自动对暂存的 `.dart` 文件 `dart format` 并回写重新 stage，CI 用 `dart format --output=none --set-exit-if-changed lib test` 把关。

```bash
dart format lib test          # 手动格式化
```

### 2.2 静态分析：very_good_analysis

Lint 基线是 [`very_good_analysis`](../analysis_options.yaml) 10.2.0（比 `flutter_lints` 严格得多），默认全量开启，**仅关掉对本务实模板噪声过大或与设计冲突的少数规则，每条都注明原因**：

| 关闭的规则 | 原因 |
|---|---|
| `public_member_api_docs` | 不强制每个 public 成员写文档（按需补） |
| `lines_longer_than_80_chars` | dart format 已统一；个别长链/URL 允许超出 |
| `sort_pub_dependencies` | pubspec 按「模块」分组加注释，不按字母排序 |
| `flutter_style_todos` | 不强制 `// TODO(user):` 格式 |
| `one_member_abstracts` | 单方法抽象网关是有意设计（seam + fake 测试） |
| `avoid_classes_with_only_static_members` | Design Tokens 容器有意全静态成员 |
| `cascade_invocations` | 级联 `..` 是风格偏好 |
| `comment_references` | 文档里 `[Symbol]` 跨库引用不强制可解析 |
| `discarded_futures` | UI 回调「即发即忘」异步常见 |
| `avoid_catches_without_on_clauses` | 兜底处有意 catch-all |
| `avoid_positional_boolean_parameters` | setter（`setBool(key,value)`）位置参数更自然 |
| `avoid_redundant_argument_values` | 该规则 + `dart fix` 会误删「常量折叠成默认值」的实参（曾静默破坏 EnvConfig dart-define，见 [T16.1](verification/T16.1.md)） |
| `missing_whitespace_between_adjacent_strings` | 中文文案按行拆分时相邻字符串无空格是有意的 |
| `unnecessary_lambdas` | `() => getIt<T>()` 的 tearoff 建议会生成无法编译代码（曾改坏 injection_test） |

> ⚠️ **不要盲目跑 `dart fix --apply`**。其中两条（`avoid_redundant_argument_values`、`unnecessary_lambdas`）的自动修复曾产生**能编译但行为错误**或**无法编译**的代码。改动后务必 `flutter analyze` + `flutter test` 双绿。

```bash
flutter analyze               # 期望：No issues found!
```

生成代码（`*.g.dart` / `*.freezed.dart` / `*.config.dart` / `*.gen.dart` / `lib/l10n/app_localizations*.dart`）已在 `analyzer.exclude` 中排除，不纳入 lint。

### 2.3 通用约定

- **import 顺序**：dart → package → 相对，由 `directives_ordering` 强制（dart format / IDE 自动排）。优先用 `package:` 绝对导入。
- **`const` 优先**：能 const 的 Widget / 构造尽量 const（性能 + lint 要求）。
- **不可变模型**：跨层 DTO 用 `freezed`；领域实体保持不可变。
- **错误处理**：跨层返回 `Result<T>`，不向上抛异常；异常在 `data` 层经 `ErrorMapper` 归一化（见 [架构 §4](ARCHITECTURE.md#4-运行时数据流以登录为例)）。
- **feature 隔离**：`features/A` 不得 import `features/B`；共享逻辑下沉到 `core/` 或 `shared/`。

## 3. Git 提交规范

### 3.1 Conventional Commits

提交信息首行须匹配（由 [`scripts/check_commit_msg.sh`](../scripts/check_commit_msg.sh) 校验，正则见该脚本）：

```
<type>(<scope>)!: <描述>
```

- **type（必填）**：`feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`
- **scope（可选）**：模块/范围，小写，如 `auth`、`env`、`readme`
- **`!`（可选）**：表示破坏性变更
- **描述**：冒号 + 空格后必须有内容

自动放行 `Merge ` / `Revert ` / `fixup!` / `squash!` 开头的提交。

示例：

```
feat(env): 增加 staging flavor
fix: 修复登录态丢失
docs(readme): 更新运行说明
refactor(auth)!: 重构 AuthRepository 接口（破坏性）
```

### 3.2 Git Hooks（lefthook）

[`lefthook.yml`](../lefthook.yml) 配置两个钩子：

| 钩子 | 动作 |
|---|---|
| `pre-commit` | 并行：对暂存 `.dart` 跑 `dart format`（回写并重新 stage）+ 全项目 `flutter analyze` |
| `commit-msg` | `bash scripts/check_commit_msg.sh` 校验 Conventional Commits |

安装（克隆后一次性）：

```bash
brew install lefthook        # 或 dart pub global activate lefthook
lefthook install             # 写入 .git/hooks
```

> 临时跳过（不推荐）：`git commit --no-verify`。CI 仍会拦截，所以本地绕过只会把问题推后。

### 3.3 分支与 PR

- 分支命名建议：`feat/<scope>-<简述>`、`fix/<scope>-<简述>`。
- PR 走 [`.github/pull_request_template.md`](../.github/pull_request_template.md)；Issue 用 [`.github/ISSUE_TEMPLATE/`](../.github/ISSUE_TEMPLATE/)。
- 合并到 `main` 触发 CI（格式 + 分析 + 测试 + codegen 一致性，push 到 main 额外构建 prod AAB）。
- **生成代码须随源码提交**：CI 会重跑 `build_runner` 并 `git diff --exit-code`，生成物与提交不一致会失败。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · very_good_analysis 10.2.0 · lefthook · Conventional Commits。
