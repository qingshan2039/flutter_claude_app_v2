import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/error/failures.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/app_error_view.dart';

/// 网络错误组件（T14.1）：断网 / 超时专用，wifi-off 图标 + 重试。
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    super.key,
    this.message = '网络连接不可用，请检查后重试',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorView(
      icon: Icons.wifi_off_outlined,
      title: '网络异常',
      message: message,
      onRetry: onRetry,
    );
  }
}

/// 把 M03 的 [Failure] 映射到合适的状态组件（T14.1 + M03 联动）。
///
/// 在 Repository 返回 `Result`/`Failure` 的页面里直接用：
/// ```dart
/// case Failed(failure: final f): return FailureView(failure: f, onRetry: reload);
/// ```
class FailureView extends StatelessWidget {
  const FailureView({required this.failure, super.key, this.onRetry});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (failure) {
      NetworkFailure(:final message) => NetworkErrorWidget(
        message: message,
        onRetry: onRetry,
      ),
      UnauthorizedFailure(:final message) => AppErrorView(
        icon: Icons.lock_outline,
        title: '需要登录',
        message: message,
        retryLabel: '去登录',
        onRetry: onRetry,
      ),
      ValidationFailure(:final message) => AppErrorView(
        icon: Icons.rule_outlined,
        title: '校验未通过',
        message: message,
        onRetry: onRetry,
      ),
      ServerFailure(:final message, :final statusCode) => AppErrorView(
        icon: Icons.cloud_off_outlined,
        title: statusCode == null ? '服务异常' : '服务异常 ($statusCode)',
        message: message,
        onRetry: onRetry,
      ),
      CacheFailure(:final message) => AppErrorView(
        icon: Icons.sd_card_alert_outlined,
        title: '缓存异常',
        message: message,
        onRetry: onRetry,
      ),
      UnknownFailure(:final message) => AppErrorView(
        message: message,
        onRetry: onRetry,
      ),
    };
  }
}
