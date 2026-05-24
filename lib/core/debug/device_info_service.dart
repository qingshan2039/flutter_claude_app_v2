import 'dart:io';

import 'package:injectable/injectable.dart';

/// 设备信息（T29.6）。
///
/// 用 `dart:io` 的 [Platform] 提供零依赖的设备/系统信息快照。更细的机型信息
/// （厂商/型号）可接入 `device_info_plus`，精确 App 版本可接入 `package_info_plus`；
/// 本服务用 `--dart-define=APP_VERSION` 注入的版本兜底。
@lazySingleton
class DeviceInfoService {
  const DeviceInfoService();

  /// 由 dart-define 注入的 App 版本（缺省取 pubspec 版本占位）。
  static const String appVersion =
      String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  Map<String, String> snapshot() => <String, String>{
    '操作系统': Platform.operatingSystem,
    '系统版本': Platform.operatingSystemVersion,
    'App 版本': appVersion,
    'Dart 版本': Platform.version.split(' ').first,
    'CPU 核心数': '${Platform.numberOfProcessors}',
    'locale': Platform.localeName,
  };
}
