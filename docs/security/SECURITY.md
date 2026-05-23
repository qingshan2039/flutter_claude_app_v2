---
doc_type: implementation_guide
module_id: M18
priority: P0
status: implemented
spec_source: flutter_template_v3.md
spec_lines: "709-740"
tags: [security, secrets, dart-define, envied, network-security, ats, flag-secure, root-detection, M18]
related_code:
  - lib/core/env/env_config.dart
  - android/app/src/main/res/xml/network_security_config.xml
  - ios/Runner/Info.plist
  - lib/core/security/screen_security.dart
  - lib/core/security/device_integrity.dart
---

# 安全规范（M18）

> 敏感配置外部化、网络安全、ATS、防截屏、Root/越狱检测的统一说明。
> 上线前请配合 [`../SECURITY_CHECKLIST.md`](../SECURITY_CHECKLIST.md) 逐项核对。

## 1. 敏感配置外部化（T18.1）

**原则：密钥绝不进代码库。** 通过编译期注入 + gitignore 实现（沿用 M15 的
`EnvConfig` + dart-define）。

```dart
final env = ref.watch(envConfigProvider);   // 或 getIt<EnvConfig>()
env.apiKey;       // 第三方 API Key（脱敏，toString 显示 ***）
env.sentryDsn;    // Sentry DSN
```

- 注入：`--dart-define-from-file=env/<env>.json`（键：`API_KEY`、`SENTRY_DSN`、`API_BASE_URL`…）。
- `env/*.json`（真实值）已 gitignore；仓库只有 `env/*.example.json` 模板。
- `EnvConfig.toString()` 对 `apiKey`/`sentryDsn` 脱敏，避免日志泄露。

### envied（可选，更强混淆）
如需把密钥**编译进二进制并混淆**（而非明文 dart-define），可集成
[`envied`](https://pub.dev/packages/envied)：`.env` 文件（gitignore）+ `@Envied`
注解 + build_runner 生成混淆后的常量类。本模板默认用 dart-define（更简单、CI 友好）；
envied 适合「密钥必须随包分发」的场景。⚠️ 任何客户端方案都**无法绝对防逆向**，
高敏感操作应放服务端。

## 2. Android 网络安全（T18.2）

`android/app/src/main/res/xml/network_security_config.xml`（经 AndroidManifest
`android:networkSecurityConfig` 接入）：

- `base-config cleartextTrafficPermitted="false"`：release 强制 HTTPS。
- `debug-overrides`：仅 debug 放开明文 + 信任用户证书（本地调试/抓包）。
- 证书绑定（pinning）示例已注释，上线按真实域名 + 备份 pin 启用。

## 3. iOS ATS（T18.3）

`ios/Runner/Info.plist` 的 `NSAppTransportSecurity`：
- `NSAllowsArbitraryLoads=false`：默认禁止明文，强制 HTTPS。
- 需放开某域名时在 `NSExceptionDomains` 按域名最小化（勿全局放开）。

## 4. 防截屏（T18.4，可选）

```dart
// 敏感页面包一层即可（进入 FLAG_SECURE，离开自动关）
SecureScreen(child: PaymentPage());
// 或手动控制
getIt<ScreenSecurity>().enableSecure();
getIt<ScreenSecurity>().disableSecure();
```

- Android：原生 `FLAG_SECURE`（`MainActivity.kt`）——禁截屏/录屏，最近任务空白。
- iOS：系统无等价 API，需原生加「后台模糊层 + 监听截屏通知」（本模板未内置，本类在 iOS 静默降级）。

## 5. Root / 越狱检测（T18.5，可选）

```dart
final report = await getIt<DeviceIntegrityService>().check();
if (!report.isTrusted) { /* 提示风险 / 限制功能 */ }
```

- Android 原生粗检：模拟器 / 可调试 / su 路径（`MainActivity.kt`）。
- 未实现平台 → 返回默认「可信」（保守，不误杀）。
- ⚠️ 生产级检测是攻防对抗，应换成 **Play Integrity API**（Android）/
  **DeviceCheck + App Attest**（iOS）或 `flutter_jailbreak_detection`；本类是统一接口（seam），便于替换。

## 6. 测试要点

- `EnvConfig.apiKey`：默认空、可覆盖、toString 脱敏（`test/core/env/env_config_test.dart`）。
- `ScreenSecurity` / `DeviceIntegrity`：MethodChannel mock 断言调用 + 优雅降级
  （`test/core/security/*_test.dart`）。
- 原生编译：`flutter build apk --flavor dev`（验证 MainActivity + net config）。
