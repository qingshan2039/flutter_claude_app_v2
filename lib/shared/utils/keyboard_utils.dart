import 'package:flutter/widgets.dart';

/// 键盘处理工具（T14.7）。
abstract final class KeyboardUtils {
  /// 收起键盘。传 [context] 用 [FocusScope]；不传则用全局 primaryFocus（脱离 context）。
  static void dismiss([BuildContext? context]) {
    if (context != null) {
      final scope = FocusScope.of(context);
      if (!scope.hasPrimaryFocus && scope.hasFocus) {
        scope.unfocus();
        return;
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 当前键盘高度（被键盘遮挡的底部高度，单位 px）。
  static double inset(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  /// 键盘是否弹出。
  static bool isOpen(BuildContext context) => inset(context) > 0;
}

/// 点击空白处收起键盘（T14.7）。
///
/// 包在页面 body 外层即可：点输入框以外的区域自动收起键盘。
/// 用 [HitTestBehavior.translucent] 保证空白区域也能接收点击，且不拦截子组件交互。
class DismissKeyboardOnTap extends StatelessWidget {
  const DismissKeyboardOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => KeyboardUtils.dismiss(context),
      child: child,
    );
  }
}

/// 智能避让占位（T14.7）。
///
/// 放在「底部固定内容」（如提交按钮）下方，高度跟随键盘升降，使该内容始终浮在
/// 键盘之上。比整页 `resizeToAvoidBottomInset` 更精准（只抬需要抬的部分）。
class KeyboardSpacer extends StatelessWidget {
  const KeyboardSpacer({super.key, this.extra = 0});

  /// 额外留白（在键盘高度之外再加的间距）。
  final double extra;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: KeyboardUtils.inset(context) + extra);
  }
}
