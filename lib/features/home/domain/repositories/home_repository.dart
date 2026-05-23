import 'package:flutter_claude_app_v2/features/home/domain/entities/feed_item.dart';

/// 首页信息流数据访问（T19.2）。
abstract class HomeRepository {
  /// 分页拉取信息流。[page] 从 1 开始。返回不足 [pageSize] 视为最后一页。
  Future<List<FeedItem>> fetchFeed({required int page, required int pageSize});
}
