import 'package:flutter_claude_app_v2/core/error/error_mapper.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart' show Failure;
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/core/network/interceptors/auth_interceptor.dart'
    show TokenStorage;
import 'package:flutter_claude_app_v2/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_claude_app_v2/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// [AuthRepository] 的实现（T06.4 + T17.1 分层 + T19.1 登录）。
///
/// 职责（Repository 的典型边界）：
/// 1. 调 [AuthRemoteDataSource] 拿原始数据（DTO）
/// 2. 经 mapper 把 [UserModel] 转 [User]
/// 3. 登录成功把 token 落到 [TokenStorage]（M05 SecureStorage）
/// 4. try/catch + [ErrorMapper] 把异常归一化成 [Failure]，返回 [Result]
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage, this._errorMapper);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final ErrorMapper _errorMapper;

  @override
  Future<Result<User>> getCurrentUser({String? userId}) async {
    try {
      final model = await _remote.fetchUser(userId: userId);
      return Success(model.toEntity());
    } on Exception catch (e) {
      return Failed(_errorMapper.map(e));
    }
  }

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await _remote.signIn(email: email, password: password);
      await _tokenStorage.save(
        accessToken: resp.accessToken,
        refreshToken: resp.refreshToken,
      );
      return Success(resp.user.toEntity());
    } on Exception catch (e) {
      return Failed(_errorMapper.map(e));
    }
  }

  @override
  Future<void> signOut() => _tokenStorage.clear();
}
