import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';

/// 按压缩放反馈（T34.5）。
///
/// 包裹任意子组件：按下时轻微缩小、松开回弹，提供物理触感的点击反馈；点击事件
/// 走 [onTap]。适合卡片 / 自定义按钮等需要触感的可点区域。
class TapScale extends StatefulWidget {
  const TapScale({
    required this.child,
    super.key,
    this.onTap,
    this.pressedScale = 0.96,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// 按下时的缩放比例（0–1，越小按压感越强）。
  final double pressedScale;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: MotionTokens.fast,
        curve: MotionTokens.pressable,
        child: widget.child,
      ),
    );
  }
}

/// 入场动画：淡入 + 上滑（T34.5）。
///
/// 用于列表项逐个出现：给每项传入随下标递增的 [delay]
/// （见 [MotionTokens.staggerDelay]）即可获得**交错（stagger）**入场效果。
class AppearAnimation extends StatefulWidget {
  const AppearAnimation({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = MotionTokens.normal,
    this.offset = const Offset(0, 0.12),
  });

  final Widget child;

  /// 开始播放前的延迟（交错入场用）。
  final Duration delay;
  final Duration duration;

  /// 入场起始位移（相对自身尺寸的比例，向终点 Offset.zero 滑动）。
  final Offset offset;

  @override
  State<AppearAnimation> createState() => _AppearAnimationState();
}

class _AppearAnimationState extends State<AppearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: MotionTokens.emphasized,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
