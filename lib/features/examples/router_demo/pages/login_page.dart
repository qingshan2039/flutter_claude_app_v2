import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/auth_redirect.dart';
import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 登录页占位 — 演示 T07.4 路由守卫触发的目的地。
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Login Page (router demo)'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                // 演示：模拟登录成功，把 isLoggedIn 切到 true，guard 自动放行
                ref.read(isLoggedInProvider.notifier).state = true;
                context.goNamed(RouteNames.home);
              },
              child: const Text('Sign in (demo)'),
            ),
          ],
        ),
      ),
    );
  }
}
