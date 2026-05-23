---
doc_type: tutorial
module_id: M17
audience: [human_beginners]
status: implemented
tags: [tutorial, beginner, testing, unit-test, widget-test, integration-test, mocktail, coverage, M17]
related_code:
  - test/features/auth/
  - test/_helpers/mocks.dart
  - test/_helpers/storage_test_setup.dart
  - integration_test/login_flow_test.dart
  - scripts/coverage.sh
---

# M17 实战手册（新手向）：写测试 · mock · 集成测试 · 覆盖率

> 面向**第一次写 Flutter 测试**的人。每一步都给可直接复制的命令、预期输出和出错怎么办。
> 跟着做即可。简明速查版（给熟手）看同目录 [`TESTING.md`](./TESTING.md)。

---

## 0. 先记住三句话

1. **测试 = 用代码验证代码**：写一段代码，自动检查「真实代码」的行为对不对。改坏了立刻报警。
2. **三层金字塔**：单元测试（测一个函数/类，最多最快）> Widget 测试（测一个界面组件）> 集成测试（测整条流程，最少最慢）。
3. **跑测试就一条命令**：`flutter test`。绿色 = 通过，红色 = 失败并告诉你哪行。

---

## 1. 名词速览（30 秒）

| 词 | 大白话 |
|---|---|
| 单元测试 unit test | 测一个纯逻辑（如「Mapper 转换对不对」） |
| Widget 测试 | 测一个界面组件（如「按钮点了有没有反应」） |
| 集成测试 integration test | 测整条用户流程（如「登录走通没」） |
| mock（替身）| 假的依赖，让你单独测某个类，不碰网络/数据库 |
| 覆盖率 coverage | 你的测试「跑到了」多少比例的代码 |
| `expect(实际, 期望)` | 断言：不相等就判定失败 |

---

## 2. 跑测试（最基础）

在项目根目录（有 `pubspec.yaml` 那层）：

```bash
# 跑全部测试（test/ 目录下所有 *_test.dart）
flutter test

# 只跑某个文件
flutter test test/features/auth/data/mappers/user_mapper_test.dart

# 只跑某个目录
flutter test test/features/auth

# 只跑名字里含某关键字的用例
flutter test --name '成功'
```

通过时结尾是：

```
00:11 +409: All tests passed!
```

`+409` = 通过 409 个；如果有 `-1` 就是失败 1 个，上面会列出失败文件与原因。

> 📌 测试文件必须放在 `test/` 下、文件名以 `_test.dart` 结尾，否则 `flutter test` 不会跑它。
> 习惯：测试目录结构**镜像** `lib/`，例如 `lib/features/auth/...` 的测试放
> `test/features/auth/...`。

---

## 3. 一个测试文件长什么样（骨架）

```dart
import 'package:flutter_test/flutter_test.dart';   // 测试框架（必备）
// import 你要测的真实代码...

void main() {                       // 入口，固定写法
  group('一组相关测试', () {         // 可选：把相关用例归一组
    test('描述这个用例验证什么', () {  // 一个用例
      // 1) 准备数据
      final sum = 1 + 1;
      // 2) 断言
      expect(sum, 2);               // 实际 sum 应等于 2
    });
  });
}
```

- `test(...)`：同步用例；要 `await` 时写 `test('...', () async { ... })`。
- `expect(实际, 期望)`：常用「期望」写法：
  - `expect(x, 2)` 相等
  - `expect(x, isTrue)` / `isFalse` / `isNull` / `isNotNull`
  - `expect(x, isA<User>())` 类型是 User
  - `expect(() => f(), throwsStateError)` 调用会抛 StateError

---

## 4. 写第一个单元测试（纯函数 / Mapper）

目标：验证 `UserModel.toEntity()` 转换正确（真实代码在
`lib/features/auth/data/mappers/user_mapper.dart`）。

**第 1 步**：建文件 `test/features/auth/data/mappers/user_mapper_demo_test.dart`（本项目已有
正式版 `user_mapper_test.dart`，这里只是教学演示，跑完可删）。

**第 2 步**：写

```dart
import 'package:flutter_claude_app_v2/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserModel.toEntity 字段一一对应', () {
    const model = UserModel(id: '1', name: 'Alice', email: 'a@b.com');

    final user = model.toEntity();   // 调真实代码

    expect(user.id, '1');
    expect(user.name, 'Alice');
    expect(user.email, 'a@b.com');
  });
}
```

**第 3 步**：跑

```bash
flutter test test/features/auth/data/mappers/user_mapper_demo_test.dart
```

看到 `All tests passed!` 即成功。

> 三段式习惯（AAA）：**Arrange**（准备数据）→ **Act**（调被测代码）→ **Assert**（断言）。

---

## 5. mock 依赖（mocktail）

### 5.1 为什么要 mock

要单独测 `AuthRepositoryImpl`，但它依赖 `AuthRemoteDataSource`（真实的会发网络请求）。
我们用一个「假数据源」替身，让它「想返回什么就返回什么」，从而只测 Repository 自己的逻辑。

本项目用 **mocktail**（不需要代码生成）。共享替身放在 `test/_helpers/mocks.dart`：

```dart
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
```

### 5.2 mocktail 四个动作

```dart
final ds = MockAuthRemoteDataSource();

// ① 打桩：调用时返回什么（异步用 thenAnswer，同步用 thenReturn）
when(() => ds.fetchUser(userId: any(named: 'userId')))
    .thenAnswer((_) async => const UserModel(id: '1', name: 'A', email: 'a@b'));

// ② 打桩：调用时抛异常
when(() => ds.fetchUser(userId: any(named: 'userId')))
    .thenThrow(const NetworkException(message: 'offline'));

// ③ 校验：某方法被调了几次
verify(() => ds.fetchUser(userId: 'x')).called(1);

// ④ 参数匹配器：any() 任意值，any(named:'x') 任意命名参数
```

> ⚠️ 用 `any()` 匹配**非基元类型**（如 `User`）前，要先
> `registerFallbackValue(const User(...))`（本项目封装为 `registerCommonFallbackValues()`）。
> `String`/`int`/可空类型不用注册。

### 5.3 完整例子：Repository + mock DataSource（逐行）

真实范例在 `test/features/auth/data/repositories/auth_repository_impl_test.dart`：

```dart
import 'package:mocktail/mocktail.dart';
import '../../../../_helpers/mocks.dart';   // 共享替身

void main() {
  late MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {                                  // 每个用例前都跑：拿到全新替身
    dataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource, const ErrorMapper());
  });

  test('成功：数据源返回 Model → 仓库给出 Success(User)', () async {
    // Arrange：让替身返回一个 UserModel
    when(() => dataSource.fetchUser(userId: any(named: 'userId')))
        .thenAnswer((_) async =>
            const UserModel(id: '7', name: 'Neo', email: 'neo@m.io'));

    // Act：调真实仓库
    final result = await repository.getCurrentUser(userId: '7');

    // Assert：是 Success，且名字映射对了
    expect(result, isA<Success<User>>());
    expect((result as Success<User>).value.name, 'Neo');
    verify(() => dataSource.fetchUser(userId: '7')).called(1);
  });

  test('失败：数据源抛异常 → 仓库给出 Failed(NetworkFailure)', () async {
    when(() => dataSource.fetchUser(userId: any(named: 'userId')))
        .thenThrow(const NetworkException(message: 'offline'));

    final result = await repository.getCurrentUser();

    expect(result, isA<Failed<User>>());
    expect((result as Failed<User>).failure, isA<NetworkFailure>());
  });
}
```

> **替身（fake）vs mock**：本项目两种都用。
> - 简单依赖：手写 fake（如 UseCase 测试里的 `_FakeAuthRepo implements AuthRepository`）。
> - 要「按调用打桩 / 校验调用次数」：用 mocktail（如上）。

---

## 6. Widget 测试（测界面组件）

### 6.1 基本套路

```dart
testWidgets('点按钮后计数 +1', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: MyCounter()));  // 渲染组件
  expect(find.text('0'), findsOneWidget);                          // 初始是 0

  await tester.tap(find.byIcon(Icons.add));                        // 点 + 按钮
  await tester.pump();                                             // 重建一帧

  expect(find.text('1'), findsOneWidget);                          // 变成 1
});
```

- `tester.pumpWidget(...)`：把组件放进测试环境渲染。
- `find.text('x')` / `find.byType(X)` / `find.byIcon(...)`：定位 widget。
- `tester.tap(...)` / `enterText(...)`：交互。
- `findsOneWidget` / `findsNothing` / `findsWidgets`：数量断言。

### 6.2 `pump` vs `pumpAndSettle`（关键陷阱！）

| 方法 | 作用 |
|---|---|
| `await tester.pump()` | 只重建**一帧** |
| `await tester.pump(Duration(...))` | 前进指定时间再重建一帧 |
| `await tester.pumpAndSettle()` | 反复重建直到**没有动画**为止 |

> 🚨 如果界面有**永不停止的动画**（`CircularProgressIndicator` 转圈、骨架屏微光），
> 用 `pumpAndSettle()` 会**永远等不到结束 → 超时报错**。这种情况用 `pump()`。
> 这是新手最常踩的坑。

### 6.3 Provider 注入（用假的 provider 控制状态）

要测一个读 Riverpod provider 的组件，最干净的做法是用 `ProviderScope.overrides`
把 provider 换成你能控制的替身。真实范例
`test/features/auth/presentation/widgets/current_user_badge_test.dart`：

```dart
testWidgets('显示用户名', (tester) async {
  final useCase = MockGetCurrentUserUseCase();
  when(() => useCase()).thenAnswer(
    (_) async => const Success<User>(User(id: '1', name: 'Trinity', email: 't@m')),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [getCurrentUserUseCaseProvider.overrideWithValue(useCase)],
      child: const MaterialApp(home: Scaffold(body: CurrentUserBadge())),
    ),
  );
  await tester.pump();   // 等 FutureProvider 完成（不要 pumpAndSettle）

  expect(find.text('Trinity'), findsOneWidget);
});
```

### 6.4 测试需要 DI / 存储时

有些测试要 `configureDependencies()`（getIt）或用到 SharedPreferences/Hive。
本项目封装了 `test/_helpers/storage_test_setup.dart`：

```dart
import '../../_helpers/storage_test_setup.dart';

late Directory tempDir;
setUp(() async {
  tempDir = await setupStorageMocks();      // 装好平台 mock
  await getIt.reset();
  await configureDependencies(environment: 'dev');
});
tearDown(() async {
  await getIt.reset();
  await tearDownStorageMocks(tempDir);      // 清理
});
```

---

## 7. 集成测试（端到端）

### 7.1 和 Widget 测试的区别

- Widget 测试：测**一个组件**，放在 `test/`。
- 集成测试：驱动**整个 App**（路由 + DI + 主题…）走完一条用户流程，放在 `integration_test/`。
  API 几乎一样（也用 `tester` / `find` / `tap`），但**需要连接真机或模拟器**。

### 7.2 怎么跑

```bash
# 先连一台设备/启动模拟器，然后：
flutter test integration_test
flutter test integration_test/login_flow_test.dart -d <deviceId>
```

> ⚠️ 没有连设备时，`flutter test integration_test` 会**卡在「等待设备」**。
> 这不是 bug，是它本来就要设备。CI 里要放到带 Android 模拟器的独立 job 跑。

### 7.3 例子：登录流程

`integration_test/login_flow_test.dart` 验证「未登录 → 被守卫拦到登录页 → 点登录 → 进首页」：

```dart
await tester.pumpWidget(ProviderScope(child: const App()));
await tester.pumpAndSettle();
expect(find.text('Sign in (demo)'), findsOneWidget);     // 在登录页
await tester.tap(find.text('Sign in (demo)'));
await tester.pumpAndSettle();
expect(find.text('Home Page (router demo)'), findsOneWidget); // 到首页
```

---

## 8. 覆盖率（测试覆盖了多少代码）

### 8.1 一条命令

```bash
scripts/coverage.sh            # 跑测试 + 打印行覆盖率
scripts/coverage.sh --html     # 额外生成 HTML 报告（需装 lcov：brew install lcov）
```

输出：

```
📊 覆盖率摘要：
   行覆盖 Lines: 1857/2402  (77.3%)
```

意思：手写代码里有 2402 行可执行，测试跑到了 1857 行（77.3%）。

### 8.2 看 HTML 报告（直观）

```bash
scripts/coverage.sh --html
open coverage/html/index.html   # 浏览器打开，红色 = 没被测到的行
```

> 覆盖率不是越高越好的唯一指标，但「核心逻辑（UseCase/Repository/Mapper）应尽量高」。
> 生成代码（`*.g.dart` 等）已被脚本排除，不计入。

---

## 9. 好习惯（写出能维护的测试）

1. **一个用例只测一件事**，描述写清「验证什么」。
2. **AAA 结构**：Arrange → Act → Assert。
3. **不要测私有实现细节**，测「行为/输出」。
4. 测试代码**也要过 lint**（本项目用 very_good_analysis）：写完跑 `dart format .` + `flutter analyze`，否则 pre-commit 钩子会拦你（见 `docs/cicd/BEGINNER_GUIDE.md`）。
5. 异步必须 `await`，否则断言可能在结果出来前就跑了。

---

## 10. 一页速查表

```bash
flutter test                                   # 全部
flutter test test/features/auth                # 某目录
flutter test path/to/foo_test.dart --name X    # 某文件某用例
flutter test --coverage                        # 带覆盖率
flutter test integration_test                  # 集成测试（需设备）
scripts/coverage.sh --html                     # 覆盖率 + HTML
```

```dart
expect(x, 2); expect(x, isA<T>()); expect(()=>f(), throwsStateError);
when(() => mock.foo()).thenAnswer((_) async => v);   // 打桩
verify(() => mock.foo()).called(1);                  // 校验
ProviderScope(overrides: [p.overrideWithValue(v)], child: ...);  // 注入
await tester.pump();              // 有动画用这个
await tester.pumpAndSettle();     // 无动画才用这个
```

---

## 11. 常见错误 FAQ

**Q：`pumpAndSettle timed out`（超时）？**
A：界面有永不停的动画（转圈/骨架屏）。把 `pumpAndSettle()` 换成 `pump()` 或
`pump(const Duration(milliseconds: 300))`。

**Q：`Bad state: GetIt: ... is not registered`？**
A：测试用到了 DI，但没初始化。在 `setUp` 里调
`setupStorageMocks()` + `configureDependencies()`（见 6.4）。

**Q：mocktail 报 `type 'X' is not registered as a fallback value`？**
A：你对非基元类型用了 `any()`。先 `registerFallbackValue(const X(...))`
（或调 `registerCommonFallbackValues()`）。

**Q：`flutter test integration_test` 一直不动？**
A：没连设备。启动模拟器或连真机；CI 里放到带模拟器的独立 job。

**Q：提交时被钩子拦下，说测试/分析没过？**
A：本地先 `flutter analyze` + `flutter test` 跑绿再提交（见
`docs/cicd/BEGINNER_GUIDE.md` 第 2 章）。

**Q：改了 `lib/` 代码后测试挂了？**
A：正常——测试在替你「报警」。看失败信息，要么是代码改错了，要么是测试该跟着更新。
