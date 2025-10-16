// lib/domain/services/normalize.dart
String normalize(String s) => s.trim().toLowerCase();
String normalizeUrl(String input) {
  var s = input.trim();
  if (s.isEmpty) return s;
  if (!s.contains('://')) s = 'https://$s';
  return s;
}

/// 텍스트에서 URL을 추출합니다.
/// "구글 https://google.com 테스트"와 같은 텍스트에서 https://google.com만 추출합니다.
String? extractUrl(String input) {
  final reg = RegExp(
    r'\b(https?://[a-zA-Z0-9\-._~:/?#\[\]@!$&()*+,;=%]+)',
    caseSensitive: false,
  );
  final match = reg.firstMatch(input);
  if (match != null) {
    var url = match.group(1) ?? '';
    // URL 끝의 불필요한 문장부호 제거
    url = url.replaceAll(RegExp(r'[.,;:!?\)\]]+$'), '');
    if (url.isNotEmpty) return url;
  }
  return null;
}

List<String> parseCategoriesInput(String input) {
  return input
      .split(',')
      .map((e) => normalize(e))
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();
}
