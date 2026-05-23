import 'package:flutter/material.dart';
import 'package:flutter_claude_app_v2/core/router/route_names.dart';
import 'package:flutter_claude_app_v2/features/home/domain/entities/feed_item.dart';
import 'package:flutter_claude_app_v2/features/home/presentation/providers/home_feed_controller.dart';
import 'package:flutter_claude_app_v2/shared/widgets/app_refresh_list.dart';
import 'package:flutter_claude_app_v2/shared/widgets/async_value_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 首页（T19.2）：信息流列表 + 下拉刷新 + 上拉分页（M14 组件），点项进详情。
///
/// 是 Shell（底部 Tab）的第一个分支。三态用 [AsyncValueWidget]，列表用
/// [AppRefreshList]。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(homeFeedControllerProvider);
    final controller = ref.read(homeFeedControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: AsyncValueWidget<HomeFeedState>(
        value: feed,
        skeleton: true,
        onRetry: () => ref.invalidate(homeFeedControllerProvider),
        data: (state) => AppRefreshList<FeedItem>(
          items: state.items,
          hasMore: state.hasMore,
          onRefresh: controller.refresh,
          onLoad: controller.loadMore,
          itemBuilder: (context, item, _) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(item.id)),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.goNamed(
                RouteNames.detail,
                pathParameters: <String, String>{'id': item.id},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
