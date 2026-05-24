import 'dart:async';

import 'package:injectable/injectable.dart';

/// 网络状态（T25.4）。
enum NetworkStatus {
  online,
  offline;

  bool get isOnline => this == NetworkStatus.online;
  bool get isOffline => this == NetworkStatus.offline;
}

/// 网络状态服务（T25.4）。
///
/// 暴露当前状态 + 变化流。[setStatus] 供数据源驱动：
/// - **生产**：在初始化时用 `connectivity_plus` 接入——
///   ```dart
///   Connectivity().onConnectivityChanged.listen((results) {
///     final online = !results.contains(ConnectivityResult.none);
///     getIt<ConnectivityService>().setStatus(
///       online ? NetworkStatus.online : NetworkStatus.offline,
///     );
///   });
///   ```
/// - **测试 / demo**：直接 `setStatus(...)` 模拟联网/断网。
abstract class ConnectivityService {
  NetworkStatus get status;

  /// 状态变化广播流（仅在状态实际改变时发射）。
  Stream<NetworkStatus> get onStatusChange;

  /// 设置当前状态（数据源/测试/demo 调用）。
  void setStatus(NetworkStatus status);

  /// 释放底层资源（DI 容器 dispose/reset 时调用）。
  Future<void> dispose();
}

@LazySingleton(as: ConnectivityService)
class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl();

  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();
  NetworkStatus _status = NetworkStatus.online;

  @override
  NetworkStatus get status => _status;

  @override
  Stream<NetworkStatus> get onStatusChange => _controller.stream;

  @override
  void setStatus(NetworkStatus status) {
    if (status == _status) return;
    _status = status;
    _controller.add(status);
  }

  /// 释放资源（injectable 在容器 reset 时调用）。
  @override
  @disposeMethod
  Future<void> dispose() => _controller.close();
}
