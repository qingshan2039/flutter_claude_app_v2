import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';

/// Lottie 资源类型（T34.4）。
enum LottieSourceType { asset, network }

/// Lottie 动画视图（T34.4）— **零依赖 seam 实现**。
///
/// 为保持模板「零新增依赖」，本组件默认渲染一个**可控的占位动画**（不引入
/// `lottie` 依赖、不绑定二进制资源），但暴露与真实 Lottie 一致的 API：资源来源、
/// 自动播放、循环。需要真实 Lottie 时按下述两步接入，业务调用处无需改动：
///
/// 1) 加依赖：
/// ```yaml
/// # pubspec.yaml
/// dependencies:
///   lottie: ^3.1.0   # 纯 Dart，无原生插件
/// ```
/// 2) 把 [build] 里的占位替换为：
/// ```dart
/// return Lottie.asset(widget.source,
///     repeat: widget.repeat, animate: widget.autoplay,
///     width: widget.size, height: widget.size);
/// ```
class LottieView extends StatefulWidget {
  const LottieView({
    required this.source,
    super.key,
    this.sourceType = LottieSourceType.asset,
    this.size = 120,
    this.autoplay = true,
    this.repeat = true,
    this.semanticLabel,
  });

  /// 资源路径（asset 路径或网络 URL）。占位实现仅透传，不实际加载。
  final String source;
  final LottieSourceType sourceType;
  final double size;

  /// 是否自动开始播放。
  final bool autoplay;

  /// 是否循环播放（false 则只播一次）。
  final bool repeat;
  final String? semanticLabel;

  @override
  State<LottieView> createState() => _LottieViewState();
}

class _LottieViewState extends State<LottieView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionTokens.slowest,
  );

  @override
  void initState() {
    super.initState();
    _applyPlayback();
  }

  @override
  void didUpdateWidget(LottieView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.repeat != widget.repeat) {
      _applyPlayback();
    }
  }

  void _applyPlayback() {
    if (!widget.autoplay) {
      _controller.stop();
      return;
    }
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: widget.semanticLabel ?? 'Lottie 动画占位：${widget.source}',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: RotationTransition(
            turns: _controller,
            child: Icon(
              Icons.auto_awesome,
              size: widget.size * 0.6,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
