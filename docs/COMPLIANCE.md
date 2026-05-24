---
doc_type: compliance_checklist
project: flutter_claude_app_v2
spec_source: flutter_template_v3.md
task_id: T24.6
module_id: M24
status: completed
audience: [human_developers, legal, qa]
tags: [compliance, privacy, pipl, gdpr, ccpa, coppa, checklist, M24, T24.6]
---

# 合规清单（COMPLIANCE）

> 上架前的隐私合规自查清单：国内（个保法 / 工信部）+ 海外（GDPR / CCPA / COPPA）。
> 本清单是**工程视角**的落地核对，不构成法律意见；正式上线请经法务复核。
> 相关实现见 M24 隐私合规：[ACCESSIBILITY 之外的隐私文档与代码]。

## 0. 模板已内置的合规能力（M24）

| 能力 | 实现 | 任务 |
|---|---|---|
| 隐私同意 + 版本管理 + 二次确认 | `ConsentStore` + `PrivacyConsentDialog` | T24.1 |
| SDK 初始化分级（同意后才初始化可选 SDK） | `SdkInitializer`（essential/optional） | T24.2 |
| 账户注销 + 冷静期 + 数据清理 | `AccountDeletionService` + `UserDataEraser` | T24.3 |
| 数据导出（可移植） | `DataExportService`（JSON） | T24.4 |
| 隐私政策 / 用户协议页（版本/生效日期） | `LegalDocumentPage` + `kPrivacyPolicy/kUserAgreement` | T24.5 |

## 1. 国内合规（个人信息保护法 / 网络安全法 / 工信部）

### 1.1 告知与同意
- [ ] 首次启动**先弹隐私政策**，用户**主动同意**后才进入（不得默认勾选）——`PrivacyConsentDialog`（T24.1）。
- [ ] 不同意时提供**二次确认/最小可用**，不得因不同意非必要权限就拒绝提供基本功能。
- [ ] 隐私政策**单独成文、易于访问**，含收集目的/方式/范围、第三方共享、留存期限、联系方式——`LegalDocumentPage`（T24.5）。
- [ ] 隐私政策**版本管理**，实质变更时**重新告知并征得同意**——`ConsentStore.needsConsent(version)`（T24.1）。

### 1.2 最小必要 + SDK 管理
- [ ] 仅收集**实现功能所必需**的个人信息（最小必要原则）。
- [ ] **第三方 SDK 清单**（名称、用途、收集字段、隐私政策链接）在隐私政策中披露。
- [ ] 可选 SDK（统计/广告/推送）**在用户同意后才初始化**——`SdkInitializer`（T24.2）。
- [ ] 不在用户同意前**收集设备标识符**（IMEI/MAC/Android ID/OAID 等）或读取通讯录/位置等。

### 1.3 权限
- [ ] 权限**用时申请**、申请前说明用途（二次说明弹窗）——M09 权限模块。
- [ ] 不强制索取与功能无关的权限；被拒后核心功能仍可用。

### 1.4 用户权利
- [ ] 提供**账户注销**入口与流程（含冷静期、数据清理）——`AccountDeletionService`（T24.3）+ 设置页。
- [ ] 提供**个人信息查询 / 导出 / 删除**——`DataExportService`（T24.4）。
- [ ] 提供**撤回同意**的途径——`ConsentStore.revoke()`（T24.1）。

### 1.5 上架材料（工信部 / 应用商店）
- [ ] 完成**App 备案**（工信部，2023 起要求）。
- [ ] 商店要求的**隐私政策链接、权限清单、SDK 目录、个人信息收集清单**齐备。
- [ ] 软件著作权 / ICP（如含网络服务）按需准备。

## 2. GDPR（欧盟，如面向欧盟用户）

- [ ] **合法性基础**明确（同意 / 履行合同 / 合法利益等）。
- [ ] **明确同意**（freely given, specific, informed, unambiguous）；可像拒绝一样容易地**撤回同意**。
- [ ] **数据主体权利**：访问、更正、删除（被遗忘权）、**可携带权**（导出，T24.4）、限制处理、反对。
- [ ] **删除权**：账户注销真正清除数据（T24.3 `UserDataEraser`）。
- [ ] **隐私设计与默认**（Privacy by Design/Default）：默认最小收集（T24.2 分级）。
- [ ] 跨境传输有合法机制（SCC 等）；记录处理活动（ROPA）；必要时设 DPO。
- [ ] Cookie/SDK 同意横幅（Web/Hybrid 场景）。

## 3. CCPA/CPRA（美国加州）

- [ ] 「**Do Not Sell/Share My Personal Information**」选项（如有数据出售/共享）。
- [ ] 披露收集的个人信息**类别与目的**。
- [ ] 知情权、删除权、更正权、退出权；**不因行权而歧视**。

## 4. COPPA（美国，面向 13 岁以下儿童）

- [ ] 若面向/可能吸引儿童：**可验证的家长同意**后才收集。
- [ ] 不向儿童投放行为广告；最小化收集；提供家长查看/删除途径。
- [ ] 年龄门（age gate）设计避免诱导虚报。

## 5. 工程交付物核对（CI 可查）

- [ ] 同意状态持久化且按版本失效（`consent_store_test.dart`）。
- [ ] 可选 SDK 未同意不初始化（`sdk_initializer_test.dart`）。
- [ ] 注销冷静期与到期清理（`account_deletion_test.dart`）。
- [ ] 数据导出产出合法 JSON（`data_export_test.dart`）。
- [ ] 隐私政策/协议页含版本与生效日期（`legal_document_page_test.dart`）。

## 6. 发布前最终确认

- [ ] 隐私政策 / 用户协议**法务定稿**并替换模板占位内容（`legal_documents.dart`）。
- [ ] 第三方 SDK 清单与隐私政策披露一致。
- [ ] 各商店（App Store / 各安卓市场）隐私问卷/标签如实填写。
- [ ] 数据出境、留存期限、安全措施有据可查。

## 环境快照

Flutter 3.41.9 · Dart 3.11.5 · 个保法/GDPR/CCPA/COPPA 工程自查 · macOS。
