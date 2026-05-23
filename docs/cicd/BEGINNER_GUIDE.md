---
doc_type: tutorial
module_id: M16
audience: [human_beginners]
status: implemented
tags: [tutorial, beginner, git-hooks, lefthook, ci, cd, github-actions, build, signing, fastlane, M16]
related_code:
  - lefthook.yml
  - scripts/check_commit_msg.sh
  - .github/workflows/ci.yml
  - scripts/build_android.sh
  - scripts/build_ios.sh
  - scripts/flutter-env.sh
  - android/app/build.gradle.kts
---

# M16 实战手册（新手向）：Git Hooks · CI/CD · 打包

> 这份文档面向**第一次接触** git hooks / CI/CD / 移动端打包的人。每一步都给出
> 可直接复制的命令、预期输出和出错怎么办。跟着做即可，不需要先懂原理。
>
> 想要简明速查版（给熟手）请看同目录 [`CICD.md`](./CICD.md)。

---

## 0. 先记住三句话

1. **Git Hooks**：你每次 `git commit` 时，电脑自动帮你「格式化代码 + 查错 + 检查提交信息」。不合格就**拦下来不让提交**。
2. **CI/CD**：你把代码推到 GitHub 后，GitHub 的服务器自动帮你「再查一遍 + 跑测试 +（在主分支）打包」。
3. **打包**：把代码变成能装到手机上的文件（Android 的 `.apk`/`.aab`、iOS 的 `.ipa`）。本项目有三套环境 dev/staging/prod，用脚本一键打。

> 名词对照：CI = 持续集成（自动检查+测试）；CD = 持续交付（自动打包/发布）；
> flavor = 「环境风味」，同一份代码打成 dev/staging/prod 三个互不冲突的 App。

---

## 1. 准备工作（每台电脑只做一次）

### 1.1 确认 Flutter 能用

打开终端（macOS 的「终端」/ VSCode 里的 Terminal），在项目根目录运行：

```bash
flutter doctor
```

看到 Flutter、Android toolchain 基本是 ✓ 即可（iOS 那行需要 Mac + Xcode）。

### 1.2 项目根目录在哪

本手册所有命令都假设你**在项目根目录**执行（就是有 `pubspec.yaml` 的那层）：

```bash
cd /path/to/flutter_claude_app_v2
ls pubspec.yaml      # 能列出来就对了
```

### 1.3 拉依赖

```bash
flutter pub get
```

---

## 2. Git Hooks（用 lefthook）

### 2.1 它帮你做什么

本项目在 `lefthook.yml` 里配了两个「钩子」：

| 触发时机 | 自动做的事 | 不通过的后果 |
|---|---|---|
| `git commit` 之前（pre-commit） | 1) 对你**改动的** `.dart` 文件 `dart format`（自动格式化并重新加入暂存）<br>2) `flutter analyze`（全项目静态检查） | analyze 有问题 → **提交被拦下** |
| 写完提交信息后（commit-msg） | 校验提交信息是否符合 **Conventional Commits** 规范 | 不符合 → **提交被拦下** |

好处：团队代码风格统一、坏代码进不了仓库、提交历史整齐。

### 2.2 安装 lefthook（一次性）

lefthook 是一个小工具（不是 Dart 包，是个独立程序）。三选一安装：

```bash
# 方式 A：macOS / Homebrew（推荐）
brew install lefthook

# 方式 B：用 Dart 全局安装
dart pub global activate lefthook

# 方式 C：npm（如果你有 Node）
npm install -g lefthook
```

验证装好了：

```bash
lefthook version      # 能打印版本号即可
```

### 2.3 启用钩子（一次性，关键！）

**装了工具还不够**，必须在项目里「安装钩子」，它才会写进 `.git/hooks/`：

```bash
lefthook install
```

预期输出类似：`sync hooks: ✔️ (pre-commit, commit-msg)`。

> 💡 每个克隆下来的新副本都要执行一次 `lefthook install`。换电脑/重新 clone 记得再来一次。

### 2.4 实际提交时会发生什么

正常改完代码后：

```bash
git add lib/some_file.dart
git commit -m "feat(home): 增加下拉刷新"
```

你会看到 lefthook 依次跑 `format` 和 `analyze`：

- 如果某个 `.dart` 没格式化好，它会**自动格式化并帮你重新 `git add`**，提交照常进行。
- 如果 `flutter analyze` 报错，提交会**中断**，终端会列出问题。→ 去 [2.6](#26-钩子失败了怎么办) 修。

接着校验提交信息（见下一节）。

### 2.5 提交信息怎么写（Conventional Commits）

格式：

```
<type>(<scope>): <描述>
```

- `type`（**必填**，只能是这些）：`feat` `fix` `docs` `style` `refactor` `perf` `test` `build` `ci` `chore` `revert`
- `scope`（可选）：影响范围，如 `env`、`home`、`m16`
- `描述`：一句话说清做了什么

✅ **正确示例**：

```
feat(env): 增加 staging flavor
fix: 修复登录态丢失
docs(cicd): 补充打包步骤
refactor(network)!: 重构拦截器（! 表示破坏性变更）
```

❌ **会被拦下的**：

```
随便写的              # 没有 type
update code          # update 不是合法 type
修复bug              # 没有 type:
```

被拦下时终端会打印（实测输出）：

```
❌ commit message 不符合 Conventional Commits 规范：
   "随便写的"
   正确格式：<type>(<scope>): <描述>
   type 可选值：feat fix docs style refactor perf test build ci chore revert
```

> `Merge`/`Revert`/`fixup!` 开头的自动提交会被放行，不用担心。

### 2.6 钩子失败了怎么办

| 现象 | 原因 | 解决 |
|---|---|---|
| `flutter analyze` 报错，提交中断 | 代码有 lint/编译问题 | 终端会写明文件:行号。先 `dart fix --apply` 自动修，再 `flutter analyze` 看还剩啥，手动改完重新 `git add` + `git commit` |
| 提示 commit message 不规范 | 信息没按格式写 | 按 [2.5](#25-提交信息怎么写conventional-commits) 重写 |
| `lefthook: command not found` | 没装/没装好 | 回 [2.2](#22-安装-lefthook一次性) |
| 改了代码但钩子没触发 | 没执行 `lefthook install` | 跑一次 `lefthook install` |

### 2.7 紧急跳过钩子（慎用）

极少数情况（比如 CI 修复中）需要跳过：

```bash
git commit -m "feat: xxx" --no-verify     # 跳过所有钩子
LEFTHOOK=0 git commit -m "feat: xxx"      # 同上
```

> ⚠️ 正常开发**不要**跳过。跳过 = 把没检查的代码塞进仓库，CI 大概率会替你拦下来（见第 3 章）。

---

## 3. CI/CD（GitHub Actions）

### 3.1 概念

你推代码到 GitHub 后，GitHub 提供的免费服务器会**自动**按 `.github/workflows/ci.yml` 的剧本跑一遍。你不用守着，结果会显示在网页上（✅/❌）。

### 3.2 本项目的 CI 什么时候跑、跑什么

`.github/workflows/ci.yml` 定义了两个「job（任务）」：

| job | 什么时候跑 | 做什么 |
|---|---|---|
| **analyze-and-test** | 每次开 PR、每次推送 | 格式检查 → `flutter analyze` → `flutter test` → 校验生成代码是否最新 |
| **build-android** | 仅当推送到 **main** 分支 | 打 **prod** 的安装包（AAB，含混淆），上传成可下载的「artifact」 |

### 3.3 第一次让 CI 跑起来

CI 是「推上去就自动触发」的，你只要正常用 git：

```bash
# 1) 新建一个分支做改动（推荐，不直接在 main 上改）
git checkout -b feat/my-change

# 2) 改代码 → 提交（会过 git hooks）
git add .
git commit -m "feat: 我的改动"

# 3) 推到 GitHub
git push -u origin feat/my-change
```

然后到 GitHub 仓库页面，点 **Pull requests → New pull request**，把 `feat/my-change` 合并到 `main`，创建 PR。**创建后 CI 自动开始跑。**

### 3.4 在 GitHub 上看结果

- **PR 页面底部**：会出现一块检查区，绿勾 ✅ = 通过，红叉 ❌ = 失败。
- **仓库顶部 Actions 标签页**：能看到每次运行的详细日志。点进某次运行 → 点某个 job → 展开步骤，看是哪一步红了。

### 3.5 CI 失败了怎么排（最重要）

CI 跑的命令**和你本地能跑的一模一样**。先在本地复现：

```bash
dart format --output=none --set-exit-if-changed lib test   # 格式检查
flutter analyze                                             # 静态分析
flutter test                                                # 测试
```

- 格式那条报错 → 运行 `dart format .` 然后提交。
- analyze 报错 → `dart fix --apply` + 手动修。
- test 报错 → 看是哪个测试，本地修好。
- 「生成代码不一致」报错 → 运行 `dart run build_runner build --delete-conflicting-outputs`，把改动一起提交。

修好后再 `git push`，CI 会自动重跑。

### 3.6 进阶：给 CI 配密钥（真实发布才需要）

模板 CI 用的是**示例配置**（`env/*.example.json`、debug 签名），能跑通但不是真发布。真实发布时：

1. 在 GitHub 仓库 **Settings → Secrets and variables → Actions** 添加密钥（如 `PROD_ENV_JSON`、`ANDROID_KEYSTORE_BASE64`、`KEY_PROPERTIES`）。
2. 在 workflow 里把 Secret 写到文件再构建（示例思路）：
   ```yaml
   - run: echo "${{ secrets.PROD_ENV_JSON }}" > env/prod.json
   - run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/keystore.jks
   ```
3. **永远不要**把真实密钥写进代码或提交到仓库。

### 3.7 下载 CI 打出来的包

main 分支跑完 build-android 后：Actions → 选那次运行 → 页面底部 **Artifacts** → 下载 `app-prod-release`（里面有 `.aab` 和符号文件）。

---

## 4. 打包（出安装包）

### 4.1 先理解：3 套环境 × 产物类型

- 环境（flavor）：`dev`（开发）、`staging`（预发）、`prod`（生产）。包名、App 名、图标互不相同，可同时装在一台手机上。
- Android 产物：`apk`（可直接安装/分发测试）、`aab`（上架 Google Play 用）。
- iOS 产物：`ipa`（可上传 TestFlight / App Store）。

### 4.2 Android 打包

#### 4.2.1 最简单：先跑起来看看（debug）

连上手机/模拟器后：

```bash
scripts/flutter-env.sh dev run
```

> 这条等价于 `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.json`。
> 第一次会提示你从模板建 `env/dev.json`：`cp env/dev.example.json env/dev.json`。

#### 4.2.2 出 release 安装包（用脚本，推荐）

```bash
# 出 dev 的 APK（适合发给测试同学直接装）
scripts/build_android.sh dev apk

# 出 prod 的 AAB（上架 Google Play 用）
scripts/build_android.sh prod aab
```

预期最后一行（实测）：

```
✓ Built build/app/outputs/flutter-apk/app-dev-release.apk
✅ 完成。符号文件：build/symbols/dev（请留存用于崩溃还原）
```

产物位置：

| 类型 | 路径 |
|---|---|
| APK | `build/app/outputs/flutter-apk/app-<flavor>-release.apk` |
| AAB | `build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab` |
| 混淆符号 | `build/symbols/<flavor>/*.symbols`（**务必留存**，见 4.2.4） |

#### 4.2.3 配置正式签名（上架前必做）

没配签名时，脚本会用 **debug 签名**（只能本地玩，不能上架）。正式签名步骤：

**第 1 步：生成 keystore（密钥库，一次性，妥善保管！丢了就无法更新 App）**

```bash
keytool -genkey -v -keystore ~/ccd-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias ccd
```

按提示设密码、填信息。

**第 2 步：在 `android/key.properties` 写入（这个文件已被 .gitignore，不会进仓库）**

```properties
storeFile=/Users/你的用户名/ccd-release.jks
storePassword=你设置的库密码
keyAlias=ccd
keyPassword=你设置的key密码
```

**第 3 步：再次打包，会自动用正式签名**

```bash
scripts/build_android.sh prod aab
```

> 原理：`android/app/build.gradle.kts` 检测到 `key.properties` 存在就用正式签名，否则回退 debug。

#### 4.2.4 混淆与崩溃还原

脚本默认带 `--obfuscate --split-debug-info`：代码被混淆（更难逆向），同时在 `build/symbols/<flavor>/` 生成**符号文件**。

- 上线后用户崩溃，崩溃栈是「乱码」，用符号文件还原成可读堆栈：
  ```bash
  flutter symbolize -i 崩溃栈.txt -d build/symbols/prod/app.android-arm64.symbols
  ```
- ⚠️ **每个发布版本的符号文件都要单独存档**（或上传到 Sentry），否则线上崩溃永远看不懂。

### 4.3 iOS 打包（需要 Mac + Xcode + 苹果开发者账号）

> 没有 Mac 可跳过本节。iOS 发布强依赖苹果生态。

#### 4.3.1 一次性准备

1. Xcode 里为 Runner 配好签名（Team、Bundle ID）。
2. 为 dev/staging/prod 建 scheme（详见 [`../env/ENVIRONMENTS.md`](../env/ENVIRONMENTS.md) 的 iOS flavor 一节）。
3. 安装 fastlane：`brew install fastlane`，并在 `ios/fastlane/Appfile` 填好账号信息。

#### 4.3.2 打包 / 上传 TestFlight

```bash
# 只出 .ipa
scripts/build_ios.sh prod ipa

# 出包并经 fastlane 上传到 TestFlight（需配好 App Store Connect API Key 环境变量）
scripts/build_ios.sh prod testflight
```

App Store Connect API Key（`ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_CONTENT`）通过**环境变量**提供，切勿写进代码。

---

## 5. 一页速查表

```bash
# —— Git Hooks ——
brew install lefthook && lefthook install   # 安装并启用（每个 clone 一次）
git commit -m "feat(scope): 描述"           # 正常提交（自动 format+analyze+校验）

# —— 本地预跑 CI 会做的检查 ——
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs

# —— 运行 / 打包 ——
scripts/flutter-env.sh dev run              # 跑 dev
scripts/build_android.sh dev apk            # dev APK（测试分发）
scripts/build_android.sh prod aab           # prod AAB（上架）
scripts/build_ios.sh prod testflight        # iOS → TestFlight（需 Mac）

# —— 触发 CI ——
git push -u origin feat/my-change           # 推分支 → 在 GitHub 开 PR → CI 自动跑
```

---

## 6. 常见问题 FAQ

**Q：`scripts/build_android.sh: Permission denied`？**
A：给执行权限：`chmod +x scripts/*.sh`。

**Q：构建报错 `flutter run` 提示要 `--flavor`？**
A：本项目加了 flavor，原生运行/构建必须带 `--flavor`。用脚本（已自动带）或手动加 `--flavor dev`。

**Q：`env/dev.json` 找不到？**
A：从模板复制：`cp env/dev.example.json env/dev.json`，再按需填真实值。该文件不入库。

**Q：CI 一直红，但本地是绿的？**
A：确认本地跑的是和 CI 一样的命令（见 [3.5](#35-ci-失败了怎么排最重要)）；特别是「生成代码一致性」——记得提交 `build_runner` 产物。

**Q：提交被 commit-msg 拦住，但我就想快速存一下？**
A：先按规范写（`chore: wip` 也是合法的）。实在要跳过用 `--no-verify`，但不推荐。

**Q：keystore 丢了会怎样？**
A：**无法再更新已上架的 App**。请像保管身份证一样保管 keystore 和密码（建议加密备份多份）。
