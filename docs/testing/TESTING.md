---
doc_type: implementation_guide
module_id: M17
priority: P0
status: implemented
spec_source: flutter_template_v3.md
spec_lines: "677-707"
tags: [testing, unit-test, widget-test, integration-test, mocktail, coverage, lcov, M17]
related_code:
  - test/_helpers/mocks.dart
  - test/features/auth/
  - test/shared/
  - integration_test/login_flow_test.dart
  - scripts/coverage.sh
---

# 测试体系（M17）

> 🔰 **第一次写 Flutter 测试？** 先看手把手教程
> [`BEGINNER_GUIDE.md`](./BEGINNER_GUIDE.md)（含每步命令、预期输出、排错）。本文是给熟手的速查版。
>
> 单元 / Widget / 集成三层测试 + mocktail + 覆盖率。约定与范例集中在 `test/`、
> `integration_test/`。

## 1. 测试金字塔与对应范例

| 层级 | 测多大 | 范例 |
|---|---|---|
| 单元测试 | 一个类/函数（纯逻辑） | `test/features/auth/domain/use_cases/get_current_user_use_case_test.dart`（UseCase）<br>`test/features/auth/data/repositories/auth_repository_impl_test.dart`（Repository + mock DataSource）<br>`test/features/auth/data/mappers/user_mapper_test.dart`（Mapper） |
| Widget 测试 | 一个组件 + Provider 注入 | `test/features/auth/presentation/widgets/current_user_badge_test.dart`<br>`test/shared/widgets/*_test.dart`（M14 组件） |
| 集成测试 | 多页面端到端 | `integration_test/login_flow_test.dart`（登录流程） |

## 2. mocktail（T17.2）

**无需代码生成**，直接 `class MockX extends Mock implements X {}`。共享 mock 放
`test/_helpers/mocks.dart`。

```dart
final ds = MockAuthRemoteDataSource();
// 打桩
when(() => ds.fetchUser(userId: any(named: 'userId')))
    .thenAnswer((_) async => const UserModel(id: '1', name: 'A', email: 'a@b'));
// 抛错
when(() => ds.fetchUser(userId: any(named: 'userId')))
    .thenThrow(const NetworkException(message: 'offline'));
// 校验
verify(() => ds.fetchUser(userId: 'x')).called(1);
```

> 用 `any()`/`captureAny()` 匹配**非基元**类型参数前，要先
> `registerFallbackValue(...)`（见 `registerCommonFallbackValues()`）。基元/可空类型不用。

## 3. 单元测试：Repository + mock DataSource（T17.1）

为了能 mock，数据获取被抽成接口 `AuthRemoteDataSource`（seam）。Repository 只测
自己的职责（调用数据源 → mapper → 错误归一化），用 mock 数据源隔离网络：

```dart
repository = AuthRepositoryImpl(MockAuthRemoteDataSource(), const ErrorMapper());
// 成功：DataSource 返回 Model → 期望 Success(User)
// 失败：DataSource thenThrow → 期望 Failed(NetworkFailure)
```

## 4. Widget 测试：Provider 注入（T17.3）

用 `ProviderScope.overrides` 把 provider 换成 mock，精确控制三态，不碰真实 DI：

```dart
ProviderScope(
  overrides: [getCurrentUserUseCaseProvider.overrideWithValue(mockUseCase)],
  child: const MaterialApp(home: CurrentUserBadge()),
);
```

> 含 `CircularProgressIndicator` 等**永不停止动画**的页面，用 `tester.pump()`
> 而**不要** `pumpAndSettle()`（否则超时）。

## 5. 集成测试：登录端到端（T17.4）

`integration_test/login_flow_test.dart` 驱动完整 `App`：未登录被守卫拦到登录页 →
点登录 → 进首页。

```bash
# 真机 / 模拟器（推荐；integration_test 需要连接设备）
flutter test integration_test
flutter test integration_test/login_flow_test.dart -d <deviceId>
```

> 同样的端到端逻辑也可作为普通 widget 测试在 `flutter test`（flutter_tester，
> 无需设备）中验证——`integration_test` 与普通 `WidgetTester` API 一致，只是
> 绑定不同。CI 基础流水线**不**自动跑 integration_test（会卡在等待设备），
> 应放到带模拟器的独立 job。

## 6. 覆盖率（T17.5）

```bash
scripts/coverage.sh          # 跑测试 + 生成 coverage/lcov.info + 打印行覆盖率
scripts/coverage.sh --html   # 额外出 coverage/html/index.html（需 lcov/genhtml）
```

- 摘要用 awk 直接从 `lcov.info` 计算，跨 lcov 版本稳定。
- 装了 `lcov` 时会先过滤生成代码（`*.g.dart`/`*.freezed.dart`/`*.config.dart`/
  `*.gen.dart`/l10n/入口），让数字反映**手写代码**的覆盖。
- CI（`.github/workflows/ci.yml`）跑 `flutter test --coverage` 并把 `lcov.info`
  作为 artifact 上传；同时跑 `flutter test integration_test`。

## 7. 常用命令

```bash
flutter test                                   # 全部单元/Widget 测试
flutter test test/features/auth                # 指定目录
flutter test --coverage                        # 带覆盖率
flutter test integration_test                  # 集成测试
scripts/coverage.sh --html                     # 覆盖率 + HTML 报告
```
