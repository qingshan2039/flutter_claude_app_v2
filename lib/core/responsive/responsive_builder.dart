import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/responsive/breakpoints.dart';

/// 根据断点返回不同布局（T12.2）。
///
/// 用 [LayoutBuilder] 取**父容器约束宽度**（而非整窗口），适合嵌套场景。
/// 只 [mobile] 必填；其它按「就近回退」：largeDesktop → desktop → tablet → mobile。
///
/// ```dart
/// ResponsiveBuilder(
///   mobile: (_) => const _OneColumn(),
///   tablet: (_) => const _TwoColumn(),
///   desktop: (_) => const _ThreeColumn(),
/// );
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;
  final WidgetBuilder? largeDesktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = Breakpoints.fromWidth(constraints.maxWidth);
        return _resolve(type)(context);
      },
    );
  }

  WidgetBuilder _resolve(ScreenType type) {
    return switch (type) {
      ScreenType.largeDesktop => largeDesktop ?? desktop ?? tablet ?? mobile,
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.mobile => mobile,
    };
  }
}

/// 按屏幕类型选**值**（而非 Widget）。用于响应式的 padding / 列数 / 字号等。
///
/// ```dart
/// final columns = const ResponsiveValue<int>(mobile: 1, tablet: 2, desktop: 3)
///     .resolve(context.screenType);
/// ```
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? largeDesktop;

  T resolve(ScreenType type) {
    return switch (type) {
      ScreenType.largeDesktop => largeDesktop ?? desktop ?? tablet ?? mobile,
      ScreenType.desktop => desktop ?? tablet ?? mobile,
      ScreenType.tablet => tablet ?? mobile,
      ScreenType.mobile => mobile,
    };
  }
}
