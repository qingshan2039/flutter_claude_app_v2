import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/core/error/result.dart';
import 'package:flutter_claude_app_v2/features/auth/domain/entities/user.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/providers/current_user_provider.dart';
import 'package:flutter_claude_app_v2/features/auth/presentation/widgets/current_user_badge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../_helpers/mocks.dart';

/// T17.3：Widget 测试 + Provider 注入范例。
///
/// 通过 `ProviderScope.overrides` 把 [getCurrentUserUseCaseProvider] 换成
/// mocktail mock，从而精确控制 [CurrentUserBadge] 的 data / error / loading 三态，
/// 全程不碰 DI、网络与真实 UseCase。
void main() {
  late MockGetCurrentUserUseCase useCase;

  setUp(() => useCase = MockGetCurrentUserUseCase());

  Widget boot() => ProviderScope(
    overrides: <Override>[
      getCurrentUserUseCaseProvider.overrideWithValue(useCase),
    ],
    child: const MaterialApp(home: Scaffold(body: CurrentUserBadge())),
  );

  testWidgets('data：显示用户名', (tester) async {
    when(() => useCase()).thenAnswer(
      (_) async => const Success<User>(
        User(id: '1', name: 'Trinity', email: 't@m.io'),
      ),
    );

    await tester.pumpWidget(boot());
    await tester.pump(); // 等 FutureProvider 完成

    expect(find.text('Trinity'), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });

  testWidgets('error：Failed → 显示「加载失败」', (tester) async {
    when(() => useCase()).thenAnswer(
      (_) async => const Failed<User>(NetworkFailure(message: 'offline')),
    );

    await tester.pumpWidget(boot());
    await tester.pump();

    expect(find.text('加载失败'), findsOneWidget);
  });

  testWidgets('loading：未完成时显示转圈', (tester) async {
    // 永不完成的 Future → 停在 loading 态（注意：不要 pumpAndSettle）。
    when(() => useCase()).thenAnswer((_) => Completer<Result<User>>().future);

    await tester.pumpWidget(boot());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
