---
doc_type: checklist
module_id: M18
priority: P0
status: implemented
spec_source: flutter_template_v3.md
spec_lines: "709-740"
tags: [security, checklist, release, secrets, network, storage, obfuscation, M18]
---

# 上线前安全检查清单（M18 / T18.6）

> 每次发布（尤其首次上架）前逐条核对。✅=已满足，⬜=待办，N/A=不适用。
> 关联模块在括号注明，便于定位实现。

## 1. 敏感配置 / 密钥（M15 / M18·T18.1）

- [ ] 代码里**没有任何**硬编码的 API Key / 密钥 / 令牌 / 密码（全局搜索 `secret`、`apiKey`、`token=`、私钥头 `BEGIN PRIVATE KEY`）。
- [ ] 密钥经 `--dart-define` / `--dart-define-from-file` 注入（`EnvConfig`：`apiKey`/`sentryDsn`）。
- [ ] `env/*.json`（真实值）已被 `.gitignore`；仓库只有 `env/*.example.json` 模板。
- [ ] CI / 打包用 Secrets 注入密钥，不写进 workflow / 脚本。
- [ ] Android 签名 `key.properties` 与 keystore 不入库（已在 `android/.gitignore`），且**异地加密备份**。
- [ ] 日志不打印密钥/PII：检查 `LoggingInterceptor` 与 `LogSanitizer`（M11/T11.3）脱敏覆盖 token/password/phone。

## 2. 网络安全（M04 / M18·T18.2/T18.3）

- [ ] 全站 **HTTPS**；Android `network_security_config.xml` `cleartextTrafficPermitted=false`（release）。
- [ ] iOS ATS `NSAllowsArbitraryLoads=false`；如有例外，按域名最小化（非全局放开）。
- [ ] 生产域名上线前关掉 debug 明文/用户证书例外（debug-overrides 仅 debug 生效，确认 release 未放开）。
- [ ] 如做证书绑定（pinning）：配置真实 pin + **备份 pin**（防证书轮换锁死），并设过期日。
- [ ] 关闭/移除抓包代理信任、测试后门、mock 开关在 release 构建。

## 3. 本地存储（M05）

- [ ] 敏感数据（token、凭据）只存 `SecureStorage`（Keychain / EncryptedSharedPreferences），**不进** SharedPreferences / 明文 Hive。
- [ ] 缓存/数据库不持久化敏感 PII；必要时加密。
- [ ] 登出 / 账号切换时彻底清除敏感存储。

## 4. 认证与会话（M04 / M07）

- [ ] Token 失效 / 401 有刷新或登出流程（`AuthInterceptor`）。
- [ ] 路由守卫拦截未登录访问受保护页（`authRedirect`，M07/T07.4）。
- [ ] 深链 / Universal Links 入参做校验，不信任外部传入。

## 5. 客户端加固（M16 / M18·T18.4/T18.5）

- [ ] release 开启代码混淆：R8（`isMinifyEnabled`）+ Dart `--obfuscate --split-debug-info`（M16/T16.6）。
- [ ] 符号文件（`build/symbols/<flavor>`、iOS dSYM）按版本留存/上传，供崩溃还原。
- [ ] 敏感页面（支付/隐私）用 `SecureScreen` 防截屏（Android FLAG_SECURE；iOS 需原生模糊层）。
- [ ] 视风险接入 Root/越狱检测（`DeviceIntegrityService`），生产替换为 Play Integrity / DeviceCheck 等专门方案。
- [ ] release 构建 `isDebuggable=false`（勿用 debug 签名上架）。

## 6. 权限与隐私（M09 / M24）

- [ ] 只声明**实际使用**的权限；删除 AndroidManifest / Info.plist 中不用的权限与用途说明。
- [ ] iOS 每个权限有面向用户的 `NS*UsageDescription`（缺失会被审核拒）。
- [ ] 有隐私政策入口；首启合规弹窗（M24 隐私合规模块）。

## 7. 依赖与供应链

- [ ] `flutter pub outdated` 检查依赖，无已知高危漏洞版本。
- [ ] 不引入来路不明 / 长期无维护的包；审查权限敏感插件源码。
- [ ] `pubspec.lock` 入库，锁定可复现的依赖版本。

## 8. 构建 / 发布

- [ ] 用正确 flavor + 正式签名打 release（`scripts/build_android.sh prod aab` / `scripts/build_ios.sh prod`）。
- [ ] CI 通过：format + analyze（very_good_analysis）+ test（M16/M17）。
- [ ] 移除调试日志洪泛（prod `enableLogging=false`）、内置 Debug 面板（M29）在 release 关闭。
- [ ] 版本号 / build number 已递增。

## 9. 快速自检命令

```bash
# 搜可疑硬编码密钥（应无业务命中）
grep -rinE "(api[_-]?key|secret|password|token)\s*[:=]\s*['\"][A-Za-z0-9_\-]{12,}" lib/

# 确认真实 env 未被跟踪（应只列出 *.example.json）
git ls-files env/

# 静态分析 + 测试
flutter analyze && flutter test
```
