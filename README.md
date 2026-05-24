# flutter_claude_app_v2

> 生产级、可直接商用的 Flutter 应用模板（脚手架）。内置依赖注入、错误处理、网络层、本地存储、状态管理、路由、国际化、权限、主题、日志监控、多屏适配、多环境、CI/CD、测试体系与安全规范，并附带一套可运行的示例业务模块（登录 / 首页 / 详情 / 设置 / 权限演示）。

![flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?logo=flutter)
![dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart)
![architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20Feature--First-success)
![lints](https://img.shields.io/badge/Lints-very__good__analysis-blue)

## 项目简介

`flutter_claude_app_v2` 是一个**开箱即用**的 Flutter 工程模板：把一个商业 App 上线前需要反复搭建的基础设施一次性做好，让你跳过「搭架子」直接写业务。

- **架构**：Clean Architecture + Feature-First（`domain` / `data` / `presentation` 三层）。
- **可运行**：`flutter run -t lib/main_dev.dart --flavor dev` 即可启动，含登录 → 首页 → 详情 → 设置 → 权限演示的完整闭环。
- **可验证**：每个原子任务都有验证报告（`docs/verification/`），命令输出真实可复现。
- **可扩展**：新增 feature / 语言 / 权限 / 环境都有标准步骤（见 [扩展指南](docs/EXTEND_GUIDE.md)）。

## 特性清单

| 模块 | 能力 | 关键技术 |
|---|---|---|
| M02 依赖注入 | 编译期 DI、按环境注册 | `get_it` + `injectable` |
| M02 数据建模 | 不可变模型 + JSON 序列化 | `freezed` + `json_serializable` |
| M03 错误处理 | `Exception → Failure → Result<T>` 归一化 + 全局兜底 | sealed class + `runZonedGuarded` |
| M04 网络层 | Dio 实例 + 4 个拦截器 + Retrofit + 取消/重试/SSL Pinning | `dio` + `retrofit` |
| M05 本地存储 | KV / 安全存储 / 数据库 + Schema 版本管理 | `shared_preferences` + `flutter_secure_storage` + `hive_ce` |
| M06 状态管理 | Provider 示例集 + Observer + UseCase 联动 | `flutter_riverpod`（手写 Provider 模式） |
| M07 路由 | 类型安全路由 + Shell 嵌套 + 守卫 + 深链接 + 404 + 动画 | `go_router` + `go_router_builder` |
| M08 国际化 | en/zh + 复数/占位符/日期/货币 + 运行时切换 + 持久化 | `flutter_localizations` + `intl` |
| M09 权限 | 统一三态接口 + 永久拒绝引导 + iOS/Android 差异封装 | `permission_handler` |
| M10 主题 | Design Tokens + 亮/暗 + ThemeExtension + 切换持久化 | Material 3 |
| M11 日志监控 | 分级日志 + 落盘切割 + 脱敏 + Sentry + 性能埋点 | `logger` + `sentry_flutter` |
| M12 多屏适配 | 断点系统 + ResponsiveBuilder + 折叠屏 + 安全区 + 横竖屏 | `MediaQuery` / `LayoutBuilder` |
| M13 启动编排 | `bootstrap` 关键/非关键路径 + 多环境入口 + 原生启动页 | `runZonedGuarded` + `flutter_native_splash` |
| M14 通用 UI 组件 | 状态组件 / AsyncValueWidget / 图片 / 刷新分页 / Toast / BottomSheet / 键盘 / Scaffold | 自研组件库 |
| M15 多环境 | EnvConfig + 三套 flavor + Dart Define 注入 + VSCode 配置 | `--dart-define-from-file` |
| M16 代码质量 / CI/CD | very_good_analysis + lefthook + GitHub Actions + 打包脚本 + 混淆 | `lefthook` + Actions |
| M17 测试体系 | 单元 / Widget / 集成测试 + mocktail + 覆盖率 | `flutter_test` + `mocktail` |
| M18 安全规范 | 敏感配置外部化 + 网络安全 + ATS + 防截屏 + Root/越狱检测 + 检查清单 | MethodChannel + 原生 |
| M19 示例业务 | 登录 / 首页 / 详情 / 设置 / 权限演示（端到端串联前述全部模块） | 全栈示例 |

> 进度与逐任务报告见 [验证报告索引](docs/verification/README.md)（已完成 M01–M19，共 ~110 个原子任务）。

## 快速开始

```bash
# 1. 安装依赖
flutter pub get

# 2. 生成代码（DI / freezed / json / retrofit / 路由 / 资源）
dart run build_runner build --delete-conflicting-outputs

# 3. 准备开发环境变量（从模板复制，本地填值，已被 .gitignore）
cp env/dev.example.json env/dev.json

# 4. 运行（dev flavor）
flutter run -t lib/main_dev.dart --flavor dev --dart-define-from-file=env/dev.json
# 或用封装脚本：
scripts/flutter-env.sh dev run
```

> 第一次跑不通？先看 [GETTING_STARTED](docs/GETTING_STARTED.md) 与 [TROUBLESHOOTING](docs/TROUBLESHOOTING.md)。

## 多环境运行

模板内置 `dev` / `staging` / `prod` 三套环境（独立包名 / AppName / 图标 / 编译期常量）：

```bash
scripts/flutter-env.sh dev run             # 开发
scripts/flutter-env.sh staging build-apk   # 预发 APK
scripts/flutter-env.sh prod build-appbundle# 生产 AAB
```

机制：`--flavor <env>`（原生 flavor）+ `-t lib/main_<env>.dart`（Dart 入口）+ `--dart-define-from-file=env/<env>.json`（敏感常量）。详见 [多环境配置](docs/env/ENVIRONMENTS.md)。

## 项目结构

```
lib/
├── main_{dev,staging,prod}.dart  # 三套环境入口 → bootstrap(AppEnvironment.x)
├── main_showcase.dart            # 组件画廊入口
├── bootstrap.dart                # 统一启动编排（关键/非关键路径）
├── app.dart                      # MaterialApp.router 装配（主题/i18n/路由）
├── core/                         # 跨 feature 的基础设施
│   ├── di/ error/ network/ storage/ router/ i18n/ permission/
│   ├── theme/ logger/ responsive/ env/ security/ observer/ ...
├── shared/                       # 通用 UI 组件、扩展、工具
│   └── widgets/ extensions/ utils/ constants/
├── features/                     # 业务模块（Feature-First）
│   ├── auth/ home/ detail/ settings/ permission_demo/   # M19 示例业务
│   └── examples/ showcase/                              # 演示/画廊
├── l10n/                         # ARB + 生成的 AppLocalizations
└── gen/                          # flutter_gen 生成的资源引用
```

分层职责与数据流见 [架构文档](docs/ARCHITECTURE.md)。

## 测试与质量

```bash
flutter analyze                       # 静态分析（very_good_analysis，0 issue）
flutter test                          # 单元 + Widget 测试（host 运行）
flutter test --coverage               # 带覆盖率
scripts/coverage.sh                   # 生成覆盖率摘要
flutter test integration_test/login_flow_test.dart   # 端到端（flutter_tester）
```

提交前 [lefthook](lefthook.yml) 自动执行 `dart format` + `flutter analyze`，并校验 Conventional Commits；CI（[.github/workflows/ci.yml](.github/workflows/ci.yml)）跑格式/分析/测试/codegen 一致性，push 到 `main` 额外构建 prod AAB。详见 [CI/CD 文档](docs/cicd/CICD.md)。

## 文档导航

| 文档 | 内容 |
|---|---|
| [GETTING_STARTED](docs/GETTING_STARTED.md) | 环境准备、依赖安装、多环境运行 |
| [ARCHITECTURE](docs/ARCHITECTURE.md) | 架构图、分层职责、数据流 |
| [CONVENTIONS](docs/CONVENTIONS.md) | 命名规范、代码风格、Git 提交规范 |
| [EXTEND_GUIDE](docs/EXTEND_GUIDE.md) | 新增 feature / 语言 / 权限 / 环境 |
| [TROUBLESHOOTING](docs/TROUBLESHOOTING.md) | build_runner / iOS Pod / 常见报错 |
| [ADR](docs/adr/README.md) | 架构决策记录（模板 + 示例） |
| [多环境](docs/env/ENVIRONMENTS.md) · [CI/CD](docs/cicd/CICD.md) · [测试](docs/testing/TESTING.md) · [安全](docs/security/SECURITY.md) | 模块专题 |
| [权限](docs/permission/PERMISSIONS.md) · [响应式](docs/responsive/RESPONSIVE.md) · [深链接](docs/router/DEEP_LINKING.md) · [SSL Pinning](docs/network/SSL_PINNING.md) | 模块专题 |
| [验证报告索引](docs/verification/README.md) | 每个原子任务的验收报告 |

## 环境要求

- Flutter **3.41.9**（Dart **3.11.5**），Dart SDK 约束 `^3.11.5`
- Android `minSdk=24`，iOS `13.0`
- iOS 固定 CocoaPods（关闭 SPM，原因见 `pubspec.yaml` 注释）

## 许可

本模板用于内部脚手架，`publish_to: 'none'`（不发布到 pub.dev）。
