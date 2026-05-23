import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/shared/utils/overlay_utils.dart';

/// BottomSheet 工具（T14.6）。
///
/// 作为 [OverlayService] 的扩展，复用同一套全局 Key，故同样**脱离 BuildContext**
/// 可调用：`getIt<OverlayService>().showAppBottomSheet(...)`。
///
/// 统一样式：顶部大圆角 + 拖拽手柄（[showDragHandle]）+ 拖拽关闭（[enableDrag]）+
/// 安全区避让（`useSafeArea`）。
extension BottomSheetX on OverlayService {
  /// 标准底部弹层。
  Future<T?> showAppBottomSheet<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final context = navigatorKey.currentContext;
    assert(context != null, 'OverlayService.navigatorKey 未挂载');
    if (context == null) return Future<T?>.value();

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      showDragHandle: showDragHandle,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: RadiusTokens.topLg),
      builder: builder,
    );
  }

  /// 可拖拽高度的底部弹层（长列表 / 半屏详情）。
  ///
  /// [builder] 收到的 `ScrollController` 必须接到内部可滚动组件，才能「拖拽手柄
  /// 联动内容滚动」。
  Future<T?> showDraggableSheet<T>({
    required Widget Function(BuildContext context, ScrollController controller)
    builder,
    double initialSize = 0.5,
    double minSize = 0.25,
    double maxSize = 0.95,
  }) {
    return showAppBottomSheet<T>(
      showDragHandle: false,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        builder: builder,
      ),
    );
  }
}
