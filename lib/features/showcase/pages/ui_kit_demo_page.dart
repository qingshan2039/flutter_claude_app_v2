import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/di/injection.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/radius_tokens.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/features/showcase/widgets/demo_scaffold.dart';
import 'package:flutter_claude_app_v2/shared/utils/bottom_sheet_utils.dart';
import 'package:flutter_claude_app_v2/shared/utils/keyboard_utils.dart';
import 'package:flutter_claude_app_v2/shared/utils/overlay_utils.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_image.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_refresh_list.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_scaffold.dart';
import 'package:flutter_claude_app_v2/shared/widgets/async_value_widget.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 状态预览类型（T14.1 demo）。
enum _StateKind { empty, loading, skeleton, error, network }

/// 是否让 demo 的异步源报错（T14.2 demo）。
final AutoDisposeStateProvider<bool> _failModeProvider = StateProvider.autoDispose<bool>((ref) => false);

/// demo 异步源：400ms 后返回数据或抛错。
final AutoDisposeFutureProvider<String> _demoUserProvider = FutureProvider.autoDispose<String>((ref) async {
  final fail = ref.watch(_failModeProvider);
  await Future<void>.delayed(const Duration(milliseconds: 400));
  if (fail) throw Exception('mock server error 500');
  return 'Alice（id=1，加载耗时 400ms）';
});

/// M14 通用 UI 组件 — 可视化演示。
class UiKitDemoPage extends ConsumerStatefulWidget {
  const UiKitDemoPage({super.key});

  @override
  ConsumerState<UiKitDemoPage> createState() => _UiKitDemoPageState();
}

class _UiKitDemoPageState extends ConsumerState<UiKitDemoPage> {
  final OverlayService _overlay = getIt<OverlayService>();
  final TextEditingController _kbCtrl = TextEditingController();
  _StateKind _stateKind = _StateKind.empty; // 默认静态，避免初始即动画

  @override
  void dispose() {
    _kbCtrl.dispose();
    super.dispose();
  }

  Widget _statePreview(_StateKind kind) {
    return switch (kind) {
      _StateKind.empty => EmptyWidget(
        message: '这里什么都没有',
        actionLabel: '去添加',
        onAction: () => _overlay.showInfo('点击了「去添加」'),
      ),
      _StateKind.loading => const LoadingWidget(message: '加载中…'),
      _StateKind.skeleton => const SkeletonLoader(itemCount: 3),
      _StateKind.error => AppErrorView(
        message: '请求失败：500',
        onRetry: () => _overlay.showWarning('点击了重试'),
      ),
      _StateKind.network => NetworkErrorWidget(
        onRetry: () => _overlay.showWarning('点击了重试'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(_demoUserProvider);

    return DemoScaffold(
      title: '通用 UI 组件',
      moduleId: 'M14',
      children: <Widget>[
        // ── T14.1 状态组件集 ──
        DemoSection(
          title: 'T14.1 状态组件集',
          description: 'Loading / Empty / Error / NetworkError / 骨架屏',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SegmentedButton<_StateKind>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<_StateKind>>[
                  ButtonSegment(value: _StateKind.empty, label: Text('空')),
                  ButtonSegment(value: _StateKind.loading, label: Text('加载')),
                  ButtonSegment(value: _StateKind.skeleton, label: Text('骨架')),
                  ButtonSegment(value: _StateKind.error, label: Text('错误')),
                  ButtonSegment(value: _StateKind.network, label: Text('断网')),
                ],
                selected: <_StateKind>{_stateKind},
                onSelectionChanged: (s) =>
                    setState(() => _stateKind = s.first),
              ),
              SpacingTokens.gapMd,
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: RadiusTokens.allMd,
                ),
                child: SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: _statePreview(_stateKind),
                ),
              ),
            ],
          ),
        ),

        // ── T14.2 AsyncValueWidget ──
        DemoSection(
          title: 'T14.2 AsyncValueWidget',
          description: '把 Riverpod AsyncValue 三态映射到状态组件',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 120,
                child: AsyncValueWidget<String>(
                  value: asyncUser,
                  onRetry: () => ref.invalidate(_demoUserProvider),
                  data: (name) => Center(
                    child: DemoResultRow('data', name),
                  ),
                ),
              ),
              SpacingTokens.gapSm,
              Wrap(
                spacing: SpacingTokens.sm,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () => ref.invalidate(_demoUserProvider),
                    child: const Text('重新加载'),
                  ),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(_failModeProvider.notifier)
                        .update((v) => !v),
                    child: const Text('切换：成功/报错'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── T14.3 AppImage ──
        DemoSection(
          title: 'T14.3 AppImage（cached_network_image）',
          description: '内存+磁盘缓存 · 占位/错误图 · 圆角 / 圆形',
          child: Row(
            children: <Widget>[
              const AppImage(
                'https://picsum.photos/id/1025/200',
                width: 88,
                height: 88,
                borderRadius: RadiusTokens.allLg,
              ),
              SpacingTokens.hGapMd,
              AppImage.circle('https://picsum.photos/id/64/200', size: 88),
              SpacingTokens.hGapMd,
              const Expanded(
                child: Text('真机/模拟器联网后显示图片；无网络时回退占位/错误图。'),
              ),
            ],
          ),
        ),

        // ── T14.4 AppRefreshList ──
        DemoSection(
          title: 'T14.4 下拉刷新 / 上拉加载',
          description: '封装 easy_refresh，与 Riverpod 分页状态联动',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _RefreshListDemoPage(),
                ),
              ),
              icon: const Icon(Icons.list_alt),
              label: const Text('打开刷新列表示例'),
            ),
          ),
        ),

        // ── T14.5 Toast / Dialog ──
        DemoSection(
          title: 'T14.5 Toast / Dialog（脱离 context）',
          description: 'getIt<OverlayService>() 直接调用，无需 BuildContext',
          child: Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: <Widget>[
              OutlinedButton(
                onPressed: () => _overlay.showSuccess('保存成功'),
                child: const Text('成功 Toast'),
              ),
              OutlinedButton(
                onPressed: () => _overlay.showError('网络异常'),
                child: const Text('错误 Toast'),
              ),
              OutlinedButton(
                onPressed: () => _overlay.showWarning('请先填写表单'),
                child: const Text('警告 Toast'),
              ),
              OutlinedButton(
                onPressed: () async {
                  final ok = await _overlay.showConfirm(
                    title: '删除该项？',
                    message: '此操作不可撤销。',
                    confirmLabel: '删除',
                    destructive: true,
                  );
                  _overlay.showInfo('确认结果：$ok');
                },
                child: const Text('确认对话框'),
              ),
            ],
          ),
        ),

        // ── T14.6 BottomSheet ──
        DemoSection(
          title: 'T14.6 BottomSheet（统一样式 + 拖拽关闭）',
          child: Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: <Widget>[
              OutlinedButton(
                onPressed: _showSimpleSheet,
                child: const Text('普通底部弹层'),
              ),
              OutlinedButton(
                onPressed: _showDraggableSheet,
                child: const Text('可拖拽弹层'),
              ),
            ],
          ),
        ),

        // ── T14.7 键盘处理 ──
        DemoSection(
          title: 'T14.7 键盘处理',
          description: '点输入框外的空白处即收起键盘',
          child: DismissKeyboardOnTap(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
                  controller: _kbCtrl,
                  decoration: const InputDecoration(
                    labelText: '点这里弹出键盘',
                    hintText: '然后点空白处收起',
                  ),
                ),
                SpacingTokens.gapSm,
                const Text('（KeyboardSpacer 可让底部按钮浮在键盘之上）'),
              ],
            ),
          ),
        ),

        // ── T14.8 AppScaffold ──
        DemoSection(
          title: 'T14.8 AppScaffold（默认 AppBar + 加载遮罩）',
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _AppScaffoldDemoPage(),
                ),
              ),
              icon: const Icon(Icons.web_asset),
              label: const Text('打开 AppScaffold 示例'),
            ),
          ),
        ),
      ],
    );
  }

  void _showSimpleSheet() {
    _overlay.showAppBottomSheet<void>(
      builder: (context) => Padding(
        padding: SpacingTokens.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('分享'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDraggableSheet() {
    _overlay.showDraggableSheet<void>(
      builder: (context, controller) => ListView.builder(
        controller: controller,
        padding: SpacingTokens.pagePadding,
        itemCount: 30,
        itemBuilder: (_, i) => ListTile(title: Text('可拖拽内容 #$i')),
      ),
    );
  }
}

// ───────────────────────── T14.4 子页：刷新列表 ─────────────────────────

class _PagedState {
  const _PagedState({required this.items, required this.hasMore});
  final List<String> items;
  final bool hasMore;
}

class _PagedNotifier extends AutoDisposeNotifier<_PagedState> {
  static const _pageSize = 15;
  static const _maxItems = 45;

  @override
  _PagedState build() => _make(_pageSize);

  _PagedState _make(int count) => _PagedState(
    items: List<String>.generate(count, (i) => '列表项 #${i + 1}'),
    hasMore: count < _maxItems,
  );

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = _make(_pageSize);
  }

  Future<void> loadMore() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final next = (state.items.length + _pageSize).clamp(0, _maxItems);
    state = _make(next);
  }
}

final _pagedProvider =
    AutoDisposeNotifierProvider<_PagedNotifier, _PagedState>(
      _PagedNotifier.new,
    );

class _RefreshListDemoPage extends ConsumerWidget {
  const _RefreshListDemoPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_pagedProvider);
    final notifier = ref.read(_pagedProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('下拉刷新 / 上拉加载')),
      body: AppRefreshList<String>(
        items: state.items,
        hasMore: state.hasMore,
        onRefresh: notifier.refresh,
        onLoad: notifier.loadMore,
        itemBuilder: (_, item, _) => Card(
          child: ListTile(
            leading: const Icon(Icons.label_outline),
            title: Text(item),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── T14.8 子页：AppScaffold ─────────────────────────

class _AppScaffoldDemoPage extends StatefulWidget {
  const _AppScaffoldDemoPage();

  @override
  State<_AppScaffoldDemoPage> createState() => _AppScaffoldDemoPageState();
}

class _AppScaffoldDemoPageState extends State<_AppScaffoldDemoPage> {
  bool _loading = false;

  Future<void> _simulate() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AppScaffold 示例',
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => getIt<OverlayService>().showInfo('AppBar action'),
        ),
      ],
      isLoading: _loading,
      loadingMessage: '提交中…',
      padding: SpacingTokens.pagePadding,
      body: Center(
        child: FilledButton(
          onPressed: _loading ? null : _simulate,
          child: const Text('模拟提交（显示 2s 遮罩）'),
        ),
      ),
    );
  }
}
