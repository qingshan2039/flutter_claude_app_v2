/// 首页信息流条目（T19.2）。
class FeedItem {
  const FeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}
