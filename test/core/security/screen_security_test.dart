import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/security/screen_security.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockScreenSecurity extends Mock implements ScreenSecurity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  group('ScreenSecurityImpl (T18.4)', () {
    const impl = ScreenSecurityImpl();
    final invoked = <String>[];

    setUp(() {
      invoked.clear();
      messenger.setMockMethodCallHandler(ScreenSecurityImpl.channel, (call) async {
        invoked.add(call.method);
        return null;
      });
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(ScreenSecurityImpl.channel, null);
    });

    test('enableSecure → 调原生 enableSecure', () async {
      await impl.enableSecure();
      expect(invoked, <String>['enableSecure']);
    });

    test('disableSecure → 调原生 disableSecure', () async {
      await impl.disableSecure();
      expect(invoked, <String>['disableSecure']);
    });

    test('无原生 handler 时静默降级（不抛）', () async {
      messenger.setMockMethodCallHandler(ScreenSecurityImpl.channel, null);
      await expectLater(impl.enableSecure(), completes);
    });
  });

  group('SecureScreen (T18.4)', () {
    testWidgets('挂载时 enable、卸载时 disable', (tester) async {
      final security = _MockScreenSecurity();
      when(() => security.enableSecure()).thenAnswer((_) async {});
      when(() => security.disableSecure()).thenAnswer((_) async {});

      await tester.pumpWidget(
        SecureScreen(screenSecurity: security, child: const SizedBox()),
      );
      verify(() => security.enableSecure()).called(1);
      verifyNever(() => security.disableSecure());

      await tester.pumpWidget(const SizedBox()); // 移除 → dispose
      verify(() => security.disableSecure()).called(1);
    });
  });
}
