import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';

/// Debug 面板入口（T29.1）。
///
/// 包住一个常驻控件（如 LOGO）：**长按**触发 [onTrigger]（一般打开 Debug 面板）。
/// 仅在 [enabled] 为 true 时响应——通常用 [isAvailable] 限定 dev/staging。
///
/// 摇一摇触发可在此基础上接 `sensors_plus` 监听加速度（本模板用长按，零依赖）。
class DebugEntry extends StatelessWidget {
  const DebugEntry({
    required this.child,
    required this.enabled,
    super.key,
    this.onTrigger,
  });

  final Widget child;
  final bool enabled;
  final VoidCallback? onTrigger;

  /// Debug 面板是否在该环境可用（生产环境禁用）。
  static bool isAvailable(AppEnvironment environment) => !environment.isProd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: enabled ? onTrigger : null,
      child: child,
    );
  }
}
