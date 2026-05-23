import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

/// 远程数据源抽象（T17.1 引入的测试缝隙 / seam）。
///
/// 只负责「拿原始数据（DTO / [UserModel]）」，不做领域转换、不处理 [Failure]。
/// 失败时**抛异常**，由上层 [AuthRepository] 统一归一化为 Result/Failure。
///
/// 把数据获取抽成接口后，Repository 测试可注入 mock 数据源（见
/// `test/features/auth/data/repositories/auth_repository_impl_test.dart`）。
abstract class AuthRemoteDataSource {
  /// 拉取用户原始数据（可指定 [userId]）。
  Future<UserModel> fetchUser({String? userId});
}

/// 占位实现：模拟 80ms IO，返回写死的 [UserModel]。
///
/// M19/T19.1 接真实 API 时，把这里换成 retrofit ApiService 调用即可，
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
}
