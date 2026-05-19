import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements AuthRepository {
  _FakeRepo(this.result);
  Result<User> result;

  @override
  Future<Result<User>> getCurrentUser({String? userId}) async => result;
}

void main() {
  ProviderContainer makeContainer({required AuthRepository repo}) {
    final container = ProviderContainer(
      overrides: <Override>[
        getCurrentUserUseCaseProvider.overrideWithValue(
          GetCurrentUserUseCase(repo),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('currentUserResultProvider (Result<User> 暴露层)', () {
    test('Success 路径 → 返回 Success', () async {
      const user = User(id: '1', name: 'A', email: 'a@b.com');
      final container = makeContainer(
        repo: _FakeRepo(const Success<User>(user)),
      );

      final result = await container.read(currentUserResultProvider.future);
      expect(result, isA<Success<User>>());
      expect((result as Success<User>).value.name, 'A');
    });

    test('Failed 路径 → 返回 Failed（不抛异常）', () async {
      final container = makeContainer(
        repo: _FakeRepo(const Failed<User>(NetworkFailure(message: 'offline'))),
      );

      final result = await container.read(currentUserResultProvider.future);
      expect(result, isA<Failed<User>>());
      expect((result as Failed<User>).failure, isA<NetworkFailure>());
    });
  });

  group('currentUserProvider (AsyncValue 拍平层)', () {
    test('Success 路径 → AsyncData', () async {
      const user = User(id: '1', name: 'A', email: 'a@b.com');
      final container = makeContainer(
        repo: _FakeRepo(const Success<User>(user)),
      );

      final value = await container.read(currentUserProvider.future);
      expect(value, equals(user));
      final state = container.read(currentUserProvider);
      expect(state.hasValue, isTrue);
      expect(state.hasError, isFalse);
    });

    test('Failed 路径 → AsyncError', () async {
      final container = makeContainer(
        repo: _FakeRepo(const Failed<User>(UnauthorizedFailure())),
      );

      await expectLater(
        container.read(currentUserProvider.future),
        throwsA(anything),
      );
      final state = container.read(currentUserProvider);
      expect(state.hasError, isTrue);
    });
  });

  group('依赖替换：override getCurrentUserUseCaseProvider', () {
    test('不同 override 互不影响', () async {
      const okUser = User(id: 'ok', name: 'OK', email: 'ok@b.com');

      final okContainer = makeContainer(
        repo: _FakeRepo(const Success<User>(okUser)),
      );
      final failContainer = makeContainer(
        repo: _FakeRepo(const Failed<User>(NetworkFailure())),
      );

      final okResult = await okContainer.read(currentUserResultProvider.future);
      final failResult =
          await failContainer.read(currentUserResultProvider.future);

      expect(okResult, isA<Success<User>>());
      expect(failResult, isA<Failed<User>>());
    });
  });
}
