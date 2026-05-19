// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'typed_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$detailRoute];

RouteBase get $detailRoute => GoRouteData.$route(
  path: '/typed-detail/:id',
  name: 'typed-detail',
  factory: $DetailRoute._fromState,
);

mixin $DetailRoute on GoRouteData {
  static DetailRoute _fromState(GoRouterState state) =>
      DetailRoute(id: state.pathParameters['id']!);

  DetailRoute get _self => this as DetailRoute;

  @override
  String get location =>
      GoRouteData.$location('/typed-detail/${Uri.encodeComponent(_self.id)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
