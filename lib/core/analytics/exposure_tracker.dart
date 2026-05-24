import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics.dart';
import 'package:flutter_claude_app_v2/core/analytics/analytics_event.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// 自动曝光埋点（T27.3）。
///
/// 用 [VisibilityDetector] 监测 [child] 进入视口；可见比例首次达到 [threshold]
/// 时，上报一次 `element_exposure` 事件（用 [exposureName] 标识），并回调
/// [onExposed]。**只触发一次**（避免反复滚动重复上报）。
///
/// ```dart
/// ExposureTracker(
///   exposureName: 'home_banner',
///   child: BannerCard(),
/// );
/// ```
/// 测试中设 `VisibilityDetectorController.instance.updateInterval = Duration.zero`
/// 可让回调即时触发。
class ExposureTracker extends StatefulWidget {
  const ExposureTracker({
    required this.exposureName,
    required this.child,
    super.key,
    this.threshold = 0.5,
    this.onExposed,
    this.analytics,
    this.extraParams,
  });

  final String exposureName;
  final Widget child;

  /// 触发曝光的最小可见比例（0–1）。
  final double threshold;

  /// 曝光时的额外回调（可选）。
  final VoidCallback? onExposed;

  /// 埋点实现；为 null 时从 DI 取 [Analytics]。
  final Analytics? analytics;

  /// 附加事件参数。
  final Map<String, Object?>? extraParams;

  @override
  State<ExposureTracker> createState() => _ExposureTrackerState();
}

class _ExposureTrackerState extends State<ExposureTracker> {
  bool _fired = false;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_fired || !mounted) return;
    if (info.visibleFraction < widget.threshold) return;
    _fired = true;
    widget.onExposed?.call();
    final analytics = widget.analytics ?? getIt<Analytics>();
    unawaited(
      analytics.track(
        AnalyticsEvent.exposure(widget.exposureName, extra: widget.extraParams),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey<String>('exposure_${widget.exposureName}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: widget.child,
    );
  }
}
