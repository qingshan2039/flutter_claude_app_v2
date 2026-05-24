import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/motion/app_hero.dart';
import 'package:flutter_claude_app_v2/core/motion/app_transitions.dart';
import 'package:flutter_claude_app_v2/core/motion/lottie_view.dart';
import 'package:flutter_claude_app_v2/core/motion/micro_interactions.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/motion_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';

const String _heroTag = 'motion-hero-demo';

/// M34 动效系统 demo：动效 Token / 转场 / Hero / Lottie seam / 微交互。
class MotionDemoPage extends StatefulWidget {
  const MotionDemoPage({super.key});

  @override
  State<MotionDemoPage> createState() => _MotionDemoPageState();
}

class _MotionDemoPageState extends State<MotionDemoPage> {
  AppTransitionType _transitionType = AppTransitionType.slideUp;
  bool _moved = false;
  bool _lottieAutoplay = true;
  bool _lottieRepeat = true;
  int _appearSeed = 0;

  void _pushTransition() {
    Navigator.of(context).push(
      AppTransitions.route<void>(
        type: _transitionType,
        builder: (_) => _TransitionDetailPage(type: _transitionType),
      ),
    );
  }

  void _pushHeroDetail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _HeroDetailPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoScaffold(
      moduleId: 'M34',
      title: '动效系统',
      children: <Widget>[
        DemoSection(
          title: '动效曲线规范（T34.1）',
          description: '统一时长（fast 150 / normal 250 / slow 400ms）与曲线'
              '（standard / emphasized / bounce…）。下方方块用 normal 时长 + '
              'emphasized 曲线移动。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 56,
                child: AnimatedAlign(
                  alignment:
                      _moved ? Alignment.centerRight : Alignment.centerLeft,
                  duration: MotionTokens.normal,
                  curve: MotionTokens.emphasized,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.tonal(
                onPressed: () => setState(() => _moved = !_moved),
                child: const Text('切换位置（normal · emphasized）'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '页面转场动画（T34.2）',
          description: 'AppTransitions.route 统一封装命令式导航转场：'
              'fade / slideUp / scale / sharedAxis。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  for (final t in AppTransitionType.values)
                    ChoiceChip(
                      label: Text(t.name),
                      selected: _transitionType == t,
                      onSelected: (_) => setState(() => _transitionType = t),
                    ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              FilledButton.icon(
                onPressed: _pushTransition,
                icon: const Icon(Icons.open_in_new),
                label: Text('打开详情页（${_transitionType.name}）'),
              ),
            ],
          ),
        ),
        DemoSection(
          title: 'Hero 动画封装（T34.3）',
          description: 'AppHero 用相同 tag 包裹来源/目标元素 → 共享元素转场。'
              '点击下方图标进入详情页观察放大飞行。',
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _pushHeroDetail,
              child: const AppHero(tag: _heroTag, child: _MotionLogo(size: 72)),
            ),
          ),
        ),
        DemoSection(
          title: 'Lottie 集成（T34.4）',
          description: '零依赖 seam：可控占位动画（autoplay / repeat），API 与真实 '
              'Lottie 一致。接入真实 lottie 见 LottieView 文档注释。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: LottieView(
                  source: 'assets/lottie/sample.json',
                  autoplay: _lottieAutoplay,
                  repeat: _lottieRepeat,
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('autoplay'),
                value: _lottieAutoplay,
                onChanged: (v) => setState(() => _lottieAutoplay = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('repeat'),
                value: _lottieRepeat,
                onChanged: (v) => setState(() => _lottieRepeat = v),
              ),
            ],
          ),
        ),
        DemoSection(
          title: '微交互组件（T34.5）',
          description: 'TapScale 按压缩放反馈；AppearAnimation 列表项交错入场'
              '（stagger，相邻 50ms）。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TapScale(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.md,
                    horizontal: SpacingTokens.lg,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('按住我（缩放反馈）'),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _appearSeed++),
                icon: const Icon(Icons.replay),
                label: const Text('重播列表入场'),
              ),
              const SizedBox(height: SpacingTokens.sm),
              for (var i = 0; i < 4; i++)
                AppearAnimation(
                  key: ValueKey<String>('appear-$_appearSeed-$i'),
                  delay: MotionTokens.staggerDelay(i),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(
                        '列表项 ${i + 1}'
                        '（delay ${MotionTokens.staggerDelay(i).inMilliseconds}ms）',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// T34.2 转场目标页。
class _TransitionDetailPage extends StatelessWidget {
  const _TransitionDetailPage({required this.type});

  final AppTransitionType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('转场详情（${type.name}）')),
      body: Center(
        child: Text(
          '使用 AppTransitions.${type.name} 进入',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

/// T34.3 Hero 目标页（同 tag 放大）。
class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero 详情')),
      body: const Center(
        child: AppHero(tag: _heroTag, child: _MotionLogo(size: 200)),
      ),
    );
  }
}

/// 演示用 logo（无网络图，Hero 飞行稳定）。
class _MotionLogo extends StatelessWidget {
  const _MotionLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(Icons.bolt, color: scheme.onPrimary, size: size * 0.5),
    );
  }
}
