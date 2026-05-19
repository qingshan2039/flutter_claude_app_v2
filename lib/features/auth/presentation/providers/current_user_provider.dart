import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UseCase 在 Provider 中的标准用法（T06.4）。
///
/// 三层 provider：
/// 1. [getCurrentUserUseCaseProvider]：桥接 DI 与 Riverpod。读 `getIt<GetCurrentUserUseCase>()`。
///    测试中可 override 为 fake，避免触碰 DI 容器。
/// 2. [currentUserResultProvider]：调用 UseCase，返回原始 [Result&lt;User&gt;]
///    （成功 / 失败两态，类型安全）。
/// 3. [currentUserProvider]：派生为 [AsyncValue]&lt;User&gt;。Success 走 data 分支，
///    Failed 走 error 分支。UI 直接 `when` 即可。
///
/// 这个分层让：
/// - 业务逻辑（UseCase）与状态管理（Provider）解耦
/// - 测试可分别 override
/// - 错误显式经过 [Failure]，不会有意外的 throw

/// Bridge：从 DI 暴露 [GetCurrentUserUseCase] 到 Riverpod 树。
final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider =
    Provider<GetCurrentUserUseCase>(
      (ref) => getIt<GetCurrentUserUseCase>(),
      name: 'getCurrentUserUseCaseProvider',
    );

/// 原始 [Result] 值（Success / Failed 两态）。自动随上游变化重算。
final FutureProvider<Result<User>> currentUserResultProvider =
    FutureProvider<Result<User>>(
      (ref) async {
        final useCase = ref.watch(getCurrentUserUseCaseProvider);
        return useCase();
      },
      name: 'currentUserResultProvider',
    );

/// 把 [Result] 拍平成 Riverpod 自身的 [AsyncValue]，UI 用 `when` 处理。
final FutureProvider<User> currentUserProvider = FutureProvider<User>(
  (ref) async {
    final result = await ref.watch(currentUserResultProvider.future);
    return result.fold<User>(
      (user) => user,
      (Failure failure) {
        // 把 Failure 转为异常，让 Riverpod 自身路由到 error 状态
        throw _FailureException(failure);
      },
    );
  },
  name: 'currentUserProvider',
);

/// 内部包装类，仅用于把 [Failure] 经由 Riverpod 异常路径传播。
///
/// UI 层 `when(error: (e, st) => ...)` 时可：
/// `if (e is _FailureException) handle(e.failure);`
/// 但更推荐 UI 直接 `ref.watch(currentUserResultProvider)` 显式处理 [Result]。
class _FailureException implements Exception {
  const _FailureException(this.failure);
  final Failure failure;

  @override
  String toString() => 'FailureException($failure)';
}
