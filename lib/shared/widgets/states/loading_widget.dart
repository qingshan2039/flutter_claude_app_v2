import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';

/// 加载组件（T14.1）。
///
/// 三种用法：
/// - **局部**：`LoadingWidget()` — 居中小转圈 + 可选文案，嵌在卡片/区块里。
/// - **全屏**：`LoadingWidget.fullscreen()` — 充满父约束并居中（页面整页 loading）。
/// - **骨架屏**：见 [SkeletonLoader] / [SkeletonBox]。
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message, this.size = 28})
    : _fullscreen = false;

  /// 全屏加载：撑满父容器、居中。
  const LoadingWidget.fullscreen({super.key, this.message, this.size = 36})
    : _fullscreen = true;

  /// 加载文案（可选）。
  final String? message;

  /// 进度圈直径。
  final double size;

  final bool _fullscreen;

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: size,
          height: size,
          child: const CircularProgressIndicator(strokeWidth: 3),
        ),
        if (message != null) ...<Widget>[
          SpacingTokens.gapSm,
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    final centered = Center(child: indicator);
    return _fullscreen ? SizedBox.expand(child: centered) : centered;
  }
}

/// 骨架屏单元（T14.1）：一个带微光（shimmer）动画的占位块。
///
/// 用在「内容结构已知、数据未到」的场景，比纯转圈更不打断视觉。
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = RadiusTokens.allSm,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.06),
      base,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // -1 → 2：让高光从左滑到右（含进出场）。
        final t = _controller.value * 3 - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
              colors: <Color>[base, highlight, base],
              stops: const <double>[0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// 骨架屏列表（T14.1）：重复 [itemCount] 行占位条目，模拟列表加载态。
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: SpacingTokens.pagePadding,
      itemCount: itemCount,
      separatorBuilder: (_, _) => SpacingTokens.gapMd,
      itemBuilder: (_, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          SkeletonBox(width: 48, height: 48, borderRadius: RadiusTokens.allMd),
          SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(height: 14),
                SizedBox(height: SpacingTokens.sm),
                SkeletonBox(width: 160, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
