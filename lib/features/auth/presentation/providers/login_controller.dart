import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/core/router/auth_redirect.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 桥接 DI 的 [SignInUseCase]；测试可 override 为替身。
final Provider<SignInUseCase> signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => getIt<SignInUseCase>(),
  name: 'signInUseCaseProvider',
);

/// 登录表单提交状态（T19.1）。
///
/// 以 `AsyncValue<void>` 表达「空闲 / 提交中 / 失败」：
/// - data：空闲或成功（页面据 [submit] 返回值决定跳转）
/// - loading：提交中（按钮转圈、表单禁用）
/// - error：失败（携带 [Failure]，页面内联显示）
class LoginController extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  /// 提交登录。成功返回 true（并置 isLoggedIn=true，守卫放行）。
  Future<bool> submit({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading<void>();
    final result = await ref.read(signInUseCaseProvider)(
      email: email,
      password: password,
    );
    return result.fold<bool>(
      (user) {
        ref.read(isLoggedInProvider.notifier).state = true;
        state = const AsyncData<void>(null);
        return true;
      },
      (failure) {
        state = AsyncError<void>(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final AutoDisposeNotifierProvider<LoginController, AsyncValue<void>>
loginControllerProvider =
    AutoDisposeNotifierProvider<LoginController, AsyncValue<void>>(
      LoginController.new,
      name: 'loginControllerProvider',
    );
