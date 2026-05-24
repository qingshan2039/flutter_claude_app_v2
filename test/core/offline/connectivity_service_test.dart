import 'package:flutter_claude_app_v2/core/offline/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkStatus (T25.4)', () {
    test('isOnline / isOffline', () {
      expect(NetworkStatus.online.isOnline, isTrue);
      expect(NetworkStatus.online.isOffline, isFalse);
      expect(NetworkStatus.offline.isOffline, isTrue);
    });
  });

  group('ConnectivityServiceImpl (T25.4)', () {
    late ConnectivityServiceImpl service;

    setUp(() => service = ConnectivityServiceImpl());
    tearDown(() => service.dispose());

    test('默认在线', () {
      expect(service.status, NetworkStatus.online);
    });

    test('setStatus 改变状态并广播变化', () async {
      final events = <NetworkStatus>[];
      final sub = service.onStatusChange.listen(events.add);

      service.setStatus(NetworkStatus.offline);
      service.setStatus(NetworkStatus.online);
      await pumpEventQueue();

      expect(service.status, NetworkStatus.online);
      expect(events, <NetworkStatus>[
        NetworkStatus.offline,
        NetworkStatus.online,
      ]);
      await sub.cancel();
    });

    test('设置相同状态不重复广播', () async {
      final events = <NetworkStatus>[];
      final sub = service.onStatusChange.listen(events.add);

      service.setStatus(NetworkStatus.offline);
      service.setStatus(NetworkStatus.offline); // 重复，应忽略
      await pumpEventQueue();

      expect(events, <NetworkStatus>[NetworkStatus.offline]);
      await sub.cancel();
    });
  });
}
