---
doc_type: implementation_guide
module_id: M15
priority: P0
status: implemented
spec_source: flutter_template_v3.md
spec_lines: "580-625"
tags: [env, flavor, dart-define, flutter_flavorizr, flutter_launcher_icons, flutter_gen, launch-json, M15]
related_code:
  - lib/core/env/env_config.dart
  - android/app/build.gradle.kts
  - flavorizr.yaml
  - env/
  - scripts/flutter-env.sh
  - .vscode/launch.json
---

# 多环境配置（M15）

> dev / staging / prod 三套环境：不同包名、AppName、API、开关。源码 `lib/core/env/`，
> 原生 flavor 在 `android/app/build.gradle.kts`，编译期常量在 `env/`。

## 1. 一图总览

| 维度 | dev | staging | prod |
|---|---|---|---|
| Dart 入口 | `lib/main_dev.dart` | `lib/main_staging.dart` | `lib/main_prod.dart` |
| Android flavor | `dev` | `staging` | `prod` |
| applicationId | `…app.dev` | `…app.staging` | `…app`（基础包名） |
| AppName | CCD Dev | CCD Staging | CCD |
| 日志 | 开 | 开 | 关 |
| 崩溃上报 | 关 | 开 | 开 |

## 2. 运行 / 构建

```bash
# 脚本（推荐）：自动带 --flavor + -t + --dart-define-from-file
scripts/flutter-env.sh dev run
scripts/flutter-env.sh prod build-apk

# 等价手写
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json
flutter build apk --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.json
```

> 加了 Android `productFlavors` 后，**所有原生构建/运行都必须带 `--flavor`**。
> `flutter test` 不构建原生，不受影响。

VSCode：直接选 `.vscode/launch.json` 里的 `dev (debug)` / `staging (debug)` / `prod (release)` 等配置。

## 3. EnvConfig（T15.1）

`EnvConfig` 把随环境变化的值收敛成不可变对象：

```dart
// UI 层
final env = ref.watch(envConfigProvider);   // baseUrl / flag / appName...
// 非 widget 层（拦截器、Service）
final env = getIt<EnvConfig>();
```

- `EnvConfig.defaults(env)`：每个环境的**非敏感默认值**（纯函数，可单测）。
- `EnvConfig.resolve(env)`：在默认值上叠加编译期 `--dart-define` 覆盖（见下）。
- 入口在 `bootstrap`/`main_showcase` 用 `registerEnvConfig(env)` 注册到 getIt，并
  `envConfigProvider.overrideWithValue(...)` 注入 Riverpod。

## 4. Dart Define 注入（T15.3）

敏感/可变值（API 地址、Sentry DSN）**不写进代码**，用编译期常量注入：

```bash
--dart-define-from-file=env/dev.json
```

`env/<env>.json`（含真实值）已被 `.gitignore`；仓库只提交 `env/<env>.example.json`
模板。首次使用：

```bash
cp env/dev.example.json env/dev.json   # 然后填真实值
```

支持键：`API_BASE_URL`、`SENTRY_DSN`、`APP_NAME`、`ENABLE_LOGGING`、
`ENABLE_CRASH_REPORTING`。未提供的键回退到 `EnvConfig.defaults`。

## 5. Flavor（T15.2）

### Android（已实现）
`android/app/build.gradle.kts` 的 `productFlavors` 定义 dev/staging/prod：
- `applicationIdSuffix` 改包名（三套可并存安装）
- `manifestPlaceholders["appName"]` → `AndroidManifest.xml` 的
  `android:label="${appName}"`

### flavorizr 配置
`flavorizr.yaml` 是 flavor 的声明式来源。**本项目未运行**
`dart run flutter_flavorizr`——其处理器会重写原生工程、覆盖既有手工配置（深链、
权限、CocoaPods 固定、启动页）。Android 已按它手工实现等价配置。

### iOS flavor（scheme + xcconfig，需 Xcode）
在全新工程可用 flavorizr 一次性生成；在本项目请手工：
1. Xcode 复制 Runner scheme 为 `dev`/`staging`/`prod`。
2. 为每个 flavor 建 `ios/Flutter/<flavor>.xcconfig`，设
   `PRODUCT_BUNDLE_IDENTIFIER` 与 `PRODUCT_NAME`。
3. Build Settings 按 scheme 关联对应 xcconfig。
4. `flutter run --flavor dev` 即按 scheme 名匹配。

## 6. 资源生成（T15.5）

| 工具 | 配置文件 | 说明 |
|---|---|---|
| flutter_gen | `pubspec.yaml` 顶层 `flutter_gen:` | `dart run build_runner build` → `lib/gen/assets.gen.dart`（类型安全资源引用） |
| flutter_launcher_icons | `flutter_launcher_icons-<flavor>.yaml` | 备好 `assets/flavorizr/<flavor>/icon.png` 后 `dart run flutter_launcher_icons -f <file>` |
| flutter_native_splash | `flutter_native_splash.yaml` | 多 flavor 可加 `flutter_native_splash-<flavor>.yaml` |

用法：`Assets.images.placeholder` 取代裸字符串路径。

## 7. 测试要点

- `EnvConfig.defaults/resolve/copyWith/==/toString(脱敏)`：纯函数单测
  （`test/core/env/env_config_test.dart`）。
- `envConfigProvider` 默认 dev、可被 override：ProviderContainer 单测。
- flavor：`flutter build apk --flavor dev` 能产出 APK。
