import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/app_router.dart';
import 'package:flutter_claude_app_v2/core/router/auth_redirect.dart';
import 'package:flutter_claude_app_v2/core/router/router_log_observer.dart';
import 'package:flutter_claude_app_v2/core/router/typed_routes.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_claude_app_v2/features/detail/presentation/pages/detail_page.dart';
import 'package:flutter_claude_app_v2/features/home/presentation/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  ProviderContainer makeContainer({bool loggedIn = true}) {
    final container = ProviderContainer(
      overrides: <Override>[
        isLoggedInProvider.overrideWith((ref) => loggedIn),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  GoRouter makeRouter({required ProviderContainer container}) {
    final observer = RouterLogObserver()..enabled = false;
    return createAppRouter(container: container, observer: observer);
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    required ProviderContainer container,
    required GoRouter router,
  }) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('appRouter — 已登录用户', () {
    testWidgets('初始路径 / → HomePage（在 Shell 内）', (tester) async {
      final container = makeContainer();
      final router = makeRouter(container: container);

      await pumpApp(tester, container: container, router: router);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('点击 search tab → SearchPage 出现', (tester) async {
      final container = makeContainer();
      final router = makeRouter(container: container);

      await pumpApp(tester, container: container, router: router);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.text('Search Page (router demo)'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('go /detail/42 → DetailPage（跳出 Shell，无 BottomNav）', (tester) async {
      final container = makeContainer();
      final router = makeRouter(container: container);

      await pumpApp(tester, container: container, router: router);

      router.go('/detail/42');
      await tester.pumpAndSettle();

      expect(find.byType(DetailPage), findsOneWidget);
      expect(find.text('详情 #42'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('未知路径 → 404 NotFoundPage', (tester) async {
      final container = makeContainer();
      final router = makeRouter(container: container);

      await pumpApp(tester, container: container, router: router);

      router.go('/totally-bogus-path');
      await tester.pumpAndSettle();

      expect(find.text('404'), findsOneWidget);
    });

    testWidgets('typed-detail/:id 由 go_router_builder 生成的路由也工作', (tester) async {
      final container = makeContainer();
      final router = makeRouter(container: container);

      await pumpApp(tester, container: container, router: router);

      // 用生成的 const DetailRoute(id: '99').location 拿类型安全 URL，再交给 router.go
      const route = DetailRoute(id: '99');
      router.go(route.location);
      await tester.pumpAndSettle();

      expect(find.text('Detail Page for id=99'), findsOneWidget);
    });
  });

  group('appRouter — 未登录用户', () {
    testWidgets('访问 / → 被 redirect 到 /login', (tester) async {
      final container = makeContainer(loggedIn: false);
      final router = makeRouter(container: container);

      await pumpApp(tester, container: container, router: router);

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
