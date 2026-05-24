import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/offline/connectivity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 桥接 DI 中的 [ConnectivityService]（T25.4）。测试可 override。
final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>(
      (ref) => getIt<ConnectivityService>(),
      name: 'connectivityServiceProvider',
    );

/// 网络状态 Provider（T25.4）：先发当前状态，再跟随变化流。
///
/// ```dart
/// final status = ref.watch(networkStatusProvider).valueOrNull;
/// if (status?.isOffline ?? false) { /* 显示离线提示 */ }
/// ```
final StreamProvider<NetworkStatus> networkStatusProvider =
    StreamProvider<NetworkStatus>((ref) async* {
      final service = ref.watch(connectivityServiceProvider);
      yield service.status;
      yield* service.onStatusChange;
    }, name: 'networkStatusProvider');
