import 'package:flutter_claude_app_v2/core/update/app_version.dart';
import 'package:flutter_claude_app_v2/core/update/update_models.dart';
import 'package:injectable/injectable.dart';

/// 版本检查服务（T23.1）：拉取后端的最新版本信息。
///
/// 真实实现示例（基于 M04 的 Dio/Retrofit）：
/// ```dart
/// final resp = await dio.get('/app/version');
/// return UpdateInfo.fromJson(resp.data as Map<String, dynamic>);
/// ```
abstract class VersionCheckService {
  Future<UpdateInfo> fetchLatest();
}

/// 桩实现：返回固定的更新信息，便于本地/测试跑通整条更新链路。
/// 生产替换为真实 HTTP 实现（见上方注释），DI 把接口绑定到实现。
@LazySingleton(as: VersionCheckService)
class StubVersionCheckService implements VersionCheckService {
  const StubVersionCheckService();

  @override
  Future<UpdateInfo> fetchLatest() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return UpdateInfo(
      latestVersion: AppVersion.parse('1.4.0'),
      minSupportedVersion: AppVersion.parse('1.2.0'),
      releaseNotes: '• 修复已知问题\n• 提升启动速度\n• 优化无障碍体验',
      storeUrl: 'https://apps.apple.com/app/id0000000000',
      apkUrl: 'https://example.com/download/app-release.apk',
    );
  }
}
