---
doc_type: implementation_guide
module_id: M12
priority: P0
status: implemented
spec_source: flutter_template_v3.md
spec_lines: "507-545"
tags: [responsive, breakpoints, foldable, safe-area, orientation, tablet, T12, M12]
---

# 多屏幕适配规范（M12）

> 模块 M12 多屏幕适配的统一说明：断点、响应式布局、字体缩放、平板双栏、折叠屏、
> 安全区域、横竖屏。源码在 `lib/core/responsive/`。

## 1. 断点系统（T12.1）

| 类型 | 宽度 | 典型设备 |
|---|---|---|
| `mobile` | < 600 | 手机竖屏 |
| `tablet` | 600 ~ 1024 | 手机横屏 / 平板竖屏 |
| `desktop` | 1024 ~ 1440 | 平板横屏 / 小桌面 |
| `largeDesktop` | > 1440 | 大桌面 |

```dart
if (context.isTabletOrLarger) { /* 双栏 */ }
final type = context.screenType;
```

## 2. 响应式布局（T12.2）

`ResponsiveBuilder` 用 `LayoutBuilder`（父容器约束，非整窗口）选布局，按就近回退：

```dart
ResponsiveBuilder(
  mobile: (_) => const OneColumn(),
  tablet: (_) => const TwoColumn(),     // mobile 之外可选
  desktop: (_) => const ThreeColumn(),
);
```

选**值**用 `ResponsiveValue<T>`：

```dart
final columns = const ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 4)
    .resolve(context.screenType);
```

## 3. 字体缩放（T12.3）

系统超大字体会撑破布局。`ClampedTextScaling` 把 `TextScaler` 钳制到 [0.8, 1.4]：

```dart
MaterialApp(
  builder: (context, child) => ClampedTextScaling(child: child!),
);
```

既尊重无障碍偏好，又保证布局不崩。

## 4. 平板 Master-Detail（T12.4）

`MasterDetailPage` 示例：
- 窄屏：单栏列表 → 点选 push 详情
- 宽屏：`NavigationRail` + 列表 + 详情三段并排，选中即时展示

选中状态用 `_selectedIndex` 保留；列表用 `PageStorageKey` 保留滚动位置。

## 5. 折叠屏（T12.5）

`FoldableUtils` 从 `MediaQuery.displayFeatures` 检测铰链：

```dart
final hinge = FoldableUtils.hinge(MediaQuery.of(context));
if (hinge != null) { /* 双屏形态 */ }
```

`HingeAwareTwoPane` 在垂直铰链处把内容一分为二并**避让铰链区域**（中间留出铰链宽度），避免内容压在折痕上。

## 6. 安全区域（T12.6）

异形屏（刘海/挖孔）、Home Indicator 避让：

```dart
// 统一封装：默认上下避让、左右贴边
AppSafeArea(child: pageContent);

// 读各方向 inset
SafeAreaUtils.topInset(context);     // 状态栏+刘海
SafeAreaUtils.bottomInset(context);  // Home Indicator
SafeAreaUtils.hasBottomIndicator(context);
```

规范：
- **页面根**用 `AppSafeArea` 包裹（或 Scaffold 自带）
- **全屏背景图 / 渐变**铺满，内容用 SafeArea
- **底部固定按钮**额外加 `bottomInset` 留白，避开 Home Indicator
- `MediaQuery.viewPaddingOf`（系统 UI，含键盘前）vs `paddingOf`（键盘弹出会变）— 避让用 viewPadding

## 7. 横竖屏（T12.7）

### 7.1 锁定方向

```dart
await OrientationUtils.lockPortrait();   // 锁竖屏
await OrientationUtils.lockLandscape();  // 锁横屏（视频/游戏）
await OrientationUtils.unlock();          // 恢复自由旋转
```

### 7.2 状态保留

横竖屏切换时 Flutter **不重建 State 对象**，故：
- StatefulWidget 的字段（如选中项、表单值）自动保留
- 滚动位置：给 ScrollView 加 `PageStorageKey` 即可跨方向保留
- TextField：`TextEditingController` 持有文本，旋转不丢

无需手写「保存/恢复」逻辑——除非主动 dispose 重建（如路由替换）。

## 8. 测试要点

- 断点 / ResponsiveValue / 字体钳制 / 铰链检测 / 方向映射：纯函数单测
- ResponsiveBuilder / HingeAwareTwoPane / AppSafeArea / MasterDetail：用
  `tester.view.physicalSize` + `MediaQuery` 注入不同尺寸 / displayFeatures 做 widget 测
- 方向锁定：mock `SystemChrome.setPreferredOrientations` 平台 channel 断言调用
