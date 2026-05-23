import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

/// 设备完整性报告（T18.5）。
@immutable
class DeviceIntegrityReport {
  const DeviceIntegrityReport({
    this.isRootedOrJailbroken = false,
    this.isEmulator = false,
    this.isDebuggable = false,
  });

  factory DeviceIntegrityReport.fromMap(Map<String, dynamic> map) {
    return DeviceIntegrityReport(
      isRootedOrJailbroken: map['isRootedOrJailbroken'] as bool? ?? false,
      isEmulator: map['isEmulator'] as bool? ?? false,
      isDebuggable: map['isDebuggable'] as bool? ?? false,
    );
  }

  /// 设备已 root（Android）/ 越狱（iOS）。
  final bool isRootedOrJailbroken;

  /// 运行在模拟器上。
  final bool isEmulator;

  /// 应用为可调试构建（release 应为 false）。
  final bool isDebuggable;

  /// 是否「可信」：未 root / 未越狱（最常用的拦截依据）。
  bool get isTrusted => !isRootedOrJailbroken;

  @override
  String toString() =>
      'DeviceIntegrityReport(rootedOrJailbroken: $isRootedOrJailbroken, '
      'emulator: $isEmulator, debuggable: $isDebuggable)';
}

/// Root / 越狱检测（T18.5，可选安全能力）。
abstract class DeviceIntegrityService {
  /// 返回当前设备的完整性报告。
  Future<DeviceIntegrityReport> check();
}

/// MethodChannel 实现。Android 原生检测见 `MainActivity.kt`（模拟器 / 可调试 /
/// su 路径粗检）。未实现平台/测试 → 返回默认「可信」报告（保守，不误杀正常用户）。
///
/// ⚠️ 生产级越狱/Root 检测是「攻防对抗」，应集成专门方案：Android Play Integrity
/// API、iOS DeviceCheck + App Attest，或 `flutter_jailbreak_detection` 等库。
/// 本类是统一接口（seam），便于替换为真实实现而不动业务代码。
@LazySingleton(as: DeviceIntegrityService)
class DeviceIntegrityServiceImpl implements DeviceIntegrityService {
  const DeviceIntegrityServiceImpl();

  /// 与 `MainActivity.kt` 中注册的 channel 名一致。
  static const MethodChannel channel = MethodChannel(
    'flutter_claude_app/device_integrity',
  );

  @override
  Future<DeviceIntegrityReport> check() async {
    try {
      final map = await channel.invokeMapMethod<String, dynamic>('check');
      if (map == null) return const DeviceIntegrityReport();
      return DeviceIntegrityReport.fromMap(map);
    } on MissingPluginException {
      return const DeviceIntegrityReport();
    }
  }
}
