import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:go_router/go_router.dart';

/// 首页（M07 路由示例占位）。M19/T19.2 完成后会被真实业务页面替换。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Home Page (router demo)'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  context.goNamed(RouteNames.detail, pathParameters: {'id': '42'}),
              child: const Text('Open detail #42'),
            ),
          ],
        ),
      ),
    );
  }
}
