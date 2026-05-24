---
doc_type: ab_testing_guide
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T31.3
module_id: M31
status: completed
audience: [human_developers, ai_agents]
tags: [experiment, ab-test, gray-release, bucketing, rollback, M31]
---

# 灰度发布与 A/B 实验指南（AB_TESTING）

> M31 在 `lib/core/experiment/` 提供一套轻量、零额外依赖的灰度/实验框架：稳定分桶
> → 按权重分流变体 → 曝光上报 → 一键回滚。与 M27 埋点、M28 远程配置协同。

## 1. 概念与组成

| 组件 | 文件 | 职责 |
|---|---|---|
| `Bucketer` | `core/experiment/bucketer.dart` | 把 userId/设备 ID 稳定哈希到桶（T31.1） |
| `Variant` / `Experiment` | `core/experiment/experiment.dart` | 实验与变体定义（T31.2） |
| `ExperimentService` | `core/experiment/experiment_service.dart` | 分配变体 + 曝光上报（T31.2） |
| `ExperimentRollback` | `core/experiment/experiment_rollback.dart` | 一键回滚（T31.3） |

## 2. 用户分桶（T31.1）

灰度/分流的基础是**稳定分桶**：同一用户在同一实验里永远落同一桶，保证体验一致。

```dart
// 解析分桶单位：优先登录 userId，其次设备 ID，最后匿名
final unitId = Bucketer.resolveUnitId(userId: user?.id, deviceId: deviceId);

// 0–99 桶（salt 区分不同实验，避免相关性）
final bucket = Bucketer.bucketOf(unitId, salt: 'button_color');

// 百分比灰度
if (Bucketer.isInRollout(unitId, percent: 30, salt: 'new_feature')) {
  // 命中 30% 灰度
}
```

实现用 **FNV-1a** 哈希，保证跨平台/跨运行稳定（不依赖 Dart `String.hashCode`）。

## 3. 定义并分发实验（T31.2）

```dart
// 1) 定义实验（变体 + 权重；首个变体默认对照组 control）
final experiment = Experiment(
  key: 'button_color',
  variants: const [
    Variant('control', weight: 50), // 50%
    Variant('blue', weight: 25),    // 25%
    Variant('green', weight: 25),   // 25%
  ],
);

// 2) 注册（一般在启动时；定义可来自 RemoteConfig）
getIt<ExperimentService>().register(experiment);

// 3) 取变体（稳定，按权重）
final assignment = getIt<ExperimentService>().resolve('button_color', unitId);
final color = switch (assignment?.variantKey) {
  'blue' => Colors.blue,
  'green' => Colors.green,
  _ => Colors.grey, // control
};

// 4) 取变体 + 上报曝光（数据上报，进 M27 Analytics：event=experiment_exposure）
final a = await getIt<ExperimentService>().activate('button_color', unitId);
```

**变体分发算法**：把 `unitId` 用实验 key 作 salt 分桶到 `[0, 总权重)`，按累计权重区间落到对应变体——稳定、可复现、与桶占比一致。

## 4. 曝光上报（T31.2）

`activate(...)` 会调用 M27 `Analytics.logEvent('experiment_exposure', {experiment, variant, bucket, forced_control})`。下游可切换 GA/友盟/神策等后端（见 M27）。**只在真正展示实验时调用 activate**，避免污染曝光数据。

## 5. 灰度回滚（T31.3）

出问题时**一键把实验下线**，所有用户回落对照组：

```dart
// 客户端紧急回滚（持久化，重启仍生效）
await getIt<ExperimentRollback>().rollback('button_color');
// resolve/activate 之后都会返回 control（forcedControl == true）

// 恢复
await getIt<ExperimentRollback>().restore('button_color');
await getIt<ExperimentRollback>().restoreAll();
```

两条回滚路径：

| 方式 | 手段 | 适用 |
|---|---|---|
| **客户端回滚** | `ExperimentRollback.rollback(key)`（本地持久化） | 本机调试 / 单端紧急止血 |
| **服务端回滚** | 经 RemoteConfig（M28）下发 `Experiment.enabled = false` | 全量统一关停（推荐） |

`ExperimentService.resolve` 在「实验禁用 或 已回滚」时返回对照组并标记 `forcedControl`。

## 6. 与其它模块协同

- **M28 远程配置**：实验定义（变体/权重/enabled）可由 RemoteConfig 下发，实现免发版调流量/回滚。
- **M27 数据埋点**：曝光与转化事件统一走 `Analytics`，便于实验效果分析。
- **M28 FeatureFlags**：简单开关用 FeatureFlag，多变体/分流用本框架（二者都用稳定分桶）。

## 7. 最佳实践

- 永远保留 `control` 对照组，回滚即回落它。
- 实验 key 唯一且语义化（`checkout_button_color_2026q2`）。
- 分桶单位优先用稳定的 userId；纯匿名场景用设备 ID。
- 一个用户在一个实验内只 `activate` 一次（避免重复曝光）。
- 上线前用 `assignFor` 单测验证分流占比符合预期。

## 8. 测试

- `test/core/experiment/bucketer_test.dart`：分桶稳定性 + 大样本分布。
- `test/core/experiment/experiment_service_test.dart`：权重分配 + 禁用/回滚 + 曝光上报。
- `test/core/experiment/experiment_rollback_test.dart`：回滚/恢复/持久化。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · FNV-1a 稳定分桶 · macOS。
