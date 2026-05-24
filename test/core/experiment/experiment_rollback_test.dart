import 'package:flutter_claude_app_v2/core/experiment/experiment_rollback.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../_helpers/in_memory_kv.dart';

void main() {
  group('ExperimentRollback (T31.3)', () {
    test('rollback / isRolledBack / restore', () async {
      final r = ExperimentRollback(InMemoryKeyValueStorage());
      expect(r.isRolledBack('exp1'), isFalse);

      await r.rollback('exp1');
      expect(r.isRolledBack('exp1'), isTrue);
      expect(r.rolledBack(), contains('exp1'));

      await r.restore('exp1');
      expect(r.isRolledBack('exp1'), isFalse);
    });

    test('多实验 + restoreAll', () async {
      final r = ExperimentRollback(InMemoryKeyValueStorage());
      await r.rollback('a');
      await r.rollback('b');
      expect(r.rolledBack(), <String>{'a', 'b'});
      await r.restoreAll();
      expect(r.rolledBack(), isEmpty);
    });

    test('持久化：新实例读到同一回滚集合', () async {
      final kv = InMemoryKeyValueStorage();
      await ExperimentRollback(kv).rollback('exp');
      expect(ExperimentRollback(kv).isRolledBack('exp'), isTrue);
    });
  });
}
