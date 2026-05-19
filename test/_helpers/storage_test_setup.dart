import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 为依赖 `configureDependencies()` 的 DI 测试装好平台 mock：
/// - SharedPreferences 用 setMockInitialValues 提供空数据
/// - path_provider 用 method channel mock 指向临时目录（Hive.initFlutter 需要）
///
/// 返回创建的临时目录；调用方在 tearDown 用 [tearDownStorageMocks] 清理。
Future<Directory> setupStorageMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.setMockInitialValues(<String, Object>{});

  final tempDir = Directory.systemTemp.createTempSync('di_test_');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall call) async {
      switch (call.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getApplicationSupportDirectory':
        case 'getApplicationCacheDirectory':
          return tempDir.path;
        case 'getTemporaryDirectory':
          return tempDir.path;
        default:
          return null;
      }
    },
  );

  return tempDir;
}

/// 清理 Hive box / 临时目录 / 平台 channel handler。
Future<void> tearDownStorageMocks(Directory tempDir) async {
  try {
    await Hive.close();
  } catch (_) {
    // 容忍 Hive 未打开过 box 的情况
  }
  try {
    await Hive.deleteFromDisk();
  } catch (_) {}

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    null,
  );

  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
}
