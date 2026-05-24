import 'package:flutter_claude_app_v2/core/update/app_version.dart';
import 'package:flutter_claude_app_v2/core/update/update_manager.dart';
import 'package:flutter_claude_app_v2/core/update/update_models.dart';
import 'package:flutter_claude_app_v2/core/update/version_check_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeService implements VersionCheckService {
  _FakeService(this.info);
  final UpdateInfo info;
  @override
  Future<UpdateInfo> fetchLatest() async => info;
}

UpdateInfo _info({
  required String latest,
  required String min,
  bool preferSilent = false,
}) =>
    UpdateInfo(
      latestVersion: AppVersion.parse(latest),
      minSupportedVersion: AppVersion.parse(min),
      preferSilent: preferSilent,
    );

void main() {
  const manager = UpdateManager(_FakeNever());

  group('UpdateManager.decide 策略 (T23.1/T23.2)', () {
    test('current ≥ latest → upToDate', () {
      final d = manager.decide(
        current: AppVersion.parse('1.4.0'),
        info: _info(latest: '1.4.0', min: '1.0.0'),
      );
      expect(d.policy, UpdatePolicy.upToDate);
      expect(d.updateAvailable, isFalse);
      expect(d.isForced, isFalse);
    });

    test('current < minSupported → force', () {
      final d = manager.decide(
        current: AppVersion.parse('1.1.0'),
        info: _info(latest: '2.0.0', min: '1.2.0'),
      );
      expect(d.policy, UpdatePolicy.force);
      expect(d.isForced, isTrue);
      expect(d.updateAvailable, isTrue);
    });

    test('min ≤ current < latest 且 preferSilent → silent', () {
      final d = manager.decide(
        current: AppVersion.parse('1.3.0'),
        info: _info(latest: '1.4.0', min: '1.2.0', preferSilent: true),
      );
      expect(d.policy, UpdatePolicy.silent);
      expect(d.updateAvailable, isTrue);
    });

    test('min ≤ current < latest 默认 → optional', () {
      final d = manager.decide(
        current: AppVersion.parse('1.3.0'),
        info: _info(latest: '1.4.0', min: '1.2.0'),
      );
      expect(d.policy, UpdatePolicy.optional);
    });

    test('force 优先于 silent（低于 min 即使建议静默也强制）', () {
      final d = manager.decide(
        current: AppVersion.parse('1.0.0'),
        info: _info(latest: '2.0.0', min: '1.5.0', preferSilent: true),
      );
      expect(d.policy, UpdatePolicy.force);
    });
  });

  group('UpdateManager.check 拉取后端 + 决策 (T23.1)', () {
    test('check 用 service 返回信息决策', () async {
      final service = _FakeService(_info(latest: '1.4.0', min: '1.2.0'));
      final m = UpdateManager(service);
      final d = await m.check(current: AppVersion.parse('1.3.0'));
      expect(d.policy, UpdatePolicy.optional);
    });
  });
}

/// 仅用于 decide 测试的占位 service（decide 不触发网络）。
class _FakeNever implements VersionCheckService {
  const _FakeNever();
  @override
  Future<UpdateInfo> fetchLatest() => throw UnimplementedError();
}
