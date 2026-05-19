import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:go_router/go_router.dart';

/// 404 错误页（T07.6）。
///
/// 由 [GoRouter.errorBuilder] 触发：当 URL 找不到匹配路由、或路由 builder 抛错时显示。
/// 接受可选 [error]（来自 `state.error`），方便上报但默认不向用户展示。
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.error, this.path});

  final Exception? error;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                path == null
                    ? "We couldn't find the page you requested."
                    : "We couldn't find: $path",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.goNamed(RouteNames.home),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
