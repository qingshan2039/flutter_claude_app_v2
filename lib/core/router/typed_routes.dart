import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/features/examples/router_demo/pages/detail_page.dart';
import 'package:go_router/go_router.dart';

part 'typed_routes.g.dart';

/// 类型安全路由示例（T07.2）— 用 `go_router_builder` 把 path / query 参数
/// 自动转换为构造参数。
///
/// 设计要点：
/// - 用 `@TypedGoRoute<XxxRoute>(path: '/...')` 注解一个 [GoRouteData] 子类
/// - `path: ':id'` 中的 `:id` 自动绑到字段 `String id`
/// - 调用 `const DetailRoute(id: '42').go(context)` 类型安全；编译器查参数完整性
/// - go_router_builder 生成 `$appRoutes` 列表 + `.go()` / `.push()` / `.location` 等扩展
///
/// 本文件仅演示单条 detail 路由，避免与主路由表（手写 GoRoute 链路）混乱。
/// 后续若整体迁移到类型安全 API，可把 [appRouter] 中的 GoRoute 全部换为 `@TypedGoRoute`。
@TypedGoRoute<DetailRoute>(path: '/typed-detail/:id', name: 'typed-detail')
class DetailRoute extends GoRouteData with $DetailRoute {
  const DetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DetailPage(id: id);
  }
}
