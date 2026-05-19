---
doc_type: implementation_guide
task_id: T07.5
module_id: M07
priority: P0
status: configured
spec_source: flutter_template_v3.md
spec_lines: "360-364"
tags: [routing, deep-link, universal-link, app-link, android, ios, T07, M07]
---

# 深链接配置说明（T07.5）

> 任务：**T07.5 深链接配置** — 完成 Android 与 iOS 两端的原生配置 + go_router 自动处理。
> 本文档把所需的原生改动、测试命令、上线检查清单集中说明。

## 1. 已配置的两套链路

| 类型 | 示例 URL | 用途 |
|---|---|---|
| 自定义 scheme | `fcaapp://detail/42` | 应用专属、不强制域名，开发阶段最常用 |
| Android App Links / iOS Universal Links | `https://app.example.com/detail/42` | 走 https，被浏览器/邮件原生识别；需要域名 + assetlinks/apple-app-site-association 文件 |

go_router 在两端都**自动**接管来自 OS 的深链 intent / userActivity，把 path 映射到对应路由。**Flutter 业务代码无需任何额外处理**。

## 2. Android 配置（已落地）

[android/app/src/main/AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml) 在 `MainActivity` 内新增两个 `intent-filter`：

```xml
<!-- 自定义 scheme -->
<intent-filter android:autoVerify="false">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="fcaapp"/>
</intent-filter>

<!-- App Links（autoVerify=true 需配合 assetlinks.json） -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="https"
          android:host="app.example.com"/>
</intent-filter>
```

**上线前必改**：把 `app.example.com` 替换为真实业务域名。

### 2.1 App Links 域名验证（assetlinks.json）

把以下文件部署到 `https://app.example.com/.well-known/assetlinks.json`：

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.ben.claude_flutter_v2.flutter_claude_app_v2",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:..."   // ← 用 `keytool -list -v -keystore ...` 拿 release 签名 SHA-256
      ]
    }
  }
]
```

验证：

```bash
adb shell pm verify-app-links --re-verify com.ben.claude_flutter_v2.flutter_claude_app_v2
adb shell pm get-app-links com.ben.claude_flutter_v2.flutter_claude_app_v2
# 应看到 verified 状态
```

### 2.2 测试命令（ADB）

```bash
# 自定义 scheme
adb shell am start -W -a android.intent.action.VIEW -d "fcaapp://detail/42"

# App Link（验证后浏览器跳应用，未验证则弹选择器）
adb shell am start -W -a android.intent.action.VIEW -d "https://app.example.com/detail/42"
```

## 3. iOS 配置（已落地）

[ios/Runner/Info.plist](../../ios/Runner/Info.plist) 新增 3 项：

```xml
<key>FlutterDeepLinkingEnabled</key>
<true/>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.ben.claude_flutter_v2</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>fcaapp</string>
        </array>
    </dict>
</array>
```

`FlutterDeepLinkingEnabled = true` 让 Flutter 引擎接管 universalLink，否则要在 AppDelegate 手动桥接。

### 3.1 Universal Links（associated-domains）

需要 Xcode 中开启 Capability「Associated Domains」，自动生成 `ios/Runner/Runner.entitlements`：

```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:app.example.com</string>
</array>
```

服务端部署 `https://app.example.com/.well-known/apple-app-site-association`：

```json
{
  "applinks": {
    "details": [
      {
        "appIDs": ["TEAM_ID.com.ben.claude_flutter_v2.flutter_claude_app_v2"],
        "components": [
          { "/": "/detail/*", "comment": "match detail pages" }
        ]
      }
    ]
  }
}
```

Apple CDN 缓存这个文件 ~24 小时；测试时 iOS Settings → Developer → Universal Links → "Diagnostic" 强制重新拉取。

### 3.2 测试命令

```bash
# 模拟器自定义 scheme
xcrun simctl openurl booted "fcaapp://detail/42"

# 模拟器 Universal Link
xcrun simctl openurl booted "https://app.example.com/detail/42"
```

注：自定义 scheme 不需要任何域名验证，立刻可用。Universal Links 必须在真机 + 已部署 AASA 文件后测试。

## 4. Flutter / go_router 端的处理

go_router **自动**接管 platform 发来的初始 URL 与运行时 deep link 事件：

- 应用启动：`GoRouter.maybePop` / 路由匹配
- 应用运行中：监听 `WidgetsBinding.instance.platformDispatcher.onPushRoute` 等回调

业务代码**无需写任何 deep link 监听**。如果某个深链需要参数解析，正常用 `state.uri.path` / `state.uri.queryParameters` 即可。

如需自定义处理（如打开前清缓存 / 弹确认），用 `GoRouter.redirect` 拦截：

```dart
GoRouter(
  redirect: (context, state) {
    if (state.uri.path.startsWith('/detail') && needLogin) {
      return '/login';
    }
    return null;
  },
);
```

模板的 [authRedirect](../../lib/core/router/auth_redirect.dart) 已经这么做。

## 5. 上线 checklist

- [ ] 替换 `app.example.com` 为真实业务域名（AndroidManifest + Info.plist + entitlements）
- [ ] 在域名服务器部署 `.well-known/assetlinks.json` + `apple-app-site-association`
- [ ] Android: 用 release keystore 的 SHA-256 fingerprint 填到 assetlinks.json
- [ ] iOS: Apple Developer 后台 enable Associated Domains capability
- [ ] iOS: TestFlight 真机测试一次 universal link（模拟器不验证 AASA）
- [ ] 把所有 deep link 路径列入 QA 测试用例（错误路径 → 404，受限路径 → 跳登录）

## 6. 安全注意

- 自定义 scheme `fcaapp://` 是公开的：恶意应用可拦截相同 scheme 的 URL。**敏感操作（如重置密码、支付确认）必须用 App Links / Universal Links**（有签名/域名验证）。
- 不要在深链 URL 中传 token；token 仍走 secure storage（M05）。深链只做导航与上下文（id、tab 等）。

## 7. 参考

- [Flutter 官方深链文档](https://docs.flutter.dev/ui/navigation/deep-linking)
- [go_router README — Deep Linking](https://pub.dev/packages/go_router#deep-linking)
- [Android App Links 验证文档](https://developer.android.com/training/app-links/verify-android-applinks)
- [Apple Universal Links 入门](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
