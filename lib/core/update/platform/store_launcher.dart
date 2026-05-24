import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// 应用商店跳转（T23.4：iOS 引导更新；Android 市场跳转）。
///
/// iOS 无应用内更新机制，标准做法是**引导用户到 App Store**：
/// `https://apps.apple.com/app/idXXXX` 或 `itms-apps://`。Android 国行/海外也可
/// 用本类跳应用市场（`market://details?id=...`）。
///
/// 真实实现：原生侧用系统能力打开 URL（或 Flutter 侧用 `url_launcher` 的
/// `launchUrl(...,mode: externalApplication)`）。这里用 MethodChannel
/// `flutter_claude_app/store_launcher` 作为接缝，未接入/测试时优雅降级返回 false。
abstract class StoreLauncher {
  /// 打开商店地址，返回是否成功唤起。
  Future<bool> openStore(String url);
}

@LazySingleton(as: StoreLauncher)
class StoreLauncherImpl implements StoreLauncher {
  const StoreLauncherImpl();

  static const MethodChannel channel = MethodChannel(
    'flutter_claude_app/store_launcher',
  );

  @override
  Future<bool> openStore(String url) async {
    try {
      final ok = await channel.invokeMethod<bool>('open', <String, String>{
        'url': url,
      });
      return ok ?? false;
    } on MissingPluginException {
      return false; // 未接入 / 桌面 / 测试
    } on PlatformException {
      return false;
    }
  }
}
