import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// 登录返回的原始数据（用户 + token）。
typedef SignInResponse = ({UserModel user, String accessToken, String refreshToken});

/// 远程数据源抽象（T17.1 引入的测试缝隙 / seam）。
///
/// 只负责「拿原始数据（DTO / [UserModel]）」，不做领域转换、不处理 [Failure]。
/// 失败时**抛异常**，由上层 [AuthRepository] 统一归一化为 Result/Failure。
abstract class AuthRemoteDataSource {
  /// 拉取用户原始数据（可指定 [userId]）。
  Future<UserModel> fetchUser({String? userId});

  /// 登录（T19.1）：返回用户 + token 原始数据；失败抛异常。
  Future<SignInResponse> signIn({
    required String email,
    required String password,
  });
}

/// 占位实现：模拟网络 IO。M19/T19.1 接真实 API 时换成 retrofit ApiService 调用，
/// 上层 [AuthRepository] / UseCase / Provider 与测试都无需改动。
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl();

  @override
  Future<UserModel> fetchUser({String? userId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return UserModel(
      id: userId ?? 'demo-1',
      name: 'Demo User',
      email: 'demo@example.com',
      createdAt: DateTime.utc(2026, 5, 18),
    );
  }

  @override
  Future<SignInResponse> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // 演示错误路径：密码为 'fail' 时模拟服务端拒绝。
    if (password == 'fail') {
      throw const UnauthorizedException(message: '邮箱或密码错误');
    }
    return (
      user: UserModel(
        id: 'demo-1',
        name: email.split('@').first,
        email: email,
        createdAt: DateTime.utc(2026, 5, 18),
      ),
      accessToken: 'demo-access-token',
      refreshToken: 'demo-refresh-token',
    );
  }
}
