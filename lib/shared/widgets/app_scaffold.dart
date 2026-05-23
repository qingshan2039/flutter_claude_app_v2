import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/shared/utils/keyboard_utils.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/loading_widget.dart';

/// 统一页面脚手架（T14.8）。
///
/// 在 [Scaffold] 之上收敛了三件几乎每个页面都要做的事：
/// 1. **默认 AppBar**：传 [title] 即生成；要完全自定义传 [appBar]；不需要传
///    `showAppBar: false`。
/// 2. **加载遮罩**：[isLoading] 为 true 时盖一层带 spinner 的半透明蒙层并拦截点击
///    （表单提交中防重复点击）。
/// 3. **点击空白收起键盘**：默认开启（[dismissKeyboardOnTap]）。
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body, super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.appBar,
    this.showAppBar = true,
    this.centerTitle,
    this.isLoading = false,
    this.loadingMessage,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.padding,
    this.resizeToAvoidBottomInset,
    this.dismissKeyboardOnTap = true,
  });

  final Widget body;

  /// 默认 AppBar 标题文案（与 [titleWidget] 二选一）。
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;

  /// 完全自定义 AppBar（提供后忽略 [title] / [actions] 等）。
  final PreferredSizeWidget? appBar;

  /// 是否显示 AppBar（无标题需求时设 false）。
  final bool showAppBar;
  final bool? centerTitle;

  /// 加载遮罩开关 + 文案。
  final bool isLoading;
  final String? loadingMessage;

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  /// body 内边距（可选）。
  final EdgeInsetsGeometry? padding;
  final bool? resizeToAvoidBottomInset;
  final bool dismissKeyboardOnTap;

  PreferredSizeWidget? _resolveAppBar() {
    if (appBar != null) return appBar;
    if (!showAppBar) return null;
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    var content = padding != null
        ? Padding(padding: padding!, child: body)
        : body;

    if (dismissKeyboardOnTap) {
      content = DismissKeyboardOnTap(child: content);
    }

    return Scaffold(
      appBar: _resolveAppBar(),
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      // StackFit.expand：让 body 填满可用空间（否则 Stack 会收缩到内容大小，
      // 加载遮罩 Positioned.fill 也跟着塌缩）。与普通 Scaffold body 充满一致。
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          content,
          if (isLoading) _LoadingOverlay(message: loadingMessage),
        ],
      ),
    );
  }
}

/// 加载遮罩：半透明蒙层 + 居中 spinner，拦截一切点击。
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final scrim = Theme.of(context).colorScheme.scrim;
    return Positioned.fill(
      child: ColoredBox(
        color: scrim.withValues(alpha: 0.32),
        // ModalBarrier 拦截点击，dismissible:false 防止误关。
        child: Stack(
          children: <Widget>[
            const ModalBarrier(dismissible: false, color: Colors.transparent),
            LoadingWidget.fullscreen(message: message),
          ],
        ),
      ),
    );
  }
}
