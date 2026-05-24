---
adr: 0002
title: 用 Result<T> + ErrorMapper 做跨层错误归一化
status: accepted
date: 2026-05-18
deciders: [模板维护者]
tags: [adr, error-handling, result, failure, sealed-class, M03]
supersedes: []
---

# ADR-0002：用 Result<T> + ErrorMapper 做跨层错误归一化

> 状态：accepted · 日期：2026-05-18 · 模块：M03 错误处理体系

## 背景与问题（Context）

App 的错误来源多样：网络异常（Dio）、解析异常、存储异常、鉴权失败、校验失败等。若让这些原始异常直接向上抛、在各处 `try/catch`，会导致：UI 层耦合底层异常类型、错误文案散落、漏处理某类异常导致崩溃、难以统一上报。需要一种**跨层统一**的错误传递方式。

## 候选方案（Options）

- **方案 A**：到处抛异常 + 各层 `try/catch`，UI 直接 catch 底层异常。
- **方案 B**：定义 sealed `Failure` 体系 + `Result<T>`（`Success`/`Failed`）作为跨层返回值；`data` 层用 `ErrorMapper` 把 `Exception` 归一化为 `Failure`，**异常不越过 data 层**。
- **方案 C**：用第三方函数式库（如 `dartz` 的 `Either`）。

## 决策（Decision）

我们选择 **方案 B**：自研轻量 `Result<T>` + sealed `Failure`。

- `lib/core/error/exceptions.dart`：原始异常体系（`NetworkException` 等）。
- `lib/core/error/failures.dart`：sealed `Failure`（`NetworkFailure` / `ServerFailure` / `CacheFailure` / `UnauthorizedFailure` / `ValidationFailure` / `UnknownFailure`）。
- `lib/core/error/result.dart`：sealed `Result<T>`（`Success` / `Failed`）+ `fold` 扩展方法。
- `lib/core/error/error_mapper.dart`：`const ErrorMapper`，`Exception → Failure`。
- 全局兜底：`runZonedGuarded` + `FlutterError.onError` 接 AppLogger/CrashReporter（M11）。

## 理由（Rationale）

- **类型安全的穷尽处理**：`Failure` 是 sealed，`switch` 必须覆盖所有子类型，新增一类错误会在编译期暴露所有需要处理的点。
- **关注点分离**：异常在 `data` 层就被 `ErrorMapper` 收敛成 `Failure`，`domain`/`presentation` 只面对 `Result<T>`，UI 无需散落 try/catch。
- **零额外依赖**：不引入 `dartz` 等较重的函数式库，降低学习与维护成本（自研类型足够表达 success/failure）。
- **可测试**：UseCase / Repository 返回 `Result<T>`，单测断言 `isA<Success>()` / `isA<Failed>()` 即可，无需构造异常栈。

## 后果（Consequences）

- ✅ 错误通道统一，UI 层简洁；新增错误类型由编译器强制处理。
- ✅ 便于统一上报（全局 handler）与统一文案（`FailureMessageX.message` 扩展）。
- ⚠️ 跨层方法签名统一为 `Future<Result<T>>`，调用方需用 `fold` 处理两分支。
- ⚠️ `fold` 是**扩展方法**，使用处必须 `import core/error/result.dart`（漏导入会报「fold 未定义」，见 [TROUBLESHOOTING](../TROUBLESHOOTING.md)）。
- 🔁 **重评条件**：若团队后续大量需要函数式组合（`map`/`flatMap` 链），可评估迁移到成熟函数式库。

## 参考（References）

- 代码：`lib/core/error/`（exceptions / failures / result / error_mapper）
- 用例：`lib/features/auth/data/repositories/auth_repository_impl.dart`
- 验证报告：[T03.2](../verification/T03.2.md) · [T03.3](../verification/T03.3.md) · [T03.4](../verification/T03.4.md)
- 架构：[docs/ARCHITECTURE.md § 4](../ARCHITECTURE.md#4-运行时数据流以登录为例)
