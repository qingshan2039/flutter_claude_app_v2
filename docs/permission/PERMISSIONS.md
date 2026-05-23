---
doc_type: implementation_guide
task_id: T09.4
module_id: M09
priority: P0
status: configured
spec_source: flutter_template_v3.md
spec_lines: "434-437"
tags: [permission, ios, android, info-plist, android-manifest, permission_handler, T09, M09]
---

# 权限管理与平台差异说明（T09.4）

> 任务：**T09.4 iOS / Android 差异封装** — 两端权限名差异由 [PermissionService] 的
> 映射函数抹平；原生声明（Info.plist / AndroidManifest）+ 差异说明集中于本文。

## 1. 架构：三层

```
业务代码  →  AppPermission (枚举, 平台无关)        lib/core/permission/app_permission.dart
            ↓ PermissionService.request()
            ↓ mapToHandler()  ← iOS/Android 差异在 permission_handler 内部抹平
         permission_handler Permission             (第三方)
            ↓ PermissionGateway (seam, 可 fake)
         platform channel → 原生权限弹窗
```

业务**只认 [AppPermission]**，never import permission_handler。

## 2. AppPermission ↔ 平台权限对照

| AppPermission | iOS | Android | 原生声明 |
|---|---|---|---|
| `camera` | AVCaptureDevice (camera) | `CAMERA` | iOS: NSCameraUsageDescription / Android: `<uses-permission CAMERA>` |
| `photos` | Photos (PHPhotoLibrary) | `READ_MEDIA_IMAGES`(13+) / `READ_EXTERNAL_STORAGE`(≤32) | iOS: NSPhotoLibraryUsageDescription |
| `microphone` | AVAudioSession | `RECORD_AUDIO` | iOS: NSMicrophoneUsageDescription |
| `location` | CLLocationManager (whenInUse) | `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION` | iOS: NSLocationWhenInUseUsageDescription |
| `notification` | UNUserNotificationCenter | `POST_NOTIFICATIONS`(13+) | Android 13+ 才需声明 |
| `storage` | （iOS 无独立存储权限，归 Photos） | `READ_EXTERNAL_STORAGE` | iOS 不适用 |
| `bluetooth` | CBManager | `BLUETOOTH_CONNECT` + `BLUETOOTH_SCAN`(12+) / `BLUETOOTH`(≤11) | iOS: NSBluetoothAlwaysUsageDescription |

permission_handler 的 `Permission.location` 等常量已在内部按平台/版本选对底层权限；我们的 [mapToHandler] 只需选对 `Permission` 常量。

## 3. 三态结果

| AppPermissionStatus | 含义 | 处理 |
|---|---|---|
| `granted` | 已授予 | 继续业务 |
| `denied` | 拒绝（可再次请求） | 可重新 request（系统会再弹） |
| `permanentlyDenied` | 永久拒绝 | **不能再弹**，引导去系统设置（[PermissionGuide]） |
| `restricted` | iOS 家长控制 / MDM 限制 | 引导去设置（同 permanentlyDenied） |
| `limited` | iOS 14+ 相册部分授权 | 视为可用（`isGranted` 返回 true） |

`AppPermissionStatusX.needsSettings` = permanentlyDenied || restricted。

## 4. 原生声明（已配置）

### 4.1 Android — [AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
```

### 4.2 iOS — [Info.plist](../../ios/Runner/Info.plist)

```xml
<key>NSCameraUsageDescription</key>          <string>...</string>
<key>NSPhotoLibraryUsageDescription</key>    <string>...</string>
<key>NSMicrophoneUsageDescription</key>      <string>...</string>
<key>NSLocationWhenInUseUsageDescription</key> <string>...</string>
<key>NSBluetoothAlwaysUsageDescription</key> <string>...</string>
```

## 5. permission_handler iOS 编译开关（重要）

permission_handler 在 iOS 用**编译宏**控制哪些权限被编入。**默认全部启用**会让 App Store
审核问询所有权限。正式项目应在 `ios/Podfile` 的 `post_install` 加宏，**只启用用到的权限**：

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_MICROPHONE=1',
        'PERMISSION_LOCATION=1',
        'PERMISSION_NOTIFICATIONS=1',
        'PERMISSION_BLUETOOTH=1',
        # 未列出的权限会被编译为「不可用」，审核更干净
      ]
    end
  end
end
```

> 本模板未默认改 Podfile（避免与 flavor / 其他配置冲突）。上线前按实际用到的权限配置宏。

## 6. 上线 checklist

- [ ] 删除 app 实际**不用**的权限（AndroidManifest + Info.plist + Podfile 宏）
- [ ] iOS usage description 文案面向用户、说明真实用途（审核会逐条看）
- [ ] Android 13+ 通知权限需运行时请求（`AppPermission.notification`）
- [ ] 定位若需后台，额外加 `ACCESS_BACKGROUND_LOCATION` + `NSLocationAlwaysAndWhenInUseUsageDescription`
- [ ] 测试永久拒绝路径：拒绝 → 永久拒绝 → [PermissionGuide] 弹窗 → 跳设置 → 返回重新 check

## 7. 使用示例

```dart
final svc = getIt<PermissionService>();

// 单个权限
final status = await svc.request(AppPermission.camera);
if (status.isGranted) {
  openCamera();
}

// 永久拒绝引导（T09.3）
final guide = PermissionGuide(svc);
final ok = await guide.ensureGranted(
  context,
  AppPermission.camera,
  rationaleTitle: 'Camera needed',
  rationaleMessage: 'Enable camera in Settings to scan codes.',
);

// 批量
final results = await svc.requestAll([
  AppPermission.camera,
  AppPermission.microphone,
]);
```

完整可交互的权限演示页见 **T19.5 权限演示页**（M19）。
