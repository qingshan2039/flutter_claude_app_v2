---
doc_type: devtools_guide
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T21.6
module_id: M21
status: completed
audience: [human_developers, ai_agents]
tags: [devtools, performance, memory, cpu, profiler, profile-mode, M21, T21.6]
---

# DevTools 使用指南（DEVTOOLS_GUIDE）

> Flutter DevTools 排查性能/内存/CPU 的实操手册。配套：[性能规范](PERFORMANCE.md) · [上手指南](GETTING_STARTED.md)。

## 0. 黄金法则：用 profile 模式测性能

**debug 模式的性能数据不可信**（断言、未优化的 JIT、Observatory 开销会让它远慢于真机）。测性能一律用 **profile 模式**：

```bash
flutter run --profile -t lib/main_dev.dart --flavor dev
```

- profile = 接近 release 的性能 + 保留 DevTools 可观测性。
- 内存/CPU 行为分析也优先 profile；功能调试才用 debug。
- 真机优先（模拟器/桌面的 GPU、CPU 特性与手机差异大）。

## 1. 打开 DevTools

| 方式 | 操作 |
|---|---|
| 命令行 | `flutter run` 后，终端按 `v` 打开 DevTools（或复制打印的 URL） |
| VSCode | 命令面板 → *Dart: Open DevTools*；或调试工具栏的 DevTools 图标 |
| Android Studio | Run/Debug 窗口的 *Open DevTools* |
| 独立 | `dart devtools` 后手动粘贴 app 的 VM Service URI |

## 2. Performance（帧/卡顿分析）

定位掉帧（jank）。

1. 切到 **Performance** 页 → 点 **Frame Analysis**，操作 App（如滚动列表）。
2. 看 **Frames chart**：超过预算（60fps→16ms / 120fps→8ms）的帧为红色。
3. 选中红帧，下方 **Timeline** 显示该帧耗时分布：
   - **UI 线程**长 = Dart 构建/布局慢 → 查 `build()` 是否过重、是否缺 const、rebuild 范围过大（见 [PERFORMANCE §1](PERFORMANCE.md#1-渲染优化t212)）。
   - **Raster 线程**长 = 绘制/合成慢 → 查 saveLayer、阴影、过度透明、未加 `RepaintBoundary`。
4. 勾选 **Track Widget Builds**（需 debug）：看哪些 Widget 频繁 rebuild → 用 `select()` 收窄订阅。

辅助开关（DevTools 顶部或代码）：
- **Performance Overlay**：运行时按 `P`，或 `MaterialApp(showPerformanceOverlay: true)`。两条横向图表（UI/Raster），有竖红线即掉帧。
- **Highlight Repaints**：给每次重绘的图层描随机色边框；颜色狂闪处即不必要的重绘（考虑加 `RepaintBoundary`）。
- **Highlight Oversized Images**：标出解码尺寸远大于显示尺寸的图 → 用 `AppImage.thumbnail` / `cacheWidth`（见 [PERFORMANCE §3](PERFORMANCE.md#3-图片性能t214)）。

## 3. CPU Profiler（热点方法）

定位 CPU 密集的 Dart 代码。

1. **CPU Profiler** 页 → **Record**，执行目标操作，**Stop**。
2. 看 **Flame chart**（自上而下调用栈，越宽越耗时）或 **Bottom Up**（按自身耗时排序找热点方法）。
3. 常见信号：JSON 解析、同步加密/压缩、在 build 里做重计算 → 移出 build、改异步/隔离 isolate、加缓存。
4. 也可用代码埋点对照：M11 的 `PerformanceMonitor.traceAsync/traceSync` 打印关键路径耗时。

## 4. Memory（内存/泄漏）

定位内存增长与泄漏。

1. **Memory** 页观察 **Memory chart**：正常应随导航有升有降；只升不降疑似泄漏。
2. **Heap Snapshot**：在两个时间点各拍一次（如进入再退出某页前后），对比某类实例数是否未回收。
3. **Trace Allocations**：勾选要追踪的类，操作后看分配来源调用栈。
4. 常见泄漏源：未 dispose 的 `Controller`/`StreamSubscription`/`AnimationController`；闭包持有 `BuildContext`；图片缓存无上限。
   - 本项目 Riverpod 多用 `autoDispose`（离页自动释放）；`TextEditingController` 等记得在 `dispose()` 释放（参考 `LoginPage`）。
5. 图片内存专项：配合 *Highlight Oversized Images* 与 `AppImage` 的 `cacheWidth`。

## 5. App Size Tool（包体积）

分析产物体积构成（配合 [T21.5 脚本](PERFORMANCE.md#4-包体积优化t215)）。

```bash
scripts/analyze_size.sh prod apk android-arm64
```

构建产出的 JSON 写到 `~/.flutter-devtools/`；DevTools → **App Size** → *Open* 加载，可看 Dart AOT / .so / assets / 字体 各占多少，并 **Diff** 两次构建的增量，定位体积膨胀来源。

## 6. 其它常用页

| 页 | 用途 | 关联模块 |
|---|---|---|
| **Network** | 查看 HTTP 请求/响应/耗时 | M04 网络层 |
| **Logging** | 查看 `dart:developer` / 框架日志 | M11 日志（`AppLogger`） |
| **Inspector** | Widget 树、布局约束、选中定位源码 | UI 调试 |
| **Provider** | 查看 Riverpod provider 状态（需 riverpod devtools 扩展） | M06 状态管理 |

## 7. 排查流程速查

1. `flutter run --profile`（真机）→ 复现卡顿/发热/内存涨。
2. **Performance** 找红帧 → 判断 UI 还是 Raster 线程瓶颈。
3. UI 瓶颈 → **CPU Profiler** 找热点方法 + **Track Widget Builds** 找过度 rebuild。
4. Raster 瓶颈 → **Highlight Repaints** / 检查 saveLayer、阴影、`RepaintBoundary`。
5. 内存涨 → **Memory** 快照对比 + 追踪分配。
6. 包大 → `analyze_size.sh` + **App Size** diff。
7. 改完回到第 1 步用同样操作复测，对比数据确认收益。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · DevTools（随 Flutter SDK）· profile 模式 · macOS。
