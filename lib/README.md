# `lib/` 目录结构说明

本目录是 `flutter_claude_app_v2` 模板的 Dart 源码根目录，采用 **Clean Architecture（分层）+ Feature-First（按业务垂直切分）** 的组合架构，遵循 [flutter_template_v3.md](/Users/ben/Downloads/flutter_template_v3.md) 第 4 节定义的目录规范。

T01.2 完成后，本目录共包含 **28 个叶子子目录**，每个叶子目录含一个 `.gitkeep` 占位文件。后续任务（T02.x 起）会按对应模块填充实际代码并删除 `.gitkeep`。

## 1. 架构分层概览

```
┌─────────────────────────────────────────────┐
│       Presentation Layer (UI + State)       │  features/*/presentation
│  Riverpod / go_router / Widget / Theme      │  shared/widgets
├─────────────────────────────────────────────┤
│            Domain Layer (业务核心)            │  features/*/domain
│   Entity / UseCase / Repository Interface   │
├─────────────────────────────────────────────┤
│         Data Layer (数据来源)                 │  features/*/data
│  Repository Impl / DataSource / Model       │
├─────────────────────────────────────────────┤
│      Core Infrastructure (基础设施)           │  core/
│  Network / Storage / DI / Error / Logger    │
└─────────────────────────────────────────────┘
```

依赖方向单向向下：`presentation → domain → data → core`。`core/` 不依赖任何业务层；`domain/` 不依赖 `data/`、`presentation/`、Flutter SDK（保持业务逻辑纯净，便于单测）。

## 2. 顶层结构

```
lib/
├── main.dart        # 入口（默认 Flutter 模板示例，M13/M15 改造为按环境多入口）
├── core/            # 基础设施层（不含业务）
├── shared/          # 跨 feature 复用资源（不含业务）
├── features/        # 业务模块（feature-first）
└── l10n/            # 国际化 ARB 文件
```

> 注：spec 第 4 节预留了 `app.dart`（根 Widget）和 `bootstrap.dart`（启动编排）两个文件，本任务 T01.2 不创建，留给 **M13 启动流程编排** 的 T13.1 / T13.2 实现，避免引入半成品代码。

## 3. `lib/core/` — 基础设施层（15 个子目录）

`lib/core/` 收录所有横跨业务的基础能力。每个子目录对应 spec 中一个独立模块（M），后续任务实施时直接落地到对应目录。

| 路径 | 用途 | 对应模块 |
|---|---|---|
| `core/di/` | 依赖注入配置（get_it + injectable 主入口、模块注册） | [M02](/Users/ben/Downloads/flutter_template_v3.md) |
| `core/network/` | 网络层（dio 实例、拦截器、错误转换、CancelToken 管理） | M04 |
| `core/storage/` | 本地存储（KeyValueStorage、SecureStorage、Hive/Isar） | M05 |
| `core/error/` | 错误体系（Exception、Failure、Result、全局异常捕获） | M03 |
| `core/router/` | 路由配置（go_router 主入口、守卫、深链接） | M07 |
| `core/theme/` | 主题与设计系统（Design Tokens、ThemeData、ThemeExtension） | M10 |
| `core/i18n/` | 国际化运行时（Locale Provider、语言切换、持久化） | M08 |
| `core/logger/` | 日志（分级输出、文件落盘、脱敏过滤） | M11 |
| `core/permission/` | 权限服务（PermissionService、平台差异封装） | M09 |
| `core/env/` | 多环境配置（Environment 枚举、EnvConfig、Dart Define） | M15 |
| `core/responsive/` | 多屏幕适配（Breakpoints、ResponsiveBuilder、字体缩放） | M12 |
| `core/analytics/` | 数据埋点（Analytics 接口、自动页面/曝光埋点） | M27 |
| `core/remote_config/` | 远程配置与 Feature Flag、Kill Switch | M28 |
| `core/ai/` | AI 能力抽象（LLM SDK 抽象层、流式响应） | M32 |
| `core/utils/` | 通用工具（不归类到上述模块的小工具） | — |

## 4. `lib/shared/` — 跨 feature 共享资源（3 个子目录）

`lib/shared/` 与 `lib/core/` 的区别：`core/` 是基础设施（运行时服务，有状态、有副作用），`shared/` 是 UI / 静态资源（无状态可复用）。

| 路径 | 用途 | 对应模块 |
|---|---|---|
| `shared/widgets/` | 通用 UI 组件（Loading / Empty / Error / AsyncValueWidget / AppImage / AppScaffold 等） | M14 |
| `shared/extensions/` | Dart / Flutter 类型的扩展方法（String、DateTime、BuildContext 等） | — |
| `shared/constants/` | 全局常量（图片名、动画时长、字号 token 等） | — |

## 5. `lib/features/` — 业务模块（feature-first + 三层）

`lib/features/` 按业务垂直切分，每个 feature 内部遵循 **data / domain / presentation** 三层结构。新增 feature 直接 copy 此目录骨架即可。

### 5.1 当前 feature 列表

| Feature | 状态 | 对应任务 |
|---|---|---|
| `features/auth/` | 占位 | T19.1 登录模块 |
| `features/home/` | 占位 | T19.2 首页模块 |
| `features/settings/` | 占位 | T19.4 设置页模块 |

T19.3（详情页）、T19.5（权限演示页）等后续 feature 会按相同结构追加。

### 5.2 单个 feature 内部分层

以 `features/auth/` 为例：

```
features/auth/
├── data/           # 数据层：DataSource、Model（含 JSON 序列化）、Repository 实现
├── domain/         # 领域层：Entity（纯 Dart）、Repository 接口、UseCase
└── presentation/   # 表现层：Page、Widget、Provider（Riverpod）
```

依赖规则：

- `presentation` 调用 `domain` 的 UseCase
- `domain` 定义 Repository 接口，由 `data` 提供实现
- `data` 通过 DI 注入到 `domain`，**`domain` 不引用 `data`**
- 三层均可使用 `core/` 与 `shared/`

## 6. `lib/l10n/` — 国际化资源

`lib/l10n/` 存放 ARB 文件（Application Resource Bundle）。T08.2 会生成 `app_zh.arb`、`app_en.arb` 等翻译文件，`flutter gen-l10n` 据此产出强类型访问类（`AppLocalizations`）。

## 7. 占位文件约定

T01.2 在每个叶子目录放置一个空的 `.gitkeep`，目的：

1. **保证空目录被 Git 追踪**（Git 默认不追踪空目录）
2. **为后续 IDE / RAG 索引提供锚点**

当一个叶子目录被实际代码填充时（如 T03.1 创建 `core/error/exceptions.dart`），应**同步删除该目录下的 `.gitkeep`**。规则：**只要目录内含任何 `.dart` 或资源文件，就移除 `.gitkeep`**。

## 8. 命名规范（feature 内部）

| 文件类型 | 命名模式 | 示例 |
|---|---|---|
| Page | `{feature}_page.dart` | `login_page.dart` |
| Widget | `{feature}_{widget}.dart` 或语义化 | `login_form.dart` |
| Provider | `{feature}_provider.dart` 或 `{feature}_notifier.dart` | `auth_notifier.dart` |
| Entity | `{entity}.dart` | `user.dart` |
| Model (DTO) | `{entity}_model.dart` | `user_model.dart` |
| Repository 接口 | `{feature}_repository.dart` | `auth_repository.dart` |
| Repository 实现 | `{feature}_repository_impl.dart` | `auth_repository_impl.dart` |
| DataSource | `{feature}_{remote\|local}_data_source.dart` | `auth_remote_data_source.dart` |
| UseCase | `{verb}_{noun}_use_case.dart` 或 `{verb}_{noun}.dart` | `login_use_case.dart` |

完整命名规范由 T20.4 `docs/CONVENTIONS.md` 集中定义。

## 9. 新增 feature 的步骤

未来新增业务 feature（以 `profile` 为例）：

```bash
mkdir -p lib/features/profile/{data,domain,presentation}
touch lib/features/profile/{data,domain,presentation}/.gitkeep
```

然后依次：

1. `domain/` 写 entity + repository 接口 + usecase
2. `data/` 写 model + datasource + repository 实现
3. 在 `core/di/` 注册依赖
4. `presentation/` 写 page + widget + provider
5. 在 `core/router/` 加路由
6. 删除该 feature 下的 `.gitkeep`

完整步骤由 T20.5 `docs/EXTEND_GUIDE.md` 集中定义。

---

**任务来源**: T01.2「搭建目录结构」（M01 P0）· **完成于**: 2026-05-18
**验证报告**: [docs/verification/T01.2.md](/Users/ben/ai_project/flutter_claude_app_v2/docs/verification/T01.2.md)
