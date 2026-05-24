import 'package:injectable/injectable.dart';

/// 远程配置抽象层（T28.1）。
///
/// 业务只依赖本接口读取类型化配置；具体来源（Firebase Remote Config / 自建后端）
/// 由 [RemoteConfigClient] 适配并经 DI 绑定。读取时「已激活值 → 默认值」回退。
abstract class RemoteConfig {
  bool getBool(String key, {bool defaultValue = false});
  int getInt(String key, {int defaultValue = 0});
  double getDouble(String key, {double defaultValue = 0});
  String getString(String key, {String defaultValue = ''});

  /// 默认值 + 已激活值合并后的全部配置（默认值打底）。
  Map<String, Object> getAll();

  /// 拉取最新配置并激活（写入缓存）。返回是否有变化。
  Future<bool> fetchAndActivate();
}

/// 远程配置数据源（T28.1：Firebase / 自建 的可切换接缝）。
abstract class RemoteConfigClient {
  Future<Map<String, Object>> fetch();
}

/// 桩数据源：返回固定配置，便于本地/测试跑通。
/// 生产替换为 Firebase（`FirebaseRemoteConfig`）或自建 HTTP 实现，DI 改绑即可。
@LazySingleton(as: RemoteConfigClient)
class StubRemoteConfigClient implements RemoteConfigClient {
  const StubRemoteConfigClient();

  @override
  Future<Map<String, Object>> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return <String, Object>{
      'welcome_title': '欢迎（来自远程配置）',
      'new_checkout_enabled': true,
      'max_upload_mb': 50,
      'home_banner.rollout': 30, // 灰度 30%
      'app_kill_switch': false,
      'app_kill_message': '服务维护中，请稍后再试',
    };
  }
}
