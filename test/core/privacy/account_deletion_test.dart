import 'package:flutter_claude_app_v2/core/privacy/account_deletion.dart';
import 'package:flutter_claude_app_v2/core/privacy/user_data_eraser.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

class _SpyEraser implements UserDataEraser {
  bool erased = false;
  @override
  Future<void> eraseAll() async => erased = true;
}

void main() {
  group('AccountDeletionService 冷静期纯函数 (T24.3)', () {
    const period = Duration(days: 7);
    final requested = DateTime(2026, 5, 1);

    test('isDue：未到期 false / 到期 true', () {
      expect(
        AccountDeletionService.isDue(requested, DateTime(2026, 5, 5), period),
        isFalse,
      );
      expect(
        AccountDeletionService.isDue(requested, DateTime(2026, 5, 8), period),
        isTrue,
      );
    });

    test('daysRemaining：向上取整、最小 0', () {
      expect(
        AccountDeletionService.daysRemaining(
          requested,
          DateTime(2026, 5, 1),
          period,
        ),
        7,
      );
      expect(
        AccountDeletionService.daysRemaining(
          requested,
          DateTime(2026, 5, 6, 12),
          period,
        ),
        2,
      );
      expect(
        AccountDeletionService.daysRemaining(
          requested,
          DateTime(2026, 6, 1),
          period,
        ),
        0,
      );
    });
  });

  group('AccountDeletionService 流程 (T24.3)', () {
    late InMemoryKeyValueStorage kv;
    late _SpyEraser eraser;
    late AccountDeletionService service;

    setUp(() {
      kv = InMemoryKeyValueStorage();
      eraser = _SpyEraser();
      service = AccountDeletionService(kv, eraser);
    });

    test('requestDeletion → 进入冷静期，可读到待处理请求', () async {
      expect(service.pendingRequest(), isNull);
      final req = await service.requestDeletion();
      expect(req.scheduledAt.isAfter(req.requestedAt), isTrue);
      expect(service.pendingRequest(), isNotNull);
      expect(service.isCoolingOff(), isTrue);
      expect(service.remainingDays(), inInclusiveRange(1, 7));
    });

    test('cancelDeletion → 清除请求', () async {
      await service.requestDeletion();
      await service.cancelDeletion();
      expect(service.pendingRequest(), isNull);
      expect(service.isCoolingOff(), isFalse);
    });

    test('finalizeIfDue：冷静期内不清理', () async {
      await service.requestDeletion();
      final didErase = await service.finalizeIfDue();
      expect(didErase, isFalse);
      expect(eraser.erased, isFalse);
      expect(service.pendingRequest(), isNotNull);
    });

    test('finalizeIfDue：已过冷静期 → 清理数据 + 清除请求', () async {
      // 直接写入一个很久以前的请求时间（模拟冷静期已过）。
      await kv.setString(
        'account.deletion.requestedAt',
        DateTime(2020).toIso8601String(),
      );
      final didErase = await service.finalizeIfDue();
      expect(didErase, isTrue);
      expect(eraser.erased, isTrue);
      expect(service.pendingRequest(), isNull);
    });
  });
}
