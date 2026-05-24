import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/debug/debug_entry.dart';
import 'package:flutter_claude_app_v2/core/env/app_environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DebugEntry.isAvailable (T29.1)', () {
    test('dev / staging 可用，prod 不可用', () {
      expect(DebugEntry.isAvailable(AppEnvironment.dev), isTrue);
      expect(DebugEntry.isAvailable(AppEnvironment.staging), isTrue);
      expect(DebugEntry.isAvailable(AppEnvironment.prod), isFalse);
    });
  });

  group('DebugEntry 触发 (T29.1)', () {
    testWidgets('enabled 时长按触发 onTrigger', (tester) async {
      var triggered = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugEntry(
              enabled: true,
              onTrigger: () => triggered++,
              child: const Text('LOGO'),
            ),
          ),
        ),
      );
      await tester.longPress(find.text('LOGO'));
      expect(triggered, 1);
    });

    testWidgets('disabled 时长按不触发', (tester) async {
      var triggered = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DebugEntry(
              enabled: false,
              onTrigger: () => triggered++,
              child: const Text('LOGO'),
            ),
          ),
        ),
      );
      await tester.longPress(find.text('LOGO'));
      expect(triggered, 0);
    });
  });
}
