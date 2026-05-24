import 'package:flutter_claude_app_v2/core/remote_config/remote_config.dart';
import 'package:injectable/injectable.dart';

/// 紧急下线开关（T28.3）。
///
/// 从 [RemoteConfig] 读取 `app_kill_switch`（bool）与 `app_kill_message`。开启后由
/// [KillSwitchGate] 拦截整个 App，展示强制下线页（用于线上严重故障紧急止血）。
@lazySingleton
class KillSwitch {
  const KillSwitch(this._config);

  final RemoteConfig _config;

  /// 是否处于紧急下线状态。
  bool get isActive => _config.getBool('app_kill_switch');

  /// 强制下线时展示的提示文案。
  String get message => _config.getString(
    'app_kill_message',
    defaultValue: '服务暂不可用，请稍后再试',
  );
}
