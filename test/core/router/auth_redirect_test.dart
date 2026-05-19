import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/auth_redirect.dart';
import 'package:flutter_claude_app_v2/core/router/router_log_observer.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/home_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/login_page.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/not_found_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _buildRouter(ProviderContainer container) {
  final observer = RouterLogObserver()..enabled = false;
  return GoRouter(
    initialLocation: '/',
    observers: <NavigatorObserver>[observer],
    redirect: (context, state) => authRedirect(container, state),
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/settings', builder: (context, state) => const Scaffold(body: Text('Settings'))),
    ],
  );
}

void main() {
  group('authRedirect', () {
    testWidgets('未登录 + 访问 / → 跳到 /login', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = _buildRouter(container);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
      expect(find.text('Login Page (router demo)'), findsOneWidget);
    });

    testWidgets('已登录 + 访问 / → 留在 /', (tester) async {
      final container = ProviderContainer(
        overrides: <Override>[
          isLoggedInProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      final router = _buildRouter(container);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
      expect(find.text('Home Page (router demo)'), findsOneWidget);
    });

    testWidgets('已登录 + 访问 /login → 重定向到 /', (tester) async {
      final container = ProviderContainer(
        overrides: <Override>[
          isLoggedInProvider.overrideWith((ref) => true),
        ],
      );
      addTearDown(container.dispose);

      final router = _buildRouter(container);
      router.go('/login');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
    });

    testWidgets('未登录 + 访问 /settings → 跳到 /login', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = _buildRouter(container);
      router.go('/settings');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.uri.path, '/login');
    });

    test('纯函数：未登录 + path=/login → 返回 null（放行）', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = _stubState('/login');
      expect(authRedirect(container, state), isNull);
    });
  });
}

/// 构造一个 [GoRouterState]，仅 uri 字段有值；其余传 GoRouter 内部默认值。
/// 用于 redirect 纯函数测试。
GoRouterState _stubState(String path) {
  return GoRouterState(
    _DummyConfiguration(),
    uri: Uri.parse(path),
    matchedLocation: path,
    name: null,
    path: path,
    fullPath: path,
    pathParameters: const <String, String>{},
    pageKey: const ValueKey<String>('stub'),
    error: null,
  );
}

/// Minimal stub for [RouteConfiguration]，仅满足 [GoRouterState] 构造的需要。
class _DummyConfiguration implements RouteConfiguration {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
