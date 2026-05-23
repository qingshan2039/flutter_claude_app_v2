import 'package:flutter_claude_app_v2/core/error/failures.dart' show Failure;
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/data/repositories/auth_repository_impl.dart'
    show AuthRepositoryImpl;
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';

/// 领域层 [User] 访问的抽象（T06.4 + T19.1）。
///
/// 设计原则：
/// - 接口在 `domain/repositories/`，与具体数据源解耦
/// - 返回 [Result] 而非抛异常（错误体系统一走 M03 [Failure]）
/// - data 层实现 [AuthRepositoryImpl]：登录成功落 token（M05 SecureStorage）
abstract class AuthRepository {
  /// 获取当前用户（或指定 [userId] 的用户）。
  Future<Result<User>> getCurrentUser({String? userId});

  /// 登录（T19.1）：成功则持久化 token 并返回 [User]，失败返回 [Failure]。
  Future<Result<User>> signIn({
    required String email,
    required String password,
  });

  /// 登出（T19.1 / T19.4）：清除本地 token。
  Future<void> signOut();
}
