import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:injectable/injectable.dart';

/// 防截屏 / 防录屏（T18.4，可选安全能力）。
///
/// Android：通过原生 `WindowManager.LayoutParams.FLAG_SECURE` 实现——开启后系统
/// 禁止截屏/录屏，且最近任务里显示空白。原生处理见 `MainActivity.kt`。
///
/// iOS：系统无 FLAG_SECURE 等价 API；常见做法是「进入后台时盖一层模糊视图 +
/// 监听 `UIScreen.capturedDidChangeNotification`」，需在 AppDelegate/SceneDelegate
/// 原生实现（本模板未内置，见 docs/security/SECURITY.md）。故在 iOS 上本类静默降级。
abstract class ScreenSecurity {
  /// 开启防截屏（敏感页面 onShow）。
  Future<void> enableSecure();

  /// 关闭防截屏（离开敏感页面）。
  Future<void> disableSecure();
}

/// 基于 MethodChannel 的实现。未实现的平台（iOS / 桌面 / 测试）静默降级，不抛异常。
@LazySingleton(as: ScreenSecurity)
class ScreenSecurityImpl implements ScreenSecurity {
  const ScreenSecurityImpl();

  /// 与 `MainActivity.kt` 中注册的 channel 名一致（与 flavor/包名无关）。
  static const MethodChannel channel = MethodChannel(
    'flutter_claude_app/screen_security',
  );

  @override
  Future<void> enableSecure() => _invoke('enableSecure');

  @override
  Future<void> disableSecure() => _invoke('disableSecure');

  Future<void> _invoke(String method) async {
    try {
      await channel.invokeMethod<void>(method);
    } on MissingPluginException {
      // 平台未实现（iOS/桌面/测试）→ 静默降级。
    }
  }
}

/// 把子树包成「防截屏页面」（T18.4）。
///
/// 进入时开启 FLAG_SECURE，离开（dispose）时关闭。用法：
/// ```dart
/// SecureScreen(child: PaymentPage());
/// ```
/// 测试可传入 [screenSecurity] 注入替身；默认从 `getIt` 取。
class SecureScreen extends StatefulWidget {
  const SecureScreen({required this.child, super.key, this.screenSecurity});

  final Widget child;
  final ScreenSecurity? screenSecurity;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  late final ScreenSecurity _security =
      widget.screenSecurity ?? getIt<ScreenSecurity>();

  @override
  void initState() {
    super.initState();
    _security.enableSecure();
  }

  @override
  void dispose() {
    _security.disableSecure();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
