---
doc_type: troubleshooting
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T20.6
module_id: M20
status: completed
audience: [human_developers, ai_agents]
tags: [troubleshooting, build_runner, codegen, ios, cocoapods, di, dart-define, flavor, errors, M20, T20.6]
---

# 常见问题排查（TROUBLESHOOTING）

> 按现象分类，每条给「症状 → 原因 → 解决」。配套阅读：[上手指南](GETTING_STARTED.md) · [约定规范](CONVENTIONS.md)。

## build_runner 相关

### 冲突：`Conflicting outputs were detected`

**症状**：`dart run build_runner build` 报已存在的生成文件冲突。
**原因**：上次生成残留、或多个生成器抢同一输出。
**解决**：

```bash
dart run build_runner build --delete-conflicting-outputs
# 仍失败时清缓存：
dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
```

### 改了注解但生成物没更新

**症状**：新增 `@injectable` / `@LazySingleton` / freezed 字段后，`getIt<X>()` 仍抛未注册，或模型缺字段。
**原因**：忘记重跑代码生成。
**解决**：重跑 `dart run build_runner build --delete-conflicting-outputs`；开发期可挂 `watch`。生成器：injectable（`lib/core/di/injection.config.dart`）、freezed/json（`*.freezed.dart`/`*.g.dart`）、retrofit、go_router_builder、flutter_gen。

### CI 报「生成代码与提交不一致」

**症状**：CI 的「Codegen 校验」步骤 `git diff --exit-code` 失败。
**原因**：本地改了注解类但没把重新生成的产物一起提交。**本项目生成物随源码入库**。
**解决**：本地 `dart run build_runner build --delete-conflicting-outputs`，把变更的 `*.g.dart` / `*.config.dart` 等一并 `git add` 后提交。

### i18n 文案没生成 / 缺 key 编译报错

**症状**：`AppLocalizations.of(context).xxx` 找不到，或新增 key 后报错。
**原因**：l10n 由 `flutter gen-l10n` 单独生成（不走 build_runner）。
**解决**：`flutter gen-l10n`（或 `flutter pub get`，因 `generate: true` 会触发）。漏译某 key 默认回退到模板语言（en）而非崩溃；想列出缺失项，在 `l10n.yaml` 加 `untranslated-messages-file`。

## iOS / CocoaPods 相关

### 信息提示：「plugins do not support Swift Package Manager」

**症状**：iOS 相关命令打印 `The following plugins do not support Swift Package Manager for ios: permission_handler_apple, flutter_secure_storage`。
**原因**：本项目**有意固定 CocoaPods**（`pubspec.yaml` 的 `enable-swift-package-manager: false`），因为这两个插件还没适配 SPM。该提示由 flutter_tools 在 macOS 上无条件打印。
**解决**：**无需处理**，无害。两个插件有 podspec，iOS 始终用 CocoaPods 正常构建。待插件适配 SPM 后删掉 pubspec 里那段配置即可。

### `pod install` 失败 / Pod 版本错乱

**症状**：iOS 构建报 Pod 相关错误。
**解决**：

```bash
cd ios
pod repo update
rm -rf Pods Podfile.lock && pod install
cd ..
flutter clean && flutter pub get
```

仍失败时检查 Xcode / CocoaPods 版本，并确认 iOS Deployment Target = **13.0**。

## DI（依赖注入）相关

### `Bad state: GetIt: Object/factory ... is not registered`

**症状**：运行时 `getIt<SomeType>()` 抛未注册。
**原因**：① 没重跑 build_runner；② 类缺 `@injectable`/`@LazySingleton`；③ 测试里没 `configureDependencies` 或没在 setUp 重置；④ 用错环境名。
**解决**：确认注解 → 重跑生成 → 测试中 `await getIt.reset(); await configureDependencies(environment: 'dev');`（参考 `test/app_test.dart`）。

### 注册了接口却拿不到实现

**症状**：`getIt<XxxRepository>()` 未注册，但 `XxxRepositoryImpl` 存在。
**原因**：实现类要用 `@LazySingleton(as: XxxRepository)`（或 `@Injectable(as:)`）把实现绑定到接口。
**解决**：补 `as:`，重跑生成。验证：`grep XxxRepository lib/core/di/injection.config.dart`。

## 多环境 / dart-define 相关

### `--flavor qa` 构建失败：找不到 flavor

**症状**：加了 `lib/main_qa.dart` 但 `flutter build --flavor qa` 报 Gradle flavor 不存在。
**原因**：**Dart 入口与原生 flavor 必须成对**，只加 Dart 入口不够。
**解决**：在 `flavorizr.yaml` + Android `build.gradle.kts` 的 `productFlavors` 补 `qa`（iOS 补 scheme）。完整步骤见 [扩展指南 § 新增环境](EXTEND_GUIDE.md#新增环境)。

### env 值没生效 / 用了内置默认

**症状**：改了 `env/dev.json` 但运行仍是默认值。
**原因**：① 没传 `--dart-define-from-file=env/dev.json`；② 文件不存在（`env/*.json` 被 gitignore，需从 `*.example.json` 复制）。
**解决**：`cp env/dev.example.json env/dev.json`，运行带上 `--dart-define-from-file`，或直接用 `scripts/flutter-env.sh dev run`。

### ⚠️ 不要随手 `dart fix --apply`

**症状**：跑完 `dart fix` 后 EnvConfig 的 dart-define 覆盖失效，或测试无法编译。
**原因**：`avoid_redundant_argument_values` 的修复会误删「常量折叠成默认值」的实参（静默破坏 dart-define）；`unnecessary_lambdas` 会把 `() => getIt<T>()` 改成无法编译的 tearoff。这两条规则已在 `analysis_options.yaml` 关闭并注明（见 [T16.1](verification/T16.1.md)）。
**解决**：避免全量 `dart fix`；若已执行，`git diff` 复查并还原，然后 `flutter analyze && flutter test` 双绿确认。

## 测试相关

### `flutter test integration_test` 卡住不动

**症状**：跑集成测试目录时一直「等待设备」。
**原因**：`integration_test` 需要真机/模拟器；host 上没有设备会挂起。
**解决**：单文件用 flutter_tester 跑：`flutter test integration_test/login_flow_test.dart`；真机/模拟器跑整目录 `flutter test integration_test`。CI 里这部分需用带模拟器的独立 job（见 `.github/workflows/ci.yml` 注释）。注意 macOS 没有 `timeout` 命令。

### 手写 Fake 在接口加方法后编译失败

**症状**：给某 Repository 接口加方法后，测试里的 `class FakeXxx implements XxxRepository` 报「缺少实现」。
**原因**：手写 Fake 不像 mocktail Mock 那样靠 `noSuchMethod` 自动兜底。
**解决**：给 Fake 补上新方法的桩实现；或改用 `class MockXxx extends Mock implements XxxRepository`（mocktail，自动处理新方法）。

### `The method 'fold' isn't defined for the type 'Result'`

**症状**：用 `result.fold(...)` 编译报未定义。
**原因**：`fold` 是定义在 `core/error/result.dart` 的**扩展方法**，不导入该文件时不在作用域。
**解决**：`import 'package:flutter_claude_app_v2/core/error/result.dart';`。

## 通用

### `flutter analyze` 有报错

**解决**：先 `dart format lib test`，再看具体规则。本项目基线是 very_good_analysis（严格），已关闭的规则与原因见 [CONVENTIONS § 2.2](CONVENTIONS.md#22-静态分析very_good_analysis)。不要为了消红盲改生成代码（已被 exclude）。

### 玄学问题先做一遍「清理三连」

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

iOS 再加 `cd ios && pod install && cd ..`。八成的「拉取后跑不起来」靠这套解决。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · Android minSdk 24 · iOS 13.0 / CocoaPods · very_good_analysis 10.2.0 · macOS。
