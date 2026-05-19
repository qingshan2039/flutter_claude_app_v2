import 'package:dio/dio.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

/// 类型安全的 REST API 接口示例（T04.6）。
///
/// 由 retrofit_generator 在 build_runner 时生成具体 `_ExampleApiService` 实现，
/// 自动序列化路径/查询/Body、反序列化响应到 [UserModel]。
///
/// 命名规范（与 T20.4 CONVENTIONS.md 对齐）：
/// - 每个 feature 的远程数据源放在 `features/<feat>/data/api/<feat>_api_service.dart`
/// - 本文件 `ExampleApiService` 仅作模板示范；M19 / T19.1 会落地真实 `AuthApiService`
@RestApi()
abstract class ExampleApiService {
  factory ExampleApiService(Dio dio, {String? baseUrl}) = _ExampleApiService;

  @GET('/users/{id}')
  Future<UserModel> getUserById(@Path('id') String id);

  @POST('/users')
  Future<UserModel> createUser(@Body() UserModel user);

  @PUT('/users/{id}')
  Future<UserModel> updateUser(
    @Path('id') String id,
    @Body() UserModel user,
  );

  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') String id);
}

/// 把 retrofit 服务注入 DI。每个真实的 ApiService 都需要一个对应的 @module 方法。
@module
abstract class ExampleApiModule {
  @lazySingleton
  ExampleApiService exampleApi(Dio dio) => ExampleApiService(dio);
}
