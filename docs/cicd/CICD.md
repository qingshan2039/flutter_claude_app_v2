---
doc_type: implementation_guide
module_id: M16
priority: P0
status: implemented
spec_source: flutter_template_v3.md
spec_lines: "629-673"
tags: [ci, cd, lint, lefthook, github-actions, fastlane, proguard, obfuscation, M16]
related_code:
  - analysis_options.yaml
  - lefthook.yml
  - .github/workflows/ci.yml
  - scripts/build_android.sh
  - scripts/build_ios.sh
  - ios/fastlane/
  - android/app/proguard-rules.pro
---

# 代码质量与 CI/CD（M16）

> 静态分析、git hooks、CI、打包、混淆、协作模板一站式说明。

## 1. 静态分析（T16.1）

基于 `very_good_analysis`（见 `analysis_options.yaml`），关闭了 14 条高噪声/与设计冲突的规则（每条注明原因）。

```bash
flutter analyze        # 必须零问题
dart fix --apply       # 自动修
dart format .          # 统一格式
```

> ⚠️ 已关闭 `avoid_redundant_argument_values`：它与 `dart fix` 联手会把「编译期常量
> 折叠成默认值」的实参误删，曾导致 `EnvConfig` 的 dart-define 覆盖被静默移除
> （详见 `docs/verification/T16.1.md`）。

## 2. Git Hooks（T16.2）

```bash
brew install lefthook && lefthook install
```
- pre-commit：暂存 .dart `dart format` + `flutter analyze`
- commit-msg：Conventional Commits 校验（`scripts/check_commit_msg.sh`）

## 3. CI（T16.3）

`.github/workflows/ci.yml`：
- PR/push：format check → analyze → test → codegen 一致性（build_runner 后无 diff）
- push main：构建 prod AAB（混淆 + 符号）上传 artifact

## 4. 打包（T16.4 / T16.5）

```bash
# Android（多 flavor，自动 R8 + 混淆 + 符号）
scripts/build_android.sh prod aab
scripts/build_android.sh dev apk

# iOS（需 macOS + Xcode + 凭据）
scripts/build_ios.sh prod ipa
scripts/build_ios.sh prod testflight     # fastlane :beta
```

### Android 签名
在 `android/key.properties`（不入库）配置：
```properties
storeFile=../keystore.jks
storePassword=***
keyAlias=***
keyPassword=***
```
缺失时 release 回退 debug 签名（仅本地）。

### iOS 凭据
`ios/fastlane/Appfile` + 环境变量（`ASC_KEY_ID`/`ASC_ISSUER_ID`/`ASC_KEY_CONTENT`）。

## 5. 混淆（T16.6）

- Android R8：release `isMinifyEnabled` + `isShrinkResources` + `proguard-rules.pro`
- Dart：`--obfuscate --split-debug-info=build/symbols/<flavor>`
- 崩溃还原：
  ```bash
  flutter symbolize -i stack.txt -d build/symbols/prod/app.android-arm64.symbols
  ```
- iOS dSYM：`fastlane upload_symbols`（→ Sentry）

> **务必随每个发布版本留存/上传符号文件**，否则线上崩溃栈无法还原。

## 6. 协作模板（T16.7）

`.github/pull_request_template.md` + `.github/ISSUE_TEMPLATE/{bug_report,feature_request,config}`。

## 7. 验证要点

| 阶段 | 命令 / 证据 |
|---|---|
| 静态分析 | `flutter analyze` → No issues（very_good_analysis） |
| 单元测试 | `flutter test` → 403 passed |
| 运行调用 | `scripts/build_android.sh dev apk` → app-dev-release.apk（R8+混淆） |
| 代码生成 | `dart run build_runner build` 通过；CI 校验无 diff |
| 依赖注册 | very_good_analysis(dev) + meta 已加入 pubspec |
