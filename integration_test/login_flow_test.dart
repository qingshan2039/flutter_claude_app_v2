import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/app.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';
import 'package:flutter_claude_app_v2/core/env/env_config.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_claude_app_v2/features/home/presentation/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/_helpers/storage_test_setup.dart';

/// T17.4：登录流程端到端集成测试。
///
/// 驱动**完整 App**（go_router + DI + 主题 + 国际化），验证：
/// 未登录 → 路由守卫重定向到登录页 → 点登录 → 进入首页。
///
/// 本机快速跑（无需真机，跑在 flutter_tester 上）：
///   flutter test integration_test/login_flow_test.dart
/// 真机/模拟器跑：
///   flutter test integration_test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('未登录被守卫拦到登录页 → 登录 → 进入首页', (tester) async {
    final envConfig = registerEnvConfig(AppEnvironment.dev);

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[envConfigProvider.overrideWithValue(envConfig)],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // 1) 未登录：go_router 守卫把 `/` 重定向到 `/login`
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.widgetWithText(AppBar, '登录'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    // 2) 点击「登录」按钮（表单已预填 demo@example.com / password）：
    //    SignInUseCase → 存 token → isLoggedIn 置 true → 跳转首页
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    // 3) 已进入首页
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.widgetWithText(AppBar, '首页'), findsOneWidget);
  });
}
