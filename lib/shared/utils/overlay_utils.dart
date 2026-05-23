import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/app_theme_extension.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:injectable/injectable.dart';

/// Toast 语义类型（决定配色与图标）。
enum ToastType { info, success, warning, error }

/// 弹窗按钮描述（[OverlayService.showAppDialog] 用）。
///
/// 点击后对话框以 [value] 关闭；[isDefault] 高亮为主操作，[isDestructive] 用错误色。
class AppDialogAction<T> {
  const AppDialogAction({
    required this.label,
    this.value,
    this.isDefault = false,
    this.isDestructive = false,
  });

  final String label;
  final T? value;
  final bool isDefault;
  final bool isDestructive;
}

/// 全局 Overlay 服务（T14.5）：**脱离 BuildContext** 弹 Toast / Dialog。
///
/// 适用场景：拦截器、Service、Notifier 等没有（或不该持有）context 的地方需要提示
/// 用户。通过两个全局 Key 实现：
/// - [scaffoldMessengerKey] → 挂到 `MaterialApp.scaffoldMessengerKey`（SnackBar）
/// - [navigatorKey] → 挂到 `MaterialApp.navigatorKey` 或 go_router `rootNavigatorKey`
///   （Dialog / BottomSheet）
///
/// 注册为 `@lazySingleton`，业务侧：`getIt<OverlayService>().showError('出错了')`。
@lazySingleton
class OverlayService {
  /// 挂到 `MaterialApp.scaffoldMessengerKey`。
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>(debugLabel: 'appScaffoldMessenger');

  /// 挂到 `MaterialApp.navigatorKey`（或 go_router 的 rootNavigatorKey）。
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'appNavigator');

  // ───────────────────────────── Toast ─────────────────────────────

  /// 弹一条 Toast（floating SnackBar）。无 context 可调用。
  void showToast(
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    assert(
      messenger != null,
      'OverlayService.scaffoldMessengerKey 未挂到 MaterialApp.scaffoldMessengerKey',
    );
    if (messenger == null) return;

    final (Color bg, Color fg, IconData icon) = _style(messenger.context, type);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: bg,
          duration: duration,
          shape: const RoundedRectangleBorder(borderRadius: RadiusTokens.allMd),
          content: Row(
            children: <Widget>[
              Icon(icon, color: fg, size: 20),
              SpacingTokens.hGapSm,
              Expanded(
                child: Text(message, style: TextStyle(color: fg)),
              ),
            ],
          ),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: fg,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }

  void showInfo(String message) => showToast(message);
  void showSuccess(String message) =>
      showToast(message, type: ToastType.success);
  void showWarning(String message) =>
      showToast(message, type: ToastType.warning);
  void showError(String message) => showToast(message, type: ToastType.error);

  /// 立刻隐藏当前 Toast。
  void hideToast() => scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

  (Color, Color, IconData) _style(BuildContext context, ToastType type) {
    final scheme = Theme.of(context).colorScheme;
    final c = context.appColors;
    return switch (type) {
      ToastType.info => (c.info, c.onInfo, Icons.info_outline),
      ToastType.success => (c.success, c.onSuccess, Icons.check_circle_outline),
      ToastType.warning => (c.warning, c.onWarning, Icons.warning_amber_outlined),
      ToastType.error => (scheme.error, scheme.onError, Icons.error_outline),
    };
  }

  // ──────────────────────────── Dialog ────────────────────────────

  /// 弹一个统一样式的对话框。无 context 可调用。返回点击按钮携带的 [AppDialogAction.value]。
  Future<T?> showAppDialog<T>({
    required String title,
    String? message,
    Widget? content,
    List<AppDialogAction<T>> actions = const <Never>[],
    bool barrierDismissible = true,
  }) {
    final context = navigatorKey.currentContext;
    assert(
      context != null,
      'OverlayService.navigatorKey 未挂到 MaterialApp.navigatorKey / go_router rootNavigatorKey',
    );
    if (context == null) return Future<T?>.value();

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: content ?? (message != null ? Text(message) : null),
          // 全部用 TextButton（对话框 Material 规范；也避开主题给 Filled/Outlined
          // 设的 Size.fromHeight(48) 在 OverflowBar 里触发的无限宽问题）。
          actions: actions.isEmpty
              ? <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('好'),
                  ),
                ]
              : actions
                    .map(
                      (a) => TextButton(
                        onPressed: () => Navigator.of(ctx).pop(a.value),
                        style: TextButton.styleFrom(
                          foregroundColor: a.isDestructive
                              ? scheme.error
                              : (a.isDefault ? scheme.primary : null),
                        ),
                        child: Text(
                          a.label,
                          style: a.isDefault
                              ? const TextStyle(fontWeight: FontWeight.w600)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
        );
      },
    );
  }

  /// 确认对话框。返回 true=确认 / false=取消（含点蒙层关闭）。
  Future<bool> showConfirm({
    required String title,
    String? message,
    String confirmLabel = '确定',
    String cancelLabel = '取消',
    bool destructive = false,
  }) async {
    final result = await showAppDialog<bool>(
      title: title,
      message: message,
      actions: <AppDialogAction<bool>>[
        AppDialogAction<bool>(label: cancelLabel, value: false),
        AppDialogAction<bool>(
          label: confirmLabel,
          value: true,
          isDefault: !destructive,
          isDestructive: destructive,
        ),
      ],
    );
    return result ?? false;
  }
}
