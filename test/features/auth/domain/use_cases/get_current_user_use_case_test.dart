import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo(this._result);
  final Result<User> _result;
  int callCount = 0;
  String? lastUserId;

  @override
  Future<Result<User>> getCurrentUser({String? userId}) async {
    callCount++;
    lastUserId = userId;
    return _result;
  }

  @override
  Future<Result<User>> signIn({
    required String email,
    required String password,
  }) async => _result;

  @override
  Future<void> signOut() async {}
}

void main() {
  test('成功路径：返回 Success<User>', () async {
    const user = User(id: '1', name: 'A', email: 'a@b.com');
    final repo = _FakeAuthRepo(const Success<User>(user));
    final useCase = GetCurrentUserUseCase(repo);

    final result = await useCase();

    expect(result, isA<Success<User>>());
    expect((result as Success<User>).value.name, 'A');
    expect(repo.callCount, 1);
  });

  test('失败路径：返回 Failed<User>', () async {
    final repo = _FakeAuthRepo(
      const Failed<User>(NetworkFailure(message: 'offline')),
    );
    final useCase = GetCurrentUserUseCase(repo);

    final result = await useCase();

    expect(result, isA<Failed<User>>());
    expect((result as Failed<User>).failure, isA<NetworkFailure>());
  });

  test('userId 参数透传给 Repository', () async {
    const user = User(id: 'xyz', name: 'X', email: 'x@b.com');
    final repo = _FakeAuthRepo(const Success<User>(user));
    final useCase = GetCurrentUserUseCase(repo);

    await useCase(userId: 'xyz');
    expect(repo.lastUserId, 'xyz');
  });

  test('UseCase 是无状态的：多次调用安全', () async {
    const user = User(id: '1', name: 'A', email: 'a@b.com');
    final repo = _FakeAuthRepo(const Success<User>(user));
    final useCase = GetCurrentUserUseCase(repo);

    await useCase();
    await useCase();
    await useCase();
    expect(repo.callCount, 3);
  });
}
