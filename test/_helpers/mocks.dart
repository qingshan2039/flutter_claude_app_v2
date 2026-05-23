import 'package:flutter_claude_app_v2/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_claude_app_v2/features/auth/data/models/user_model.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/use_cases/get_current_user_use_case.dart';
import 'package:mocktail/mocktail.dart';

/// 共享 mock 工具（T17.2）。
///
/// mocktail **无需代码生成**：`class MockX extends Mock implements X {}` 即可。
/// 用法（在测试里）：
/// ```dart
/// final ds = MockAuthRemoteDataSource();
/// when(() => ds.fetchUser(userId: any(named: 'userId')))
///     .thenAnswer((_) async => const UserModel(id: '1', name: 'A', email: 'a@b'));
/// // ...
/// verify(() => ds.fetchUser(userId: 'x')).called(1);
/// ```
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGetCurrentUserUseCase extends Mock
    implements GetCurrentUserUseCase {}

/// 注册 mocktail `any()`/`captureAny()` 用到的非基元类型「兜底值」。
///
/// 只有当某个被 stub 的方法**参数是非基元类型**且测试用 `any()` 匹配时才需要。
/// 在测试文件的 `setUpAll` 里调用一次即可。
void registerCommonFallbackValues() {
  registerFallbackValue(const User(id: '', name: '', email: ''));
  registerFallbackValue(const UserModel(id: '', name: '', email: ''));
}
