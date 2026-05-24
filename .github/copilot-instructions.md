# GitHub Copilot 指令 — flutter_claude_app_v2

可商用 Flutter 模板（Flutter 3.41.9 / Dart 3.11.5 / Material 3 / Clean Architecture + Feature-First）。
完整规则见仓库根 `CLAUDE.md`、`docs/CONVENTIONS.md`、`docs/ARCHITECTURE.md`。生成建议时遵守：

## 架构
- 分层 `domain` → `data` → `presentation`，依赖只能由外向内。
- `lib/core/` 放跨模块基础设施；`lib/features/<f>/` 放业务，**feature 之间不得互相 import**。
- 命名：文件 `lower_snake_case`，类 `UpperCamelCase`，顶层常量 `kXxx`，私有 `_xxx`；
  角色后缀 `XxxRepository`(abstract)/`XxxRepositoryImpl`/`XxxModel`/`XxxUseCase`/`xxxProvider`/`XxxPage`。

## 技术选型（保持一致，勿替换）
- DI：`get_it` + `injectable`（codegen）。状态：`riverpod` 2.6（手写 provider）。路由：`go_router` 15。
- 模型：`freezed` + `json_serializable`（DTO）；领域实体为不可变纯 Dart。网络：`dio` + retrofit。
- 测试：`flutter_test` + `mocktail`。Lint：`very_good_analysis` 10.2.0。
- 优先「零新增依赖 + 抽象 + MethodChannel seam + 桩实现降级」，除非 spec 明确点名某 package。

## injectable / 代码生成必知
1. 注入用的构造参数不要用基本类型（`int`/`String`/`bool`），injectable 无法解析；改用带默认值的 public 可变字段。
2. `@disposeMethod` 以接口绑定时生成 `i.dispose()`（`i` 为接口类型）——接口必须声明该方法，否则生成代码编译失败。
3. `flutter analyze` 不检查生成代码（`*.config.dart` 已 exclude）；改 DI/模型后顺序为
   `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → **`flutter test`**。

## 编码与质量
- `const` 优先；`package:` 绝对导入；跨层错误返回 `Result<T>`，不抛异常，data 层经 `ErrorMapper` 归一为 `Failure`。
- 不要建议 `dart fix --apply` 全量修复；`avoid_redundant_argument_values`、`unnecessary_lambdas` 的自动修复曾改坏代码。
- 任何改动以 `flutter analyze` + `flutter test` 双绿为准。
- 测试复用 `test/_helpers/`；Widget 测试用 `ProviderScope`，DI 用 `getIt.reset()` + `configureDependencies(environment:'dev')`；异步/流断言前 `await tester.pumpAndSettle()`。

## 提交
- Conventional Commits（`<type>(<scope>): <描述>`），由 lefthook + CI 校验。
- 生成代码随源码提交（CI 会重跑 build_runner 比对 diff）。绝不提交密钥。
