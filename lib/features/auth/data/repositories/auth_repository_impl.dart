import 'package:flutter_claude_app_v2/core/error/error_mapper.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart' show Failure;
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart' show UserModel;
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// [AuthRepository] 的占位实现（T06.4）— 返回写死的 [User]，模拟 80ms IO。
///
/// **M19/T19.1 完成后会重写**：
/// - 注入 `ExampleApiService`（或 `AuthApiService`）
/// - 用 retrofit 调真实 `/users/{id}` 端点
/// - 把 [UserModel] 经 mapper 转 [User]
/// - try/catch + [ErrorMapper.map] 把异常转 [Failure]
///
/// 本占位让 T06.4 「UseCase + Provider」链路端到端可跑、可测试。
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._errorMapper);

  final ErrorMapper _errorMapper;

  @override
  Future<Result<User>> getCurrentUser({String? userId}) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      return Success(
        User(
          id: userId ?? 'demo-1',
          name: 'Demo User',
          email: 'demo@example.com',
          createdAt: DateTime.utc(2026, 5, 18),
        ),
      );
    } on Exception catch (e) {
      return Failed(_errorMapper.map(e));
    }
  }
}
