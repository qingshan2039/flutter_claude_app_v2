import 'package:flutter_claude_app_v2/core/error/failures.dart' show Failure;
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/data/repositories/auth_repository_impl.dart' show AuthRepositoryImpl;
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';

/// 领域层 [User] 访问的抽象（T06.4）。
///
/// 设计原则：
/// - 接口在 `domain/repositories/`，与具体数据源解耦
/// - 返回 [Result] 而非抛异常（错误体系统一走 M03 [Failure]）
/// - data 层的实现由 [AuthRepositoryImpl] 提供（M19/T19.1 完成后接入真实 API）
abstract class AuthRepository {
  /// 获取当前用户（或指定 [userId] 的用户）。
  Future<Result<User>> getCurrentUser({String? userId});
}
