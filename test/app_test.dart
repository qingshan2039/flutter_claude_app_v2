import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/app.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/observer/provider_observer.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '_helpers/storage_test_setup.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await setupStorageMocks();
    await getIt.reset();
    await configureDependencies(environment: 'dev');
  });

  tearDown(() async {
    await getIt.reset();
    await tearDownStorageMocks(tempDir);
  });

  testWidgets('App 启动后渲染（未登录 → 守卫重定向到登录页）', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        observers: <ProviderObserver>[getIt<AppProviderObserver>()],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // 默认 isLoggedIn=false → authRedirect 跳 /login → LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('App 装配 MaterialApp.router（标题来自 l10n）', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        observers: <ProviderObserver>[getIt<AppProviderObserver>()],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // App 正常构建：能找到一个 Navigator（go_router 装配）
    expect(find.byType(Navigator), findsWidgets);
  });
}
