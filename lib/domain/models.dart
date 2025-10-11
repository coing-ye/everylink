// lib/domain/models.dart
class UrlItem {
  UrlItem({
    required this.id,
    required this.url,
    required this.title,
    required this.createdAt,
    required this.categories,
    required this.memo,
  });
  final int id;
  final String url;
  final String? title;
  final DateTime createdAt;
  final List<String> categories;
  final String? memo;
}
