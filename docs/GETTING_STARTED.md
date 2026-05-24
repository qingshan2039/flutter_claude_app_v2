---
doc_type: getting_started
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T20.2
module_id: M20
status: completed
audience: [human_developers, ai_agents]
tags: [getting-started, setup, environment, codegen, multi-env, run, M20, T20.2]
---

# 上手指南（GETTING_STARTED）

> 从零把项目跑起来：环境准备 → 依赖安装 → 代码生成 → 环境变量 → 多环境运行。
> 配套阅读：[README](../README.md) · [架构](ARCHITECTURE.md) · [常见报错](TROUBLESHOOTING.md)。

## 1. 环境准备

| 工具 | 版本 | 说明 |
|---|---|---|
| Flutter | **3.41.9** | `flutter --version` 确认；建议用 fvm 锁定 |
| Dart | **3.11.5** | 随 Flutter 自带，pubspec 约束 `sdk: ^3.11.5` |
| Android | **minSdk 24**，JDK 17 | Android Studio / SDK + 命令行工具 |
| iOS（仅 macOS） | **iOS 13.0**，Xcode + CocoaPods | 本项目固定用 CocoaPods（关闭 SPM） |

自检：

```bash
flutter doctor            # 各平台工具链是否就绪
flutter --version         # 期望 3.41.9 / Dart 3.11.5
```

> 为什么固定 CocoaPods？`permission_handler_apple`（M09）与 `flutter_secure_storage`（M05）目前只提供 podspec、未适配 Swift Package Manager。`pubspec.yaml` 里 `enable-swift-package-manager: false` 固定 CocoaPods，避免在开启 SPM 的机器上意外迁移。iOS 命令仍会打印一行 "The following plugins do not support Swift Package Manager…" 的信息性提示，**无害**，可忽略。

## 2. 依赖安装

```bash
flutter pub get
```

如需安装 Git Hooks（提交前自动格式化 + 分析，见 [CONVENTIONS](CONVENTIONS.md)）：

```bash
brew install lefthook        # 或：dart pub global activate lefthook
lefthook install             # 写入 .git/hooks
```

## 3. 代码生成（必做）

本项目大量使用编译期代码生成（DI、freezed、json、retrofit、go_router、资源）。**生成物已随源码提交**，但拉取后或改动注解类后需重跑：

```bash
# 一次性构建（推荐）
dart run build_runner build --delete-conflicting-outputs

# 开发时持续监听
dart run build_runner watch --delete-conflicting-outputs
```

涉及的生成器：`injectable_generator`（DI，输出 `lib/core/di/injection.config.dart`）、`freezed` + `json_serializable`（模型 `*.freezed.dart` / `*.g.dart`）、`retrofit_generator`（API 客户端）、`go_router_builder`（类型安全路由 `*.g.dart`）、`flutter_gen_runner`（资源 `lib/gen/assets.gen.dart`）。

国际化文案单独由 `flutter gen-l10n` 生成（`pubspec.yaml` 的 `generate: true` 会在 `flutter pub get` 时自动触发）：

```bash
flutter gen-l10n          # 生成 lib/l10n/app_localizations*.dart
```

> 卡在 build_runner 冲突？见 [TROUBLESHOOTING § build_runner](TROUBLESHOOTING.md#build_runner-相关)。

## 4. 环境变量（Dart Define）

敏感配置（API 地址、Sentry DSN、API Key 等）通过**编译期常量**注入，不硬编码、不入库。仓库只提交模板 `env/<env>.example.json`，真实文件 `env/<env>.json` 已被 `.gitignore`。

```bash
cp env/dev.example.json env/dev.json       # 复制后按需填值
```

`env/dev.example.json` 模板：

```json
{
  "API_BASE_URL": "https://dev-api.example.com",
  "SENTRY_DSN": "",
  "API_KEY": "",
  "APP_NAME": "CCD Dev",
  "ENABLE_LOGGING": true,
  "ENABLE_CRASH_REPORTING": false
}
```

运行时这些值由 `EnvConfig`（`lib/core/env/env_config.dart`）解析；未提供 `env/<env>.json` 时回退到 `EnvConfig` 的内置默认值（`apiKey` / `sentryDsn` 在 `toString` 中脱敏）。详见 [多环境配置](env/ENVIRONMENTS.md)。

## 5. 多环境运行

模板提供三套环境，每套有独立的 **Dart 入口**（`lib/main_<env>.dart` → `bootstrap(AppEnvironment.<env>)`）和 **原生 flavor**（包名 / AppName / 图标）。

### 方式 A：封装脚本（推荐）

```bash
scripts/flutter-env.sh dev run                # 开发运行
scripts/flutter-env.sh staging build-apk      # 预发 APK
scripts/flutter-env.sh prod build-appbundle   # 生产 AAB
scripts/flutter-env.sh prod build-ios         # 生产 iOS
```

脚本自动拼接 `--flavor`、`-t lib/main_<env>.dart`、`--dart-define-from-file=env/<env>.json`。

### 方式 B：原生 flutter 命令

```bash
flutter run -t lib/main_dev.dart --flavor dev --dart-define-from-file=env/dev.json
flutter build apk      --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.json
flutter build appbundle --flavor prod   -t lib/main_prod.dart    --dart-define-from-file=env/prod.json \
  --obfuscate --split-debug-info=build/symbols/prod
```

### 方式 C：VSCode

`.vscode/launch.json`（T15.4）已为三套环境各配一个 launch 配置，F5 直接选择。

### 组件画廊（可选）

```bash
flutter run -t lib/main_showcase.dart        # M14 组件画廊，无需 flavor/env
```

## 6. 验证安装成功

```bash
flutter analyze     # 期望：No issues found!
flutter test        # 期望：All tests passed!
```

两条都绿，即环境就绪。接着读 [架构文档](ARCHITECTURE.md) 了解代码怎么组织，或 [扩展指南](EXTEND_GUIDE.md) 开始加你的第一个 feature。

## 7. 打包发布（概览）

```bash
scripts/build_android.sh        # Android 打包脚本（T16.4）
scripts/build_ios.sh            # iOS 打包脚本 + fastlane（T16.5）
```

完整发布流程（签名、混淆、符号上传、CI 产物）见 [CI/CD 文档](cicd/CICD.md) 与新手向 [CI/CD 入门](cicd/BEGINNER_GUIDE.md)。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · Android minSdk 24 / JDK 17 · iOS 13.0 / CocoaPods · macOS。
