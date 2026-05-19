import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// 获取当前用户的 UseCase（T06.4）。
///
/// 设计原则：
/// - 单一职责：UseCase 不持有状态，只编排 1 个或少数几个 Repository 调用
/// - 注解为 `@injectable`（factory 注册）：UseCase 无状态，每次解析返回新实例即可
/// - 调用方为 Provider / Notifier，而不直接给 Widget；Widget 通过 Riverpod 访问
///
/// 调用方式（约定使用 [call] 让对象可像函数一样调用）：
/// ```dart
/// final useCase = getIt<GetCurrentUserUseCase>();
/// final Result<User> result = await useCase();
/// ```
@injectable
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({String? userId}) =>
      _repository.getCurrentUser(userId: userId);
}
