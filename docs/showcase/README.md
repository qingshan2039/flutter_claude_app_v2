---
doc_type: showcase_guide
module_id: showcase
priority: P2
status: implemented
tags: [showcase, demo, gallery, runnable, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M12]
related_code:
  - lib/main_showcase.dart
  - lib/features/showcase/
  - test/features/showcase/showcase_gallery_test.dart
---

# 模块效果展示（Showcase）

> 一个可直接运行的「画廊」App：把 M02–M12 各模块做成可交互的 demo 页，
> 让人无需读代码就能**直接看到每个模块的效果**。源码在 `lib/features/showcase/`，
> 入口 `lib/main_showcase.dart`。

## 1. 运行

```bash
# 任意已连接的设备 / 模拟器
flutter run -t lib/main_showcase.dart

# 仅构建调试包
flutter build apk --debug -t lib/main_showcase.dart
```

启动后进入画廊首页，点任一卡片进入对应模块的 demo 页。Showcase 用普通
`MaterialApp`（非 go_router）+ 画廊首页，**绕过主 App 的登录守卫**，但仍接入
真实的 theme / locale / DI，使主题、国际化、依赖注入等 demo 真实生效。

> 主入口（完整应用，含路由守卫）仍是 `lib/main_dev.dart` 等多环境入口；
> Showcase 只是并行的「演示入口」，不影响正式入口。

## 2. 包含的模块

| 模块 | demo 页 | 能看到什么 |
|---|---|---|
| M02 依赖注入与数据建模 | `di_demo_page.dart` | factory vs singleton 生命周期；freezed Model ↔ JSON ↔ Entity 往返 |
| M03 错误处理体系 | `error_demo_page.dart` | Exception → Failure 映射；`Result.fold` 成功/失败分支 |
| M04 网络层 | `network_demo_page.dart` | 拦截器链；真实 GET 请求；日志脱敏实时演示；取消令牌 |
| M05 本地存储 | `storage_demo_page.dart` | SharedPreferences / SecureStorage 读写 |
| M06 状态管理 | `state_demo_page.dart` | Riverpod 计数器 / 派生 Provider / AsyncNotifier 三态 |
| M07 路由管理 | `routing_demo_page.dart` | 自定义转场（淡入 / 滑入）+ 参数传递 |
| M08 国际化 | `i18n_demo_page.dart` | 实时切换语言；复数 / 日期 / 货币格式化 |
| M09 权限管理 | `permission_demo_page.dart` | 逐权限请求（真机有效）；永久拒绝引导设置页 |
| M10 主题与设计系统 | `theme_demo_page.dart` | 亮/暗/跟随系统切换；Design Tokens 色板与间距 |
| M11 日志与监控 | `logging_demo_page.dart` | 分级日志；脱敏实时演示；性能埋点计时 |
| M12 多屏幕适配 | `responsive_demo_page.dart` | 实时断点 / ScreenType；ResponsiveBuilder；Master-Detail |
| M14 通用 UI 组件 | `ui_kit_demo_page.dart` | 状态组件 / AsyncValueWidget / AppImage / 下拉刷新 / Toast / Dialog / BottomSheet / 键盘 / AppScaffold |

## 3. 结构

```
lib/
  main_showcase.dart                 # 入口：DI → 全局错误处理 → runApp(ShowcaseApp)
  features/showcase/
    showcase_app.dart                # 根 MaterialApp（接 theme/locale/字体钳制）
    showcase_gallery_page.dart       # 画廊首页 + kShowcaseEntries 注册表
    widgets/demo_scaffold.dart       # 共享脚手架：DemoScaffold / DemoSection / DemoResultRow
    pages/*.dart                     # 11 个模块 demo 页
```

所有模块在 `kShowcaseEntries`（`showcase_gallery_page.dart`）里注册：

```dart
final List<ShowcaseEntry> kShowcaseEntries = <ShowcaseEntry>[
  ShowcaseEntry(
    moduleId: 'M02',
    title: '依赖注入与数据建模',
    subtitle: '...',
    icon: Icons.account_tree,
    builder: (_) => const DiDemoPage(),
  ),
  // ...
];
```

### 新增一个 demo 页

1. 在 `pages/` 下新建 `xxx_demo_page.dart`，用 `DemoScaffold` 包裹内容。
2. 在 `kShowcaseEntries` 追加一条 `ShowcaseEntry`（`builder: (_) => const XxxDemoPage()`）。
3. 画廊会自动列出，无需改其它代码。

## 4. 两个布局/DI 陷阱（建 Showcase 时发现并修复）

> 这两点对**正式业务代码同样适用**，记录于此备查。

### 4.1 整宽按钮不能直接放进 Row

主题 `AppTheme` 给 `FilledButton` / `OutlinedButton` 设了
`minimumSize: Size.fromHeight(48)`（即**最小宽度无限**，用于 Column 中的整宽按钮）。
把这类按钮直接放进 `Row`（或 `ListTile.trailing`）时，Row 会以**无界宽度**测量
非弹性子项 → 触发 `BoxConstraints forces an infinite width` 断言。

- 该断言只在对应区域**真正布局**时才出现；懒加载 `ListView` 中离屏的区域不布局，
  故问题可能要等滚动 / 进页时才暴露。
- 修复：Row 里给每个按钮包 `Expanded`（等宽并排），或用本地
  `style: FilledButton.styleFrom(minimumSize: Size(0, 40))` 覆盖最小宽度。

### 4.2 injectable 不会跳过「有默认值的基元参数」

`LoggingInterceptor({this.enabled = kDebugMode})` 与
`RetryInterceptor({this.maxRetries = 3, ...})` 虽有默认值，但若类上直接标
`@lazySingleton`，injectable 仍会为这些参数生成 `gh<bool>()` / `gh<int>()`，
解析一个**未注册的基元类型** → 解析 `Dio` 时抛
`Object/factory with type bool/int is not registered`。

- 修复：不在类上标注，改由 `@module`（`NetworkModule`）的工厂方法用**默认构造**提供：
  ```dart
  @lazySingleton
  LoggingInterceptor provideLoggingInterceptor() => LoggingInterceptor();
  @lazySingleton
  RetryInterceptor provideRetryInterceptor() => RetryInterceptor();
  ```

## 5. 测试

`test/features/showcase/showcase_gallery_test.dart`：
- 画廊列出全部 11 个模块；
- 抽样进入 M02 / M03 / M06 / M10 验证交互；
- **回归守卫**：逐个进入全部 11 页，断言渲染不抛异常（守住 §4.1 这类懒加载离屏布局问题）。

```bash
flutter test test/features/showcase/showcase_gallery_test.dart
```
