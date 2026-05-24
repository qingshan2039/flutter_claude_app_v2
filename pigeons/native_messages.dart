// M26 / T26.3 Pigeon 架构定义（类型安全的 Flutter↔原生通信）。
//
// 这是**代码生成的输入**（schema），不是运行时代码。运行：
//   dart run pigeon --input pigeons/native_messages.dart
// 会按下方 @ConfigurePigeon 生成强类型 Dart 通信代码到
//   lib/core/native/pigeon/native_messages.g.dart
//
// 默认只生成 Dart（不碰原生工程，保证 CI 绿）。需要原生侧时，取消下方
// kotlinOut / swiftOut 注释再次运行，会生成 Kotlin/Swift 接口供原生实现。
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/native/pigeon/native_messages.g.dart',
    dartOptions: DartOptions(),
    dartPackageName: 'flutter_claude_app_v2',
    // kotlinOut:
    //     'android/app/src/main/kotlin/com/ben/claude_flutter_v2/'
    //     'flutter_claude_app_v2/NativeMessages.g.kt',
    // kotlinOptions: KotlinOptions(),
    // swiftOut: 'ios/Runner/NativeMessages.g.swift',
    // swiftOptions: SwiftOptions(),
  ),
)
/// 设备详情（类型安全的数据传输对象）。
class DeviceDetails {
  DeviceDetails({
    this.osName,
    this.osVersion,
    this.model,
    this.isPhysicalDevice,
  });

  String? osName;
  String? osVersion;
  String? model;
  bool? isPhysicalDevice;
}

/// Flutter → 原生：由原生实现，Flutter 调用（类型安全，无需手写 channel）。
@HostApi()
abstract class NativeDeviceApi {
  DeviceDetails getDeviceDetails();

  @async
  String greet(String name);
}

/// 原生 → Flutter：由 Flutter 实现，原生调用。
@FlutterApi()
abstract class NativeEventApi {
  void onNativeTick(int count);
}
