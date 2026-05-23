import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/router/auth_redirect.dart';
import 'package:flutter_claude_app_v2/core/router/page_transitions.dart';
import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:flutter_claude_app_v2/core/router/router_log_observer.dart';
import 'package:flutter_claude_app_v2/core/router/typed_routes.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/detail_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/home_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/login_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/not_found_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/scaffold_with_nav_bar.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/search_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

/// 应用路由表（T07.1 主体 + T07.3 Shell + T07.4 guard + T07.6 404 + T07.7 转场 + T07.8 observer）。
///
/// 结构：
/// ```text
/// /                    (Shell)
///   ├── /              → HomePage    (branch 0)
///   ├── /search        → SearchPage  (branch 1)
///   └── /settings      → SettingsPage (branch 2)
/// /detail/:id          → DetailPage  (fade 转场，跳出 shell)
/// /typed-detail/:id    → DetailPage  (类型安全示例，T07.2)
/// /login               → LoginPage   (slide-up 转场)
/// (其它)               → NotFoundPage (T07.6)
/// ```
GoRouter createAppRouter({
  required ProviderContainer container,
  required RouterLogObserver observer,
  GlobalKey<NavigatorState>? rootNavigatorKey,
}) {
  // 允许外部传入根 NavigatorKey（M14/T14.5：OverlayService 用它脱离 context 弹
  // Dialog / BottomSheet）；未传则内部新建。
  final rootKey =
      rootNavigatorKey ?? GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    observers: <NavigatorObserver>[observer],
    redirect: (context, state) => authRedirect(container, state),
    errorBuilder: (context, state) => NotFoundPage(
      error: state.error,
      path: state.uri.toString(),
    ),
    routes: <RouteBase>[
      // ───────────────── Shell: bottom navigation ─────────────────
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootKey,
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                name: RouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/search',
                name: RouteNames.search,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                name: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      // ───────────────── 全屏路由（跳出 shell） ─────────────────
      GoRoute(
        path: '/detail/:id',
        name: RouteNames.detail,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return PageTransitions.fade<void>(
            state: state,
            child: DetailPage(id: id),
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        parentNavigatorKey: rootKey,
        pageBuilder: (context, state) => PageTransitions.slideUp<void>(
          state: state,
          child: const LoginPage(),
        ),
      ),
      // ───────────────── 类型安全示例（T07.2） ─────────────────
      // go_router_builder 在 typed_routes.dart 上生成 $appRoutes。
      // 把生成的常量 spread 进 routes，让类型路由与手写路由共存。
      ...$appRoutes,
    ],
  );
}

/// DI 注册：[GoRouter] 与 [ProviderContainer] 互依赖（守卫需要读 provider）。
/// 这里把 `ProviderContainer` 作为 ProviderScope 创建后再外部传入的依赖，
/// 由 M13/T13.1 在 bootstrap 中编排。
///
/// 当前模板**未**通过 DI 暴露 GoRouter（避免与 ProviderScope 启动顺序耦合）。
/// 业务接入：在 main.dart 用 `MaterialApp.router(routerConfig: createAppRouter(...))`。
@lazySingleton
class RouterDeps {
  RouterDeps(this.observer);
  final RouterLogObserver observer;
}
