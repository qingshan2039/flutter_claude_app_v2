import 'package:flutter_claude_app_v2/features/home/domain/entities/feed_item.dart';
import 'package:flutter_claude_app_v2/features/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

/// 占位实现（T19.2）：模拟 400ms 网络分页，共 4 页（60 条），之后返回空。
/// M19 后接真实 API 时只改本类。
@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl();

  static const int maxPages = 4;

  @override
  Future<List<FeedItem>> fetchFeed({
    required int page,
    required int pageSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (page > maxPages) return const <FeedItem>[];
    final start = (page - 1) * pageSize;
    return List<FeedItem>.generate(pageSize, (i) {
      final n = start + i + 1;
      return FeedItem(
        id: '$n',
        title: '文章 #$n',
        subtitle: '第 $page 页 · 这是第 $n 条信息流摘要',
      );
    });
  }
}
