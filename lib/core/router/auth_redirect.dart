import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 登录态档位（T07.4）。
///
/// 默认 `false`（未登录），守卫会把非 login 页跳到 /login。
/// 实际登录态由 M19/T19.1 接管：登录成功后写入；登出 / token 失效时清空。
final StateProvider<bool> isLoggedInProvider = StateProvider<bool>(
  (ref) => false,
  name: 'isLoggedInProvider',
);

/// 不需要登录即可访问的路径白名单。
const Set<String> _publicPaths = <String>{
  '/login',
  // 404 与错误页由 GoRouter.errorBuilder 处理，不参与 redirect 流程
};

/// 路由守卫（T07.4）。
///
/// 用法：把本函数赋给 `GoRouter.redirect`。返回 null = 放行；返回字符串 = 跳转该路径。
///
/// 行为：
/// - 已登录 + 访问 `/login` → 跳到 [RouteNames.home]
/// - 未登录 + 访问非白名单路径 → 跳到 `/login`
/// - 其余 → 放行
String? authRedirect(
  ProviderContainer container,
  GoRouterState state,
) {
  final isLoggedIn = container.read(isLoggedInProvider);
  final goingTo = state.uri.path;

  if (isLoggedIn && goingTo == '/login') {
    return '/';
  }
  if (!isLoggedIn && !_publicPaths.contains(goingTo)) {
    return '/login';
  }
  return null;
}
