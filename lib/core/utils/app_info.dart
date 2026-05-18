import 'package:injectable/injectable.dart';

/// 应用基本信息（lazy singleton）。
///
/// T02.1 用作 DI 链路端到端验证：注解 → build_runner 生成 → getIt 注册 →
/// 运行调用 → 单测核对。后续模块（M15 多环境、M11 监控等）会替换为真实实现。
@lazySingleton
class AppInfo {
  AppInfo();

  String get name => 'flutter_claude_app_v2';
  String get version => '1.0.0+1';
}
