---
doc_type: adr_index
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T20.7
module_id: M20
status: completed
audience: [human_developers, ai_agents]
tags: [adr, architecture-decision-record, index, M20, T20.7]
---

# 架构决策记录（ADR）

> **ADR（Architecture Decision Record）** 记录项目中重要的、有取舍的技术决策：当时的背景、候选方案、最终选择与后果。让后来人（含 AI Agent）不必读完所有代码就能理解「为什么是这样」。

## 什么时候写 ADR

满足任一条件就值得写一条 ADR：

- 在多个技术方案间做了选择（库 A vs 库 B、架构模式取舍）。
- 决策有明显代价或会约束后续开发（团队需长期遵守的纪律）。
- 决策违反直觉或偏离常见做法（避免后人「好心改回去」踩坑）。

trivial 的、可随时无痛推翻的决定不需要 ADR。

## 怎么写

1. 复制 [`0000-template.md`](0000-template.md) 为 `NNNN-简短标题.md`（`NNNN` 为四位递增编号）。
2. 填写背景 / 候选 / 决策 / 理由 / 后果 / 参考。
3. 设置 `status`：`proposed`（讨论中）→ `accepted`（采纳）；被取代时改 `deprecated` 或 `superseded by ADR-XXXX`。
4. **ADR 不可变**：决策变了就**新写一条**取代旧的，而不是改旧文件（保留历史）。
5. 在下表登记。

## 决策清单

| 编号 | 标题 | 状态 | 日期 | 模块 |
|---|---|---|---|---|
| [0001](0001-handwritten-providers-over-codegen.md) | 用手写 Riverpod Provider 替代 riverpod_generator | ✅ accepted | 2026-05-18 | M06 |
| [0002](0002-result-type-for-error-handling.md) | 用 Result<T> + ErrorMapper 做跨层错误归一化 | ✅ accepted | 2026-05-18 | M03 |

> 模板文件 [`0000-template.md`](0000-template.md) 不是决策，仅供复制。

## 与其它文档的关系

- 决策的**结果**沉淀到 [ARCHITECTURE](../ARCHITECTURE.md) / [CONVENTIONS](../CONVENTIONS.md)；ADR 记录**为什么这么决定**。
- 逐任务的实现验证见 [验证报告](../verification/README.md)。
