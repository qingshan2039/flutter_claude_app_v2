---
doc_type: implementation_guide
task_id: T04.9
module_id: M04
priority: P0
optional: true
spec_source: flutter_template_v3.md
spec_lines: "279-282"
status: documentation_only
tags: [network, security, ssl-pinning, certificate, dio, T04, M04]
---

# SSL Pinning 配置说明（T04.9）

> 任务：**T04.9 SSL Pinning（可选）** — Spec 中标注为可选实施。
> 本文档作为交付物，**未默认启用 pinning**——仅给出在需要时如何接入的步骤与示例。

## 1. 为何不默认启用

SSL Pinning 绑定证书 / 公钥到客户端，能防 MITM 攻击。代价是：

- 证书轮换需要发版（或预置多套备用证书）
- 错误配置会让所有请求失败、用户无法使用
- 不同环境（dev / staging / prod）证书不同

因此 **默认关闭**，由各业务团队自行评估是否启用。

## 2. 接入步骤（HTTP 公钥固定，推荐）

### 2.1 准备指纹

获取目标 API 域名证书公钥的 SHA-256 指纹（base64）：

```bash
# macOS / Linux
echo | openssl s_client -servername api.example.com -connect api.example.com:443 2>/dev/null \
  | openssl x509 -pubkey -noout \
  | openssl rsa -pubin -outform der 2>/dev/null \
  | openssl dgst -sha256 -binary \
  | openssl enc -base64
# 输出形如：oCWBYy4eAfTGGD9YDeSGTbZkM6IhzGYS3UkSXz+P51U=
```

强烈建议**同时收集备用证书**（如 CA Intermediate + Root），避免主证书轮换导致全量请求失败。

### 2.2 安装拦截器（Dio + dart:io）

把以下方法集成到 [lib/core/network/dio_client.dart](../../lib/core/network/dio_client.dart) 的 `provideDio`：

```dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:crypto/crypto.dart';   // dev dependency；按需添加

void _enableSslPinning(Dio dio, {required List<String> allowedPins}) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient(context: SecurityContext(withTrustedRoots: true));
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final fingerprint = base64Encode(
        sha256.convert(cert.der).bytes,
      );
      return allowedPins.contains(fingerprint);
    };
    return client;
  };
}
```

调用：

```dart
const enablePinning = bool.fromEnvironment('SSL_PINNING_ENABLED', defaultValue: false);
if (enablePinning) {
  _enableSslPinning(dio, allowedPins: [
    'oCWBYy4eAfTGGD9YDeSGTbZkM6IhzGYS3UkSXz+P51U=',  // primary
    'r1XJ9YIYDDl5GjkdfsdsmkldsffwerwerSXxOq+Pe6Y=',  // backup
  ]);
}
```

### 2.3 开关控制

通过 `--dart-define SSL_PINNING_ENABLED=true` 在编译期开关：

```bash
# 开发：默认关闭
flutter run

# 生产：开启
flutter build apk --release --dart-define SSL_PINNING_ENABLED=true
```

M15/T15.3 完成后，可改为从 `EnvConfig.enableSslPinning` 读取，避免命令行参数泄漏。

## 3. 测试策略

启用后需测试：

1. **正常路径**：合法证书 + 匹配 pin → 请求成功
2. **MITM 模拟**：本地 Charles / mitmproxy 注入自签证书 → 请求被拒
3. **证书轮换**：临时换 server 证书 → 备用 pin 仍匹配 → 请求成功
4. **错配置**：清空 pins → 所有 https 请求 fail-closed（用于回滚验证）

## 4. 与现有 M04 拦截器的关系

- pinning 作用在 `HttpClient` 层，**不是** dio interceptor，无法被 [LoggingInterceptor]
  / [ApiErrorInterceptor] 链式处理
- pinning 失败时 dio 抛 `DioExceptionType.badCertificate`，会被 [ApiErrorInterceptor]
  转为 [NetworkException]（code: `BAD_CERT`）
- [RetryInterceptor] **不**对 `badCertificate` 重试（见 [retry_interceptor.dart](../../lib/core/network/interceptors/retry_interceptor.dart) `shouldRetry`）

## 5. 替代方案

若不接受运维负担：

- **Android Network Security Config**（M18/T18.2）：在 `AndroidManifest` 中通过 XML 配置
  pinning，无需运行时代码。代价：iOS 仍要手工实现
- **CT (Certificate Transparency) 监控**：被动监测异常证书，事后告警
- **App Attestation**（DeviceCheck / SafetyNet）：从设备端验证完整性，间接防 MITM

## 6. 参考

- [OWASP Mobile App Security Testing Guide — Certificate Pinning](https://owasp.org/www-project-mobile-app-security-testing-guide/)
- [Dio IOHttpClientAdapter 源码](https://github.com/cfug/dio/blob/main/dio/lib/src/adapters/io_adapter.dart)
- [Flutter SSL pinning 官方建议](https://docs.flutter.dev/cookbook/networking/web-sockets)

---

**文档维护**: 与 M04 网络层同步更新。M18/T18.2（Android 网络安全配置）落地后请回链。
