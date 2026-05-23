# Flutter 应用模板项目需求 v3

> 生产级、商业可上线、可长期维护的 Flutter 应用脚手架完整规格文档
> 版本：v3 | 最后更新：2026-05-18

---

## 文档结构说明

本文档分为五部分：

- **第一部分**：项目总览与技术决策
- **第二部分**：完整模块清单（按 P0/P1/P2 优先级组织）
- **第三部分**：可执行任务拆解（每个任务可独立交付，便于排期与进度跟踪）
- **第四部分**：任务统计与排期建议
- **第五部分**：交付检查清单

---

# 第一部分：项目总览

## 1. 项目目标

搭建一个**生产级、商业可上线、可长期维护**的 Flutter 应用脚手架，目标是：

- 新业务项目可在 1 天内基于模板启动开发
- 覆盖从开发、测试、构建、发布、监控、合规的完整链路
- 适配多端形态（手机 / 平板 / 折叠屏 / 桌面 / Web）
- 满足国内外应用市场合规要求

## 2. 平台与环境

| 项 | 规格 |
|---|---|
| Flutter SDK | 3.x 最新稳定版（3.24+） |
| Dart | 3.x |
| Android | minSdk 24，targetSdk 34，Kotlin DSL |
| iOS | 最低 13.0，Swift |
| 平板 | iPad / Android Tablet 适配 |
| 折叠屏 | 支持铰链布局 |
| 桌面 | 可选支持 Windows / macOS / Linux |
| Web | 可选支持 |

## 3. 总体架构图

```
┌─────────────────────────────────────────────┐
│       Presentation Layer (UI + State)       │
│  Riverpod / go_router / Widget / Theme      │
├─────────────────────────────────────────────┤
│            Domain Layer (业务核心)            │
│   Entity / UseCase / Repository Interface   │
├─────────────────────────────────────────────┤
│         Data Layer (数据来源)                 │
│  Repository Impl / DataSource / Model       │
├─────────────────────────────────────────────┤
│      Core Infrastructure (基础设施)           │
│  Network / Storage / DI / Error / Logger    │
├─────────────────────────────────────────────┤
│         Platform Channel (原生互操作)         │
│       MethodChannel / Pigeon / Native       │
└─────────────────────────────────────────────┘
```

## 4. 项目目录结构

```
lib/
├── main.dart                    # 入口（按环境多个 main_dev/staging/prod）
├── app.dart                     # 根 Widget
├── bootstrap.dart               # 启动初始化编排
├── core/                        # 基础设施层
│   ├── di/                      # 依赖注入配置
│   ├── network/                 # 网络层（dio、拦截器、错误转换）
│   ├── storage/                 # 本地存储（secure storage、缓存）
│   ├── error/                   # Failure、Exception 体系
│   ├── router/                  # 路由配置
│   ├── theme/                   # 主题
│   ├── i18n/                    # 国际化
│   ├── logger/                  # 日志
│   ├── permission/              # 权限服务
│   ├── env/                     # 环境配置
│   ├── responsive/              # 多屏幕适配
│   ├── analytics/               # 数据埋点
│   ├── remote_config/           # 远程配置
│   ├── ai/                      # AI 能力抽象
│   └── utils/                   # 通用工具
├── shared/                      # 跨 feature 共享
│   ├── widgets/                 # 通用组件（loading、empty、error 等）
│   ├── extensions/              # 扩展方法
│   └── constants/               # 常量
├── features/                    # 业务模块（每个 feature 内部分层）
│   ├── auth/
│   │   ├── data/                # datasource、model、repository 实现
│   │   ├── domain/              # entity、repository 接口、usecase
│   │   └── presentation/        # page、widget、provider
│   ├── home/
│   └── settings/
└── l10n/                        # ARB 文件
```

---

# 第二部分：完整模块清单

## 模块总览

| 模块 ID | 模块名 | 优先级 |
|---|---|---|
| M01 | 项目骨架与目录结构 | P0 |
| M02 | 依赖注入与数据建模 | P0 |
| M03 | 错误处理体系 | P0 |
| M04 | 网络层 | P0 |
| M05 | 本地存储 | P0 |
| M06 | 状态管理 | P0 |
| M07 | 路由管理 | P0 |
| M08 | 国际化 | P0 |
| M09 | 权限管理 | P0 |
| M10 | 主题与设计系统 | P0 |
| M11 | 日志与监控 | P0 |
| M12 | 多屏幕适配 | P0 |
| M13 | 启动流程编排 | P0 |
| M14 | 通用 UI 组件 | P0 |
| M15 | 多环境配置 | P0 |
| M16 | 代码质量与 CI/CD | P0 |
| M17 | 测试体系 | P0 |
| M18 | 安全规范 | P0 |
| M19 | 示例业务模块 | P0 |
| M20 | 文档交付 | P0 |
| M21 | 性能优化体系 | P1 |
| M22 | 无障碍（a11y） | P1 |
| M23 | 应用内更新 | P1 |
| M24 | 隐私合规 | P1 |
| M25 | 离线优先架构 | P1 |
| M26 | 原生互操作 | P1 |
| M27 | 数据埋点 | P1 |
| M28 | 远程配置与 Feature Flag | P1 |
| M29 | 内置 Debug 面板 | P1 |
| M30 | 桌面 / Web 适配 | P2 |
| M31 | 灰度发布与 A/B Test | P2 |
| M32 | AI 能力集成预留 | P2 |
| M33 | 组件库 Storybook | P2 |
| M34 | 动效系统 | P2 |

---

# 第三部分：可执行任务拆解

> **任务拆解原则**：每个任务（Task）应满足
> - 可在 0.5 ~ 2 天内独立完成
> - 有明确的交付物（代码 / 文档 / 配置）
> - 有明确的验收标准
> - 尽量减少跨任务依赖

---

## M01 项目骨架与目录结构 [P0]

### T01.1 初始化 Flutter 项目
- [ ] 创建 Flutter 项目，配置 Android / iOS 双端
- [ ] 设置 minSdk、targetSdk、iOS 部署版本
- [ ] 配置 Kotlin DSL（Android）、Swift（iOS）
- **交付物**：可运行的空项目
- **验收**：Android / iOS 双端能运行

### T01.2 搭建目录结构
- [ ] 创建 `core/`、`shared/`、`features/`、`l10n/` 目录
- [ ] 创建各子目录占位文件
- [ ] 编写目录结构说明
- **交付物**：完整目录树 + README
- **验收**：目录结构符合 feature-first + 分层规范

### T01.3 配置 .gitignore 与 .gitattributes
- [ ] Flutter 标准 gitignore
- [ ] 补充 IDE、临时文件、生成产物的忽略规则
- [ ] 配置 .gitattributes（换行符、二进制文件）
- **交付物**：`.gitignore`、`.gitattributes`

---

## M02 依赖注入与数据建模 [P0]

### T02.1 集成 get_it + injectable
- [ ] 添加依赖
- [ ] 创建 `core/di/injection.dart` 主入口
- [ ] 配置 build_runner
- **交付物**：DI 主入口 + 配置脚本
- **验收**：`dart run build_runner build` 成功生成代码

### T02.2 集成 freezed + json_serializable
- [ ] 添加依赖
- [ ] 编写示例 Model（带 JSON 序列化）
- [ ] 编写示例 Entity（纯 Dart）
- **交付物**：示例 Model + Entity + Mapper

### T02.3 编写 DI 注册示例
- [ ] 演示 Singleton / LazySingleton / Factory 三种注册
- [ ] 演示按环境注册不同实现
- [ ] 编写测试场景下替换依赖的示例
- **交付物**：DI 示例代码 + 文档

---

## M03 错误处理体系 [P0]

### T03.1 定义 Exception 体系
- [ ] 定义 NetworkException、ServerException、CacheException、UnauthorizedException 等
- [ ] 每个 Exception 携带 code、message、stackTrace
- **交付物**：`core/error/exceptions.dart`

### T03.2 定义 Failure 体系
- [ ] 用 freezed sealed class 定义 Failure
- [ ] 包含 NetworkFailure、ServerFailure、ValidationFailure、UnknownFailure
- **交付物**：`core/error/failures.dart`

### T03.3 定义 Result 类型
- [ ] 使用 dartz 的 Either 或自定义 Result<T>
- [ ] 提供常用扩展方法（fold、map、flatMap）
- **交付物**：`core/error/result.dart`

### T03.4 实现 Exception → Failure 转换器
- [ ] 统一转换工具类
- **交付物**：`core/error/error_mapper.dart` + 单元测试

### T03.5 注册全局异常捕获
- [ ] FlutterError.onError
- [ ] PlatformDispatcher.instance.onError
- [ ] runZonedGuarded
- [ ] Isolate 异常监听
- **交付物**：`core/error/global_error_handler.dart`

---

## M04 网络层 [P0]

### T04.1 配置 dio 基础实例
- [ ] BaseUrl 来自环境配置
- [ ] 超时分级配置（connect / receive / send）
- **交付物**：`core/network/dio_client.dart`

### T04.2 实现 LogInterceptor
- [ ] 开发环境格式化输出
- [ ] 生产环境关闭
- [ ] 敏感字段脱敏过滤
- **交付物**：`core/network/interceptors/log_interceptor.dart`

### T04.3 实现 AuthInterceptor
- [ ] 自动注入 Token
- [ ] 401 触发刷新 Token
- [ ] 刷新期间挂起其他请求
- [ ] 刷新失败强制登出
- **交付物**：`core/network/interceptors/auth_interceptor.dart` + 单元测试

### T04.4 实现 ErrorInterceptor
- [ ] HTTP 错误码 → Exception
- [ ] 业务错误码 → Exception
- **交付物**：`core/network/interceptors/error_interceptor.dart`

### T04.5 实现 RetryInterceptor
- [ ] 网络抖动自动重试
- [ ] 指数退避策略
- [ ] 可配置重试次数
- **交付物**：`core/network/interceptors/retry_interceptor.dart`

### T04.6 集成 retrofit
- [ ] 定义示例 ApiService 接口
- [ ] 配置 build_runner
- **交付物**：示例 API 接口

### T04.7 封装 CancelToken 管理
- [ ] 页面销毁自动取消请求
- [ ] 与 Riverpod autoDispose 联动
- **交付物**：`core/network/cancel_token_manager.dart`

### T04.8 统一响应解包
- [ ] 后端标准结构（code/message/data）自动解包
- **交付物**：`core/network/response_wrapper.dart`

### T04.9 SSL Pinning（可选）
- [ ] 证书固定示例
- [ ] 开关控制
- **交付物**：配置说明文档

---

## M05 本地存储 [P0]

### T05.1 封装 SharedPreferences
- [ ] 抽象 KeyValueStorage 接口
- [ ] SharedPreferences 实现
- **交付物**：`core/storage/key_value_storage.dart`

### T05.2 封装 flutter_secure_storage
- [ ] 用于 Token、敏感数据
- [ ] 抽象 SecureStorage 接口
- **交付物**：`core/storage/secure_storage.dart`

### T05.3 集成 Hive / Isar
- [ ] 选择方案并配置
- [ ] 编写示例 Box / Collection
- **交付物**：`core/storage/database/`

### T05.4 数据库 Schema 版本管理
- [ ] Migration 机制示例
- **交付物**：迁移示例代码 + 文档

---

## M06 状态管理 [P0]

### T06.1 集成 Riverpod
- [ ] flutter_riverpod + riverpod_annotation + riverpod_generator
- [ ] ProviderScope 配置
- **交付物**：基础配置

### T06.2 编写 Provider 示例集
- [ ] 同步 Provider
- [ ] FutureProvider（异步三态）
- [ ] AsyncNotifier
- [ ] StateNotifier
- [ ] 组合 Provider
- [ ] autoDispose 示例
- **交付物**：`features/examples/providers_demo/`

### T06.3 实现 ProviderObserver
- [ ] 全局状态变更日志
- [ ] 接入 Logger
- **交付物**：`core/observer/provider_observer.dart`

### T06.4 UseCase 与 Provider 联动示例
- [ ] 演示 Domain 层 UseCase 在 Provider 中调用
- [ ] 处理 Either<Failure, T> 返回值
- **交付物**：完整示例

---

## M07 路由管理 [P0]

### T07.1 集成 go_router
- [ ] 基础路由配置
- [ ] 路由表集中管理
- **交付物**：`core/router/app_router.dart`

### T07.2 类型安全路由
- [ ] go_router_builder 配置
- [ ] 路由参数类型安全示例
- **交付物**：类型安全路由示例

### T07.3 嵌套路由 + Shell
- [ ] 底部导航 ShellRoute
- [ ] 各 Tab 内部子路由
- **交付物**：完整底部导航示例

### T07.4 路由守卫
- [ ] 登录拦截
- [ ] 权限拦截
- [ ] redirect 实现
- **交付物**：路由守卫代码 + 文档

### T07.5 深链接配置
- [ ] Android intent-filter
- [ ] iOS associated domains
- [ ] Universal Links 处理
- **交付物**：原生配置 + Flutter 处理代码

### T07.6 404 与错误页
- [ ] errorBuilder 配置
- [ ] 统一错误页 UI
- **交付物**：404 页面

### T07.7 路由切换动画
- [ ] 自定义 transition 示例
- **交付物**：动画示例

### T07.8 路由日志观察者
- [ ] 接入 Logger
- **交付物**：路由观察者代码

---

## M08 国际化 [P0]

### T08.1 配置 flutter_localizations + intl
- [ ] 添加依赖
- [ ] 配置 ARB 文件结构
- **交付物**：基础配置

### T08.2 编写 ARB 文件
- [ ] 中文简体（zh_CN）
- [ ] 英文（en_US）
- [ ] 涵盖常用 key（按钮、提示、错误等）
- **交付物**：`l10n/app_zh.arb`、`l10n/app_en.arb`

### T08.3 复杂场景示例
- [ ] 复数（plural）
- [ ] 占位符（placeholder）
- [ ] 日期 / 数字格式化
- **交付物**：示例代码

### T08.4 运行时语言切换
- [ ] 用 Riverpod 管理 Locale
- [ ] 切换后立即生效
- **交付物**：语言切换功能

### T08.5 语言选择持久化
- [ ] 写入 SharedPreferences
- [ ] 启动时读取
- [ ] 首次启动跟随系统语言
- **交付物**：完整持久化逻辑

### T08.6 新增语言文档
- [ ] 编写 EXTEND_GUIDE 章节
- **交付物**：扩展文档

---

## M09 权限管理 [P0]

### T09.1 封装 PermissionService
- [ ] 统一权限请求接口
- [ ] 返回三态结果（granted / denied / permanentlyDenied）
- **交付物**：`core/permission/permission_service.dart`

### T09.2 覆盖常用权限
- [ ] 相机、相册、麦克风、定位、通知、存储、蓝牙
- [ ] 各权限的请求示例
- **交付物**：各权限示例代码

### T09.3 永久拒绝处理
- [ ] 引导用户至系统设置页
- [ ] 二次说明弹窗
- **交付物**：引导 UI + 工具方法

### T09.4 iOS / Android 差异封装
- [ ] 处理两端权限名差异
- [ ] Info.plist / AndroidManifest 配置
- **交付物**：原生配置 + 差异说明文档

---

## M10 主题与设计系统 [P0]

### T10.1 定义 Design Tokens
- [ ] 颜色 token（语义化命名）
- [ ] 字号 token
- [ ] 间距 token
- [ ] 圆角 token
- [ ] 阴影 token
- [ ] 动效 token（曲线 + 时长）
- **交付物**：`core/theme/tokens/`

### T10.2 构建 ThemeData
- [ ] 亮色主题
- [ ] 暗色主题
- [ ] ColorScheme 配置
- **交付物**：`core/theme/app_theme.dart`

### T10.3 自定义 ThemeExtension
- [ ] 业务色（成功、警告等）
- [ ] 业务特有 token
- **交付物**：ThemeExtension 示例

### T10.4 主题切换
- [ ] 用 Riverpod 管理 ThemeMode
- [ ] 跟随系统 / 亮色 / 暗色 三选一
- [ ] 持久化用户选择
- **交付物**：主题切换功能

### T10.5 状态栏样式适配
- [ ] 随主题切换状态栏图标颜色
- [ ] AnnotatedRegion 封装
- **交付物**：状态栏工具

---

## M11 日志与监控 [P0]

### T11.1 集成 logger
- [ ] 分级输出（v/d/i/w/e）
- [ ] 开发 / 生产环境策略
- **交付物**：`core/logger/app_logger.dart`

### T11.2 日志文件落盘
- [ ] 按日期切割
- [ ] 自动清理过期日志
- [ ] 文件大小限制
- **交付物**：文件输出器

### T11.3 敏感字段脱敏
- [ ] token / password / phone 等过滤
- [ ] 可配置规则
- **交付物**：脱敏过滤器

### T11.4 集成 Sentry
- [ ] 自动上报未捕获异常
- [ ] 环境标签区分
- [ ] 用户行为面包屑
- **交付物**：Sentry 配置 + 初始化代码

### T11.5 性能监控埋点
- [ ] 页面加载时间
- [ ] 接口耗时
- **交付物**：性能监控工具

---

## M12 多屏幕适配 [P0]

### T12.1 定义断点系统
- [ ] mobile（< 600）
- [ ] tablet（600 ~ 1024）
- [ ] desktop（1024 ~ 1440）
- [ ] large desktop（> 1440）
- **交付物**：`core/responsive/breakpoints.dart`

### T12.2 实现 ResponsiveBuilder
- [ ] 根据断点返回不同布局
- [ ] LayoutBuilder + MediaQuery 封装
- **交付物**：`core/responsive/responsive_builder.dart`

### T12.3 字体缩放策略
- [ ] textScaleFactor 上下限
- [ ] MediaQuery 包装
- **交付物**：字体缩放工具

### T12.4 平板 Master-Detail 布局
- [ ] 双栏布局示例
- [ ] NavigationRail 替代底部 Tab
- **交付物**：平板布局示例页

### T12.5 折叠屏支持
- [ ] displayFeatures 处理
- [ ] 铰链区域避让
- **交付物**：折叠屏示例

### T12.6 安全区域处理
- [ ] SafeArea 规范
- [ ] 异形屏适配
- [ ] Home Indicator 避让
- **交付物**：安全区域工具 + 文档

### T12.7 横竖屏处理
- [ ] 横竖屏切换状态保留
- [ ] 锁定方向工具
- **交付物**：屏幕方向工具

---

## M13 启动流程编排 [P0]

### T13.1 编写 bootstrap.dart
- [ ] 统一启动入口
- [ ] 按顺序初始化各模块
- **交付物**：`bootstrap.dart`

### T13.2 多环境入口
- [ ] main_dev.dart
- [ ] main_staging.dart
- [ ] main_prod.dart
- **交付物**：三个入口文件

### T13.3 异步并行初始化优化
- [ ] 拆分关键路径与非关键路径
- [ ] 非关键依赖延迟初始化
- **交付物**：优化后的 bootstrap

### T13.4 原生启动页配置
- [ ] flutter_native_splash 集成
- [ ] Android / iOS 启动页与 Flutter 启动页衔接
- **交付物**：启动页配置

### T13.5 App 生命周期监听
- [ ] AppLifecycleState 处理
- [ ] 前后台切换钩子
- [ ] 内存警告处理
- **交付物**：`core/lifecycle/app_lifecycle.dart`

---

## M14 通用 UI 组件 [P0]

### T14.1 状态组件集
- [ ] LoadingWidget（全屏 / 局部 / 骨架屏）
- [ ] EmptyWidget
- [ ] ErrorWidget
- [ ] NetworkErrorWidget
- **交付物**：`shared/widgets/states/`

### T14.2 异步状态封装
- [ ] AsyncValueWidget：处理 AsyncValue 三态
- **交付物**：通用异步组件

### T14.3 图片组件
- [ ] 封装 cached_network_image
- [ ] 占位图 / 错误图
- [ ] 圆角扩展
- **交付物**：`shared/widgets/app_image.dart`

### T14.4 下拉刷新 / 上拉加载
- [ ] 封装 easy_refresh 或 pull_to_refresh
- [ ] 与 Riverpod 联动
- **交付物**：刷新组件 + 列表示例

### T14.5 Toast / Dialog 工具
- [ ] 脱离 BuildContext 调用
- [ ] 统一样式
- **交付物**：`shared/utils/overlay_utils.dart`

### T14.6 BottomSheet 工具
- [ ] 统一样式
- [ ] 支持拖拽关闭
- **交付物**：BottomSheet 工具

### T14.7 键盘处理
- [ ] 点击空白收起
- [ ] 智能避让
- **交付物**：键盘工具

### T14.8 统一 Scaffold 封装
- [ ] AppScaffold 含默认 AppBar
- [ ] 支持加载状态
- **交付物**：`shared/widgets/app_scaffold.dart`

---

## M15 多环境配置 [P0]

### T15.1 定义环境模型
- [ ] Environment 枚举（dev/staging/prod）
- [ ] EnvConfig 数据类
- **交付物**：`core/env/env_config.dart`

### T15.2 配置 flutter_flavorizr
- [ ] 三套 flavor 配置
- [ ] 不同 AppId、AppName、Icon
- **交付物**：flavorizr 配置文件

### T15.3 Dart Define 注入
- [ ] 编译时常量注入示例
- [ ] 敏感配置不入代码库
- **交付物**：构建脚本 + 文档

### T15.4 VSCode launch.json
- [ ] 三套环境启动配置
- **交付物**：`.vscode/launch.json`

### T15.5 资源生成
- [ ] flutter_launcher_icons 配置（三套 icon）
- [ ] flutter_native_splash 配置
- [ ] flutter_gen 配置
- **交付物**：配置文件

---

## M16 代码质量与 CI/CD [P0]

### T16.1 配置 analysis_options
- [ ] 基于 very_good_analysis
- [ ] 自定义规则补充
- **交付物**：`analysis_options.yaml`

### T16.2 配置 Git Hooks
- [ ] 集成 lefthook
- [ ] pre-commit：format + analyze
- [ ] commit-msg：Conventional Commits 校验
- **交付物**：`lefthook.yml`

### T16.3 GitHub Actions CI
- [ ] PR：format check + analyze + test
- [ ] main 分支：构建产物
- **交付物**：`.github/workflows/ci.yml`

### T16.4 Android 打包脚本
- [ ] 多 flavor 打包
- [ ] 签名配置
- **交付物**：`scripts/build_android.sh`

### T16.5 iOS 打包脚本
- [ ] fastlane 配置
- [ ] TestFlight 上传
- **交付物**：`scripts/build_ios.sh` + Fastfile

### T16.6 代码混淆配置
- [ ] Android ProGuard / R8 规则
- [ ] iOS symbol 上传
- **交付物**：混淆配置文件 + 文档

### T16.7 PR / Issue 模板
- [ ] `.github/pull_request_template.md`
- [ ] `.github/ISSUE_TEMPLATE/`
- **交付物**：模板文件

---

## M17 测试体系 [P0]

### T17.1 单元测试示例
- [ ] UseCase 测试
- [ ] Repository 测试（mock DataSource）
- [ ] Mapper 测试
- **交付物**：`test/` 目录示例

### T17.2 集成 mocktail
- [ ] 配置依赖
- [ ] 编写 mock 示例
- **交付物**：mock 工具类

### T17.3 Widget 测试示例
- [ ] 核心组件测试
- [ ] Provider 注入测试
- **交付物**：Widget 测试示例

### T17.4 集成测试示例
- [ ] 登录流程端到端
- **交付物**：`integration_test/`

### T17.5 覆盖率配置
- [ ] lcov 配置
- [ ] CI 报告生成
- **交付物**：覆盖率脚本

### T17.6 Golden 测试（可选）
- [ ] golden_toolkit 配置
- [ ] 示例
- **交付物**：Golden 测试示例

---

## M18 安全规范 [P0]

### T18.1 敏感配置外部化
- [ ] API Key 通过 --dart-define 注入
- [ ] envied 集成（可选）
- **交付物**：配置示例 + 文档

### T18.2 Android 网络安全配置
- [ ] network_security_config.xml
- **交付物**：Android 安全配置

### T18.3 iOS ATS 配置
- [ ] Info.plist 配置
- **交付物**：iOS 安全配置

### T18.4 防截屏（可选）
- [ ] 敏感页面禁用截屏
- **交付物**：防截屏工具

### T18.5 Root / 越狱检测（可选）
- [ ] 检测工具集成
- **交付物**：检测工具

### T18.6 安全检查清单
- [ ] 上线前安全 checklist
- **交付物**：`docs/SECURITY_CHECKLIST.md`

---

## M19 示例业务模块 [P0]

### T19.1 登录模块
- [ ] 表单校验
- [ ] 网络请求
- [ ] Token 存储
- [ ] 路由跳转
- [ ] 错误处理
- **交付物**：`features/auth/`

### T19.2 首页模块
- [ ] 底部 Tab 嵌套路由
- [ ] 列表加载
- [ ] 下拉刷新 + 分页
- **交付物**：`features/home/`

### T19.3 详情页模块
- [ ] 路由参数传递
- [ ] 异步数据加载
- [ ] AsyncValue 三态
- **交付物**：`features/detail/`

### T19.4 设置页模块
- [ ] 语言切换
- [ ] 主题切换
- [ ] 退出登录
- [ ] 账户注销入口
- **交付物**：`features/settings/`

### T19.5 权限演示页
- [ ] 各权限请求
- [ ] 永久拒绝引导
- **交付物**：`features/permission_demo/`

---

## M20 文档交付 [P0]

### T20.1 README.md
- [ ] 项目简介
- [ ] 特性清单
- [ ] 快速开始
- **交付物**：`README.md`

### T20.2 GETTING_STARTED.md
- [ ] 环境准备
- [ ] 依赖安装
- [ ] 多环境运行命令
- **交付物**：`docs/GETTING_STARTED.md`

### T20.3 ARCHITECTURE.md
- [ ] 架构图
- [ ] 分层职责
- [ ] 数据流图
- **交付物**：`docs/ARCHITECTURE.md`

### T20.4 CONVENTIONS.md
- [ ] 命名规范
- [ ] 代码风格
- [ ] Git 提交规范
- **交付物**：`docs/CONVENTIONS.md`

### T20.5 EXTEND_GUIDE.md
- [ ] 新增 feature 步骤
- [ ] 新增语言步骤
- [ ] 新增权限步骤
- [ ] 新增环境步骤
- **交付物**：`docs/EXTEND_GUIDE.md`

### T20.6 TROUBLESHOOTING.md
- [ ] build_runner 问题
- [ ] iOS Pod 问题
- [ ] 常见报错
- **交付物**：`docs/TROUBLESHOOTING.md`

### T20.7 ADR 模板
- [ ] 架构决策记录模板
- [ ] 至少 1 个示例 ADR
- **交付物**：`docs/adr/`

---

## M21 性能优化体系 [P1]

### T21.1 启动耗时埋点
- [ ] 各阶段耗时记录
- [ ] 首帧时间
- **交付物**：启动埋点工具

### T21.2 渲染优化规范
- [ ] const 规范
- [ ] RepaintBoundary 使用指南
- [ ] Selector 精准订阅示例
- **交付物**：`docs/PERFORMANCE.md`

### T21.3 列表性能优化
- [ ] 长列表分页示例
- [ ] itemExtent 优化
- **交付物**：高性能列表示例

### T21.4 图片性能
- [ ] 缩略图与原图分离
- [ ] 内存缓存控制
- **交付物**：图片优化配置

### T21.5 包体积优化
- [ ] ABI 拆分
- [ ] 资源压缩
- [ ] 字体子集化
- [ ] 未使用资源检测脚本
- **交付物**：优化配置 + 脚本

### T21.6 DevTools 使用指南
- [ ] Performance / Memory / CPU 使用文档
- **交付物**：`docs/DEVTOOLS_GUIDE.md`

---

## M22 无障碍（a11y） [P1]

### T22.1 Semantics 规范
- [ ] 关键组件添加 Semantics
- [ ] 语义标签规范
- **交付物**：a11y 规范文档

### T22.2 颜色对比度检查
- [ ] 设计 Token 满足 WCAG AA
- [ ] 检查工具集成
- **交付物**：对比度检查报告

### T22.3 最小点击区域
- [ ] 全局规范 48x48
- [ ] 工具组件封装
- **交付物**：可点击组件封装

### T22.4 屏幕阅读器测试
- [ ] TalkBack / VoiceOver 测试清单
- **交付物**：测试 checklist

### T22.5 焦点管理
- [ ] 键盘 Tab 顺序
- [ ] FocusNode 示例
- **交付物**：焦点管理示例

---

## M23 应用内更新 [P1]

### T23.1 版本检查接口
- [ ] 后端版本检查 API 对接
- [ ] 版本号比较工具
- **交付物**：版本检查模块

### T23.2 更新策略
- [ ] 强制 / 提示 / 静默 三档
- [ ] 更新弹窗 UI
- **交付物**：更新弹窗组件

### T23.3 Android 应用内更新
- [ ] in-app update API 集成
- **交付物**：Android 更新实现

### T23.4 iOS 引导更新
- [ ] 引导至 App Store
- **交付物**：iOS 更新实现

### T23.5 国内 Android 下载更新
- [ ] APK 下载 + 安装引导
- [ ] 断点续传
- **交付物**：APK 更新实现

---

## M24 隐私合规 [P1]

### T24.1 隐私政策弹窗
- [ ] 首次启动展示
- [ ] 未同意不初始化 SDK
- [ ] 二次确认机制
- **交付物**：隐私弹窗组件

### T24.2 SDK 初始化分级
- [ ] 必要 SDK 与可选 SDK 分离
- [ ] 用户同意后再初始化
- **交付物**：SDK 初始化框架

### T24.3 账户注销功能
- [ ] 注销流程 UI
- [ ] 冷静期机制
- [ ] 数据清理
- **交付物**：账户注销模块

### T24.4 数据导出
- [ ] 用户数据打包导出
- [ ] GDPR 合规
- **交付物**：数据导出功能

### T24.5 隐私政策与用户协议页
- [ ] 富文本展示
- [ ] 版本管理
- **交付物**：协议页面

### T24.6 合规 Checklist
- [ ] 国内（个保法、工信部备案）
- [ ] GDPR / CCPA / COPPA
- **交付物**：`docs/COMPLIANCE.md`

---

## M25 离线优先架构 [P1]

### T25.1 缓存策略
- [ ] 网络优先 / 缓存优先 / 仅缓存
- [ ] dio_cache_interceptor 配置
- **交付物**：缓存策略示例

### T25.2 本地变更队列
- [ ] 离线操作队列
- [ ] 上线后同步
- **交付物**：同步队列模块

### T25.3 乐观更新
- [ ] 先更 UI 再发请求
- [ ] 失败回滚
- **交付物**：乐观更新示例

### T25.4 网络状态监听
- [ ] connectivity_plus 集成
- [ ] 网络变化全局通知
- **交付物**：网络状态 Provider

---

## M26 原生互操作 [P1]

### T26.1 MethodChannel 封装
- [ ] 双向调用示例
- [ ] 错误处理
- **交付物**：MethodChannel 示例

### T26.2 EventChannel 封装
- [ ] 原生事件流（电量、网络变化）示例
- **交付物**：EventChannel 示例

### T26.3 Pigeon 集成
- [ ] 类型安全通信
- [ ] 代码生成
- **交付物**：Pigeon 示例

### T26.4 PlatformView 示例
- [ ] 嵌入原生视图
- **交付物**：PlatformView 示例

---

## M27 数据埋点 [P1]

### T27.1 埋点抽象层
- [ ] Analytics 接口定义
- [ ] 可切换实现（GA / 友盟 / 神策）
- **交付物**：`core/analytics/`

### T27.2 自动页面埋点
- [ ] go_router 观察者集成
- [ ] 页面浏览自动上报
- **交付物**：页面埋点观察者

### T27.3 自动曝光埋点
- [ ] VisibilityDetector 集成
- [ ] 元素曝光上报
- **交付物**：曝光埋点组件

### T27.4 事件埋点 API
- [ ] 自定义事件上报
- [ ] 参数规范
- **交付物**：事件上报 API

---

## M28 远程配置与 Feature Flag [P1]

### T28.1 远程配置抽象层
- [ ] RemoteConfig 接口
- [ ] 可切换实现（Firebase / 自建）
- **交付物**：`core/remote_config/`

### T28.2 Feature Flag
- [ ] 功能开关管理
- [ ] 灰度规则
- **交付物**：Feature Flag 模块

### T28.3 Kill Switch
- [ ] 紧急下线开关
- [ ] 强制下线 UI
- **交付物**：Kill Switch 实现

### T28.4 配置缓存与刷新
- [ ] 本地缓存
- [ ] 启动时刷新
- **交付物**：配置刷新逻辑

---

## M29 内置 Debug 面板 [P1]

### T29.1 Debug 入口
- [ ] 摇一摇 / 长按 LOGO 触发
- [ ] 仅 dev / staging 启用
- **交付物**：Debug 入口

### T29.2 环境切换
- [ ] 运行时切换 BaseUrl
- **交付物**：环境切换面板

### T29.3 日志查看器
- [ ] 实时日志展示
- [ ] 过滤 / 搜索
- [ ] 一键导出
- **交付物**：日志查看器

### T29.4 网络抓包
- [ ] 请求历史查看
- [ ] 请求 / 响应详情
- **交付物**：网络面板

### T29.5 缓存清理
- [ ] 一键清理各类缓存
- **交付物**：缓存清理工具

### T29.6 设备信息
- [ ] 设备型号、系统版本、App 版本
- **交付物**：设备信息页

---

## M30 桌面 / Web 适配 [P2]

### T30.1 桌面端基础配置
- [ ] Windows / macOS / Linux 平台启用
- [ ] 窗口最小尺寸
- **交付物**：桌面端配置

### T30.2 鼠标与键盘
- [ ] 悬停效果
- [ ] 右键菜单
- [ ] 快捷键
- **交付物**：交互示例

### T30.3 Web 端配置
- [ ] URL 策略（hash / path）
- [ ] SEO 基础
- [ ] 字体加载优化
- **交付物**：Web 配置

---

## M31 灰度发布与 A/B Test [P2]

### T31.1 用户分桶
- [ ] UserID / 设备 ID hash
- [ ] 分桶工具
- **交付物**：分桶模块

### T31.2 A/B 实验框架
- [ ] 实验定义
- [ ] 变体分发
- [ ] 数据上报
- **交付物**：实验框架

### T31.3 灰度回滚
- [ ] 一键回滚机制
- **交付物**：回滚工具

---

## M32 AI 能力集成预留 [P2]

### T32.1 LLM SDK 抽象层
- [ ] 统一 LLM 接口
- [ ] 支持 Anthropic / OpenAI / 国内大模型
- **交付物**：`core/ai/`

### T32.2 流式响应
- [ ] SSE / WebSocket 封装
- [ ] 流式 UI 组件
- **交付物**：流式响应模块

### T32.3 多模态上传
- [ ] 图片 / 音频上传组件
- **交付物**：多模态上传组件

### T32.4 AI 辅助开发配置
- [ ] .cursorrules 模板
- [ ] Claude Code / Copilot 配置
- **交付物**：AI 开发配置

---

## M33 组件库 Storybook [P2]

### T33.1 集成 widgetbook
- [ ] 基础配置
- **交付物**：Widgetbook 入口

### T33.2 组件展示
- [ ] 所有通用组件接入
- [ ] 多状态展示
- **交付物**：组件展示页

### T33.3 Design Tokens 展示
- [ ] 颜色 / 字号 / 间距可视化
- **交付物**：Token 展示页

---

## M34 动效系统 [P2]

### T34.1 动效曲线规范
- [ ] 标准曲线与时长
- **交付物**：动效 Token

### T34.2 页面转场动画
- [ ] 统一转场封装
- **交付物**：转场组件

### T34.3 Hero 动画封装
- [ ] 通用 Hero 工具
- **交付物**：Hero 示例

### T34.4 Lottie 集成
- [ ] 加载与播放工具
- **交付物**：Lottie 组件

### T34.5 微交互组件
- [ ] 按钮点击反馈
- [ ] 列表项动画
- **交付物**：微交互组件库

---

# 第四部分：任务统计与排期建议

## 任务规模统计

| 优先级 | 模块数 | 任务数 | 预估工作量 |
|---|---|---|---|
| P0 | 20 | 约 120 个 | 8-12 周 |
| P1 | 9 | 约 40 个 | 3-4 周 |
| P2 | 5 | 约 20 个 | 2-3 周 |
| **合计** | **34** | **约 180 个** | **13-19 周** |

## 推荐分阶段交付

| 阶段 | 周期 | 范围 | 里程碑 |
|---|---|---|---|
| Phase 1 | 第 1-4 周 | M01-M07 基础架构 | 项目能跑、能联网、能管理状态 |
| Phase 2 | 第 5-8 周 | M08-M14 业务能力 | 完整业务示例可演示 |
| Phase 3 | 第 9-12 周 | M15-M20 工程化 | 可正式投入生产 |
| Phase 4 | 第 13-16 周 | M21-M29 P1 模块 | 商业级能力完备 |
| Phase 5 | 第 17-19 周 | M30-M34 P2 模块 | 全功能脚手架 |

## 关键依赖关系

- M01 → 所有模块的前置
- M02 → M03 → M04 → M05（基础设施链）
- M06 → M07 → M19（状态 → 路由 → 业务）
- M10 → M12 → M14（主题 → 适配 → 组件）
- M11 → M21 → M27（监控 → 性能 → 埋点）
- M15 → M16 → M23（环境 → CI/CD → 更新）

## 推荐依赖清单（参考）

| 类别 | 库 |
|---|---|
| 状态管理 | flutter_riverpod, riverpod_annotation, riverpod_generator |
| 路由 | go_router, go_router_builder |
| 网络 | dio, retrofit, dio_smart_retry |
| 数据建模 | freezed, json_serializable, json_annotation |
| 依赖注入 | get_it, injectable |
| 函数式 | dartz 或 fpdart |
| 存储 | shared_preferences, flutter_secure_storage, hive / isar |
| 国际化 | flutter_localizations, intl |
| 权限 | permission_handler |
| 日志 | logger |
| 监控 | sentry_flutter |
| UI | cached_network_image, flutter_svg, easy_refresh |
| 工具 | flutter_gen, envied |
| 测试 | mocktail, golden_toolkit |
| 代码质量 | very_good_analysis |
| 多环境 | flutter_flavorizr |
| 资源 | flutter_native_splash, flutter_launcher_icons |
| Git Hooks | lefthook |
| 网络状态 | connectivity_plus |
| 埋点 | （视实现而定） |
| 组件库 | widgetbook |

---

# 第五部分：交付检查清单

每个任务交付前必须满足：

- [ ] 代码通过 `dart analyze` 无 warning
- [ ] 代码通过 `dart format` 格式化
- [ ] 新增功能有对应单元测试或集成测试
- [ ] 关键 API 有 dartdoc 注释
- [ ] 涉及配置变更有 README / 文档更新
- [ ] 通过 Android + iOS 双端验证
- [ ] PR 包含变更说明与测试结果

---

## 一句话总结

v3 相比 v2 增加了 **14 个新模块**，重点补强了**多屏幕适配、性能、合规、运营能力、AI 时代基础设施**五大方向，整套脚手架按 **34 个模块、约 180 个原子任务**进行拆解，可直接用于团队排期与进度跟踪。

---

**文档版本历史**

| 版本 | 日期 | 主要变更 |
|---|---|---|
| v1 | - | 初版需求 |
| v2 | - | 补强网络层细节、错误处理全链路、安全存储、崩溃监控、测试脚手架、CI/CD 与代码质量、启动流程编排、通用 UI 组件 |
| v3 | 2026-05-18 | 新增多屏幕适配、性能优化、无障碍、隐私合规、离线架构、原生互操作、埋点、远程配置、Debug 面板、AI 集成等 14 个模块；按 P0/P1/P2 优先级组织；拆解为 ~180 个可执行原子任务 |
