import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// 登录 UseCase（T19.1）。编排 [AuthRepository.signIn]。
@injectable
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<User>> call({
    required String email,
    required String password,
  }) =>
      _repository.signIn(email: email, password: password);
}
