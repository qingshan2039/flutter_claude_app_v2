import 'package:flutter_claude_app_v2/core/error/error_mapper.dart';
import 'package:flutter_claude_app_v2/core/error/exceptions.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_claude_app_v2/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../_helpers/mocks.dart';

/// T17.1：Repository 单元测试范例 —— 用 **mocktail** mock 掉 DataSource，
/// 只验证 Repository 自己的职责：调用数据源 → mapper 转换 → 错误归一化。
void main() {
  late MockAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(dataSource, const ErrorMapper());
  });

  group('AuthRepositoryImpl.getCurrentUser (T17.1)', () {
    test('成功：DataSource 返回 UserModel → 映射为 User 包进 Success', () async {
      when(() => dataSource.fetchUser(userId: any(named: 'userId'))).thenAnswer(
        (_) async => const UserModel(id: '7', name: 'Neo', email: 'neo@m.io'),
      );

      final result = await repository.getCurrentUser(userId: '7');

      expect(result, isA<Success<User>>());
      expect((result as Success<User>).value.name, 'Neo');
      verify(() => dataSource.fetchUser(userId: '7')).called(1);
    });

    test('失败：DataSource 抛异常 → ErrorMapper 归一化为 Failed(NetworkFailure)',
        () async {
      when(() => dataSource.fetchUser(userId: any(named: 'userId')))
          .thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.getCurrentUser();

      expect(result, isA<Failed<User>>());
      expect((result as Failed<User>).failure, isA<NetworkFailure>());
    });

    test('userId 透传给 DataSource', () async {
      when(() => dataSource.fetchUser(userId: any(named: 'userId'))).thenAnswer(
        (_) async => const UserModel(id: 'x', name: 'X', email: 'x@m.io'),
      );

      await repository.getCurrentUser(userId: 'abc');

      verify(() => dataSource.fetchUser(userId: 'abc')).called(1);
    });
  });
}
