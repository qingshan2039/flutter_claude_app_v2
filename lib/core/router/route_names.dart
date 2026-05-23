import 'package:go_router/go_router.dart' show GoRouter;

/// 路由 name 常量集中表（T07.1）。
///
/// 使用 [GoRouter.goNamed] / [GoRouter.pushNamed] 时引用这些常量而非裸字符串，
/// 避免散落多处的拼写错误。path 在 [appRouter] 配置里定义，name 在此聚合。
abstract final class RouteNames {
  static const String home = 'home';
  static const String search = 'search';
  static const String settings = 'settings';
  static const String detail = 'detail';
  static const String login = 'login';
  static const String permissions = 'permissions';
  static const String notFound = 'not-found';
}

/// 路由 path 常量。供测试或 URL 构造场景使用；正式导航请用 [RouteNames]。
abstract final class RoutePaths {
  static const String home = '/';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String detail = '/detail/:id';
  static const String login = '/login';
  static const String permissions = '/permissions';
}
