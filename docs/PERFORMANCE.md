---
doc_type: performance_guide
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T21.2
module_id: M21
status: completed
audience: [human_developers, ai_agents]
tags: [performance, const, repaint-boundary, riverpod-select, list, itemextent, image-cache, bundle-size, M21, T21.2, T21.5]
---

# 性能优化规范（PERFORMANCE）

> 渲染、列表、图片、包体积四方面的可落地规范。配套：[启动埋点](#启动耗时埋点t211) · [DevTools 指南](DEVTOOLS_GUIDE.md) · [架构](ARCHITECTURE.md)。

## 1. 渲染优化（T21.2）

### 1.1 const 规范

`const` Widget 在 rebuild 时被直接复用、跳过重建——这是**成本最低、收益最大**的优化。

- 能 const 的构造**一律加 const**：`const SizedBox(height: 8)`、`const Text('标题')`、`const Icon(Icons.add)`。
- 把不随状态变化的子树**提取成 const 字段或独立 const Widget**，使其落在 rebuild 范围之外。
- 项目已开启相关 lint（`prefer_const_constructors` / `prefer_const_literals_to_create_immutables` 等，来自 very_good_analysis），漏写会被静态分析提示。

```dart
// ❌ 每次 build 都新建
Padding(padding: EdgeInsets.all(16), child: Text('hi'))
// ✅ 复用
const Padding(padding: EdgeInsets.all(16), child: Text('hi'))
```

### 1.2 RepaintBoundary 使用指南

`RepaintBoundary` 把子树隔离成独立图层：子树重绘不波及外部，外部重绘也不波及它。

**该用的场景**：
- 长列表的**每一行**（见 `HighPerformanceListPage`，T21.3）——滚动时各行独立，互不重绘。
- 持续动画区域（进度条、loading、Lottie）旁边有静态内容时，给动画或静态侧加边界。
- 频繁重绘的自绘 `CustomPaint` 与其周围静态 UI 之间。

**不要滥用**：每个边界都有图层合成开销。只在「一侧频繁重绘、另一侧静止」时加；用 DevTools 的 *Highlight Repaints* 确认重绘范围后再决定。

```dart
itemBuilder: (context, index) => RepaintBoundary(
  child: _FixedHeightRow(index: index),
),
```

### 1.3 Riverpod 精准订阅（select）

只 watch 你真正用到的那一小块状态，避免无关字段变化触发整树 rebuild——等价于其它框架的 Selector。

```dart
// ❌ 整个对象变就 rebuild（即使只用到 name）
final user = ref.watch(userProvider);
Text(user.name);

// ✅ 只在 name 变化时 rebuild
final name = ref.watch(userProvider.select((u) => u.name));
Text(name);
```

- 列表项只订阅自己那条数据：`ref.watch(itemsProvider.select((list) => list[index]))`。
- 把 `ref.watch` 下沉到**真正使用值的最小 Widget**，而不是放在大页面顶部，缩小 rebuild 半径。
- 副作用监听用 `ref.listen`（不触发 rebuild）。

## 2. 列表性能（T21.3）

参考实现：[`lib/features/examples/performance/high_performance_list_page.dart`](../lib/features/examples/performance/high_performance_list_page.dart)（showcase「M21 性能优化体系」可直接体验万级列表）。

- **`ListView.builder`**：按需构建可见项，绝不用 `ListView(children: [...])` 渲染长列表。
- **`itemExtent`（固定行高）**：跳过逐项布局测量、滚动定位 O(1)，长列表收益最大。行高不定但有典型项时用 `prototypeItem`。
- **`RepaintBoundary` + const 行**：每行隔离 + 行内容尽量 const（见 §1）。
- 分页加载用 M14 的 `AppRefreshList`（下拉刷新 + 上拉分页），参考首页 `features/home`。
- 避免在 `itemBuilder` 里做重计算/同步 IO；图片用缩略图（见 §3）。

## 3. 图片性能（T21.4）

参考实现：[`lib/shared/widgets/app_image.dart`](../lib/shared/widgets/app_image.dart)。

- **按展示尺寸解码**：用 `AppImage.thumbnail(url, size: 96)` 或 `AppImage(url, cacheWidth: 360)`。`cacheWidth/Height` 是逻辑像素，组件按 `devicePixelRatio` 换算成 `memCacheWidth/Height`。不设置的话，一张 4000×3000 的图会按原分辨率解码，约占 **48MB** 内存。
- **缩略图与原图分离**：列表用 `thumbnail`（小内存 + 限制磁盘缓存到 2×size），详情页再加载原图。
- **磁盘缓存控制**：`maxWidthDiskCache/maxHeightDiskCache` 限制磁盘缓存的原图尺寸。
- 底层是 `cached_network_image`（内存 + 磁盘双缓存），重复 URL 不重复下载/解码。

```dart
// 列表项：小图、低内存
AppImage.thumbnail(item.cover, size: 96);
// 详情页：按屏宽解码
AppImage(item.cover, cacheWidth: MediaQuery.sizeOf(context).width.round());
```

## 4. 包体积优化（T21.5）

脚本：[`scripts/analyze_size.sh`](../scripts/analyze_size.sh)（体积明细）、[`scripts/check_unused_assets.sh`](../scripts/check_unused_assets.sh)（未用资源检测）。

| 手段 | 做法 |
|---|---|
| **体积分析** | `scripts/analyze_size.sh prod apk android-arm64` → 终端体积树 + DevTools「App size tool」JSON |
| **ABI 拆分** | 上架用 **AAB**（`scripts/build_android.sh prod aab`），Play 按设备分发，安装包最小；直分发 APK 用 `scripts/build_android.sh prod apk --split-per-abi`，单包约为 universal 的 1/3 |
| **字体子集化** | release 默认开启 `--tree-shake-icons`，只打包用到的 Material 图标字形（构建日志会打印裁剪比例）；自定义字体可用 fontTools 子集化 |
| **代码混淆/压缩** | release 构建用 `--obfuscate --split-debug-info`（见 `build_android.sh`）；Android 可在 `build.gradle.kts` 开 R8 `minifyEnabled` + `shrinkResources` |
| **未用资源** | `scripts/check_unused_assets.sh` 启发式扫描 `assets/`，报告 lib/ 中未引用的文件 |
| **依赖瘦身** | `flutter pub deps` 审查传递依赖；移除仅 demo 用到的重包 |

```bash
scripts/analyze_size.sh prod apk android-arm64    # 体积明细
scripts/check_unused_assets.sh assets             # 未用资源
scripts/build_android.sh prod apk --split-per-abi # 按 ABI 拆分 APK
```

## 启动耗时埋点（T21.1）

`StartupTracker`（[`lib/core/logger/startup_tracker.dart`](../lib/core/logger/startup_tracker.dart)）在 `bootstrap` 中记录各阶段（binding / di / envConfig / errorHandlers / runApp）耗时与**首帧时间**，首帧后用 `AppLogger` 打印摘要：

```
[startup] phases (since process start):
  binding          +12ms  (@12ms)
  di               +85ms  (@97ms)
  envConfig        +2ms   (@99ms)
  errorHandlers    +6ms   (@105ms)
  runApp           +18ms  (@123ms)
  → first frame at 140ms
```

用 DevTools 进一步分析见 [DEVTOOLS_GUIDE](DEVTOOLS_GUIDE.md)。showcase「M21 性能优化体系」页可直接看到本次启动的阶段耗时。

## 性能预算（建议）

| 指标 | 目标 |
|---|---|
| 帧时间 | < 16ms（60fps）/ < 8ms（120fps），无 jank |
| 冷启动到首帧 | 中端机 < 2s（用 StartupTracker 度量） |
| 列表滚动 | 万级列表无掉帧（itemExtent + RepaintBoundary） |
| 单图内存 | 按展示尺寸解码，不驻留原图位图 |

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · cached_network_image · very_good_analysis（const lints）· macOS。
