import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/responsive/breakpoints.dart';

/// 平板 Master-Detail 布局示例（T12.4）。
///
/// - **窄屏（mobile）**：单栏列表；点列表项 push 详情页
/// - **宽屏（tablet+）**：[NavigationRail] + 左侧列表 + 右侧详情，三段并排；
///   选中项即时在右侧展示，无需跳转
///
/// 选中状态用 [_selectedIndex] 保留，横竖屏 / 宽窄切换时不丢失（State 不重建）。
class MasterDetailPage extends StatefulWidget {
  const MasterDetailPage({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  State<MasterDetailPage> createState() => _MasterDetailPageState();
}

class _MasterDetailPageState extends State<MasterDetailPage> {
  int _selectedIndex = 0;

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final isWide = context.isTabletOrLarger;
    return Scaffold(
      appBar: AppBar(title: const Text('Master-Detail')),
      body: isWide ? _buildWide(context) : _buildNarrow(context),
    );
  }

  // ── 宽屏：NavigationRail + 列表 + 详情 ──
  Widget _buildWide(BuildContext context) {
    return Row(
      children: <Widget>[
        NavigationRail(
          selectedIndex: 0,
          onDestinationSelected: (_) {},
          labelType: NavigationRailLabelType.all,
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(icon: Icon(Icons.list), label: Text('Items')),
            NavigationRailDestination(icon: Icon(Icons.star), label: Text('Starred')),
          ],
        ),
        const VerticalDivider(width: 1),
        // master list
        Expanded(
          flex: 2,
          child: _MasterList(
            itemCount: widget.itemCount,
            selectedIndex: _selectedIndex,
            onSelect: _select,
          ),
        ),
        const VerticalDivider(width: 1),
        // detail pane
        Expanded(
          flex: 3,
          child: _DetailPane(index: _selectedIndex),
        ),
      ],
    );
  }

  // ── 窄屏：单栏列表，点选 push 详情 ──
  Widget _buildNarrow(BuildContext context) {
    return _MasterList(
      itemCount: widget.itemCount,
      selectedIndex: -1, // 窄屏不高亮
      onSelect: (index) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text('Item $index')),
              body: _DetailPane(index: index),
            ),
          ),
        );
      },
    );
  }
}

class _MasterList extends StatelessWidget {
  const _MasterList({
    required this.itemCount,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey<String>('master_list'),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Item $index'),
          selected: index == selectedIndex,
          onTap: () => onSelect(index),
        );
      },
    );
  }
}

class _DetailPane extends StatelessWidget {
  const _DetailPane({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Detail of item $index',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
