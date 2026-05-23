import 'package:flutter_claude_app_v2/features/detail/domain/entities/article_detail.dart';

/// 文章详情数据访问（T19.3）。失败抛异常，由 provider 走 AsyncError。
abstract class DetailRepository {
  Future<ArticleDetail> fetchDetail(String id);
}
