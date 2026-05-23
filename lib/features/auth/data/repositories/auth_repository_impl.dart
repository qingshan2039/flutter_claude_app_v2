import 'package:flutter_claude_app_v2/core/error/error_mapper.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart' show Failure;
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_claude_app_v2/features/auth/data/mappers/user_mapper.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// [AuthRepository] 的实现（T06.4 + T17.1 重构为分层）。
///
/// 职责（Repository 的典型边界）：
/// 1. 调 [AuthRemoteDataSource] 拿原始 [UserModel]（数据获取）
/// 2. 经 mapper 把 [UserModel] 转 [User]（DTO → 领域实体）
/// 3. try/catch + [ErrorMapper] 把异常归一化成 [Failure]，返回 [Result]
///
/// 数据源是接口（seam），故本类可用 mock 数据源做纯单元测试，不碰网络。
/// M19/T19.1 接真实 API 时只改 [AuthRemoteDataSourceImpl]，本类不动。
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._errorMapper);

  final AuthRemoteDataSource _remote;
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
}
