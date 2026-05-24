---
adr: 0001
title: 用手写 Riverpod Provider 替代 riverpod_generator
status: accepted
date: 2026-05-18
deciders: [模板维护者]
tags: [adr, state-management, riverpod, codegen, M06]
supersedes: []
---

# ADR-0001：用手写 Riverpod Provider 替代 riverpod_generator

> 状态：accepted · 日期：2026-05-18 · 模块：M06 状态管理

## 背景与问题（Context）

M06 选用 `flutter_riverpod` 做状态管理。Riverpod 官方推荐配套 `riverpod_generator`（`@riverpod` 注解 + build_runner 生成 Provider），可减少样板。但本模板同时重度使用其它代码生成器：`freezed` 3.x、`json_serializable` 6.x、`retrofit_generator` 10.x、`injectable_generator`、`go_router_builder`。

实测在当前版本组合下，`riverpod_generator` 与 `json_serializable` / `freezed` / `retrofit` 的版本链存在依赖冲突，无法在不降级其它核心生成器的前提下共存（`flutter pub get` 解析失败 / 生成器互不兼容）。

## 候选方案（Options）

- **方案 A**：引入 `riverpod_generator`，为此降级 `freezed` / `json_serializable` / `retrofit` 到兼容版本。
- **方案 B**：不引入 `riverpod_generator`，手写 Provider（`Provider` / `FutureProvider` / `NotifierProvider` 等），与 codegen 写法等价。
- **方案 C**：放弃 Riverpod，改用其它状态方案。

## 决策（Decision）

我们选择 **方案 B：手写 Provider 模式**。所有 Provider/Controller 用 Riverpod 的原生 API 手写，放在各 feature 的 `presentation/providers/` 下。

## 理由（Rationale）

- 网络（retrofit）+ 建模（freezed/json）+ DI（injectable）是模板的**地基**，其版本必须取较新稳定线；为一个「减样板」的便利生成器而降级地基，代价过高、风险外溢。
- 手写 Provider 与 `@riverpod` 生成的结果**语义等价**：`AutoDisposeAsyncNotifier`、`FutureProvider.family`、`Provider` 等都能直接表达，仅多写少量样板。
- 减少一个生成器 = 减少一处 build_runner 冲突面与 CI 不确定性。

## 后果（Consequences）

- ✅ 核心生成器保持新版本，依赖解析稳定；build_runner 冲突面更小。
- ✅ Provider 代码显式可读，新人不需理解 `@riverpod` 宏展开。
- ⚠️ 需手写少量样板（Provider 声明、`family` 参数透传）；团队需遵循统一写法（见 [CONVENTIONS](../CONVENTIONS.md) 命名约定）。
- ⚠️ 失去 `riverpod_lint` 的部分专用检查。
- 🔁 **重评条件**：当 `riverpod_generator` 与 freezed/json/retrofit 的新版本链能无冲突共存时，可重新评估是否迁移。

## 参考（References）

- 代码：`lib/features/*/presentation/providers/`、`lib/core/observer/provider_observer.dart`
- 依赖说明：`pubspec.yaml`（dev_dependencies 中关于 riverpod_generator 的注释）
- 验证报告：[docs/verification/T06.1.md](../verification/T06.1.md)
- 架构：[docs/ARCHITECTURE.md § 6](../ARCHITECTURE.md#6-关键横切设计)
