import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 自定义路由切换动画（T07.7）。
///
/// go_router 默认使用平台默认转场（iOS 滑入、Android 淡入上滑）。
/// 通过 [GoRoute.pageBuilder] 返回自定义 [CustomTransitionPage] 即可改写。
///
/// 提供 3 个常用工具：
/// - [fadeTransitionPage] — 淡入淡出（轻量）
/// - [slideUpTransitionPage] — 自下向上滑入（模态感）
/// - [scaleTransitionPage] — 缩放（强调感）
abstract final class PageTransitions {
  static const Duration _defaultDuration = Duration(milliseconds: 220);

  static CustomTransitionPage<T> fade<T>({
    required GoRouterState state,
    required Widget child,
    Duration duration = _defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondary, c) =>
          FadeTransition(opacity: animation, child: c),
    );
  }

  static CustomTransitionPage<T> slideUp<T>({
    required GoRouterState state,
    required Widget child,
    Duration duration = _defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondary, c) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: c);
      },
    );
  }

  static CustomTransitionPage<T> scale<T>({
    required GoRouterState state,
    required Widget child,
    Duration duration = _defaultDuration,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      name: state.name ?? state.fullPath,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondary, c) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: c),
        );
      },
    );
  }
}
