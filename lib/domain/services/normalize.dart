// lib/domain/services/normalize.dart
String normalize(String s) => s.trim().toLowerCase();
String normalizeUrl(String input) {
  var s = input.trim();
  if (s.isEmpty) return s;
  if (!s.contains('://')) s = 'https://$s';
  return s;
}
List<String> parseCategoriesInput(String input) {
  return input
      .split(',')
      .map((e) => normalize(e))
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();
}
