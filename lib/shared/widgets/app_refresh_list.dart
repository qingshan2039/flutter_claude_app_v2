import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/theme/tokens/spacing_tokens.dart';
import 'package:flutter_claude_app_v2/shared/widgets/states/states.dart';

/// 下拉刷新 / 上拉加载列表（T14.4）。
///
/// 封装 [EasyRefresh]，把「列表数据 + 刷新/加载回调」收敛成声明式入参，便于与
/// Riverpod 联动（见 showcase 的 M14 demo：provider 持有分页状态，本组件只管 UI）：
///
/// ```dart
/// AppRefreshList<Item>(
///   items: state.items,
///   hasMore: state.hasMore,
///   onRefresh: () => ref.read(p.notifier).refresh(),
///   onLoad: () => ref.read(p.notifier).loadMore(),
///   itemBuilder: (_, item, _) => ListTile(title: Text(item.title)),
/// );
/// ```
///
/// - 列表为空时展示 [empty]（默认 [EmptyWidget]），且仍可下拉刷新。
/// - [onLoad] 为 null 时不启用上拉加载。
/// - [hasMore] 为 false 时上拉到底显示「没有更多」（[IndicatorResult.noMore]）。
class AppRefreshList<T> extends StatelessWidget {
  const AppRefreshList({
    required this.items, required this.itemBuilder, required this.onRefresh, super.key,
    this.onLoad,
    this.hasMore = false,
    this.separator,
    this.padding,
    this.empty,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// 下拉刷新回调（必填）。
  final Future<void> Function() onRefresh;

  /// 上拉加载回调（可选）。
  final Future<void> Function()? onLoad;

  /// 是否还有更多数据（决定上拉到底是否显示「没有更多」）。
  final bool hasMore;

  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? SpacingTokens.pagePadding;

    return EasyRefresh(
      onRefresh: onRefresh,
      onLoad: onLoad == null
          ? null
          : () async {
              await onLoad!();
              return hasMore ? IndicatorResult.success : IndicatorResult.noMore;
            },
      child: items.isEmpty
          ? ListView(
              padding: pad,
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                SizedBox(height: 360, child: empty ?? const EmptyWidget()),
              ],
            )
          : ListView.separated(
              padding: pad,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => separator ?? SpacingTokens.gapSm,
              itemBuilder: (context, i) => itemBuilder(context, items[i], i),
            ),
    );
  }
}
