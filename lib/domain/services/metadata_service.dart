// lib/domain/services/metadata_service.dart
import 'dart:async';
import 'dart:convert' show utf8, latin1, Encoding; // ← Encoding 포함
import 'package:http/http.dart' as http;

/// 간단한 메타데이터 수집기
/// - 제목(title/og:title)
/// - 썸네일(og:image / twitter:image / itemprop="image" / <link rel=image_src>)
///
/// DB 스키마 변경 없이, 메모리에만 캐시합니다.
class MetadataService {
  // ─────────────────────────────────────────────────────────────
  // 캐시 (메모리)
  // ─────────────────────────────────────────────────────────────
  final Map<String, String?> _titleCache = <String, String?>{};
  final Map<String, String?> _imageCache = <String, String?>{};

  // 간단 LRU-ish: 너무 커지면 비우기(여기선 200개)
  static const _maxCache = 200;
  void _gcIfNeeded(Map m) {
    if (m.length > _maxCache) m.clear();
  }

  // ─────────────────────────────────────────────────────────────
  // Public APIs
  // ─────────────────────────────────────────────────────────────

  /// 제목(캐시 사용)
  Future<String?> fetchTitle(String url, {Duration timeout = const Duration(seconds: 7)}) async {
    final cached = _titleCache[url];
    if (cached != null || _titleCache.containsKey(url)) return cached;
    final html = await _getHtml(url, timeout: timeout);
    if (html == null) {
      _titleCache[url] = null;
      _gcIfNeeded(_titleCache);
      return null;
    }
    final title = _extractTitle(html);
    _titleCache[url] = title;
    _gcIfNeeded(_titleCache);
    return title;
  }

  /// 썸네일(OG-image 등) (캐시 사용)
  Future<String?> fetchOgImage(String url, {Duration timeout = const Duration(seconds: 7)}) async {
    final cached = _imageCache[url];
    if (cached != null || _imageCache.containsKey(url)) return cached;

    final html = await _getHtml(url, timeout: timeout);
    if (html == null) {
      _imageCache[url] = null;
      _gcIfNeeded(_imageCache);
      return null;
    }

    String? img = _extractOgImage(html);
    if (img != null && img.isNotEmpty) {
      // 상대경로면 절대경로로
      try {
        final base = Uri.parse(url);
        img = base.resolve(img).toString();
      } catch (_) {}
    }

    _imageCache[url] = img;
    _gcIfNeeded(_imageCache);
    return img;
  }

  // 캐시 무시하고 다시 시도하고 싶을 때(선택)
  Future<String?> refetchOgImage(String url, {Duration timeout = const Duration(seconds: 7)}) async {
    _imageCache.remove(url);
    return fetchOgImage(url, timeout: timeout);
  }

  // ─────────────────────────────────────────────────────────────
  // HTTP + 인코딩 처리
  // ─────────────────────────────────────────────────────────────
  Future<String?> _getHtml(String url, {Duration timeout = const Duration(seconds: 7)}) async {
    Uri? uri;
    try {
      uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    } catch (_) {
      return null;
    }

    try {
      final res = await http
          .get(
        uri,
        headers: const {
          'User-Agent':
          'Mozilla/5.0 (compatible; EveryLink/1.0; +https://example.app)',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      )
          .timeout(timeout);

      if (res.statusCode < 200 || res.statusCode >= 400) return null;

      // 인코딩 추정
      final bodyBytes = res.bodyBytes;
      final contentType = res.headers['content-type'] ?? '';
      final enc = _detectEncodingFromHeadersOrHtml(contentType, bodyBytes);
      return enc.decode(bodyBytes);
    } catch (_) {
      return null;
    }
  }

  // 헤더나 메타태그에서 charset 추출
  Encoding _detectEncodingFromHeadersOrHtml(String contentTypeHeader, List<int> bodyBytes) {
    // 1) 헤더 우선
    final lc = contentTypeHeader.toLowerCase();
    final mHead = RegExp(r'charset=([\w\-\d]+)').firstMatch(lc);
    if (mHead != null) {
      final enc = mHead.group(1)!.toLowerCase();
      return _encodingFromLabel(enc);
    }

    // 2) 바디 앞부분 스캔(최대 8KB)
    final sample = _safeDecodeAscii(bodyBytes, 8192);

    // <meta charset="utf-8">
    final m1 = RegExp(
      r"""<meta\s+charset=["']?([\w\-\d]+)["']?>""",
      caseSensitive: false,
    ).firstMatch(sample);
    if (m1 != null) {
      final enc = m1.group(1)!.toLowerCase();
      return _encodingFromLabel(enc);
    }

    // <meta http-equiv="content-type" content="text/html; charset=utf-8">
    final m2 = RegExp(
      r"""<meta[^>]+http-equiv=["']content-type["'][^>]*content=["'][^>]*charset=([\w\-\d]+)[^>]*["']""",
      caseSensitive: false,
    ).firstMatch(sample);
    if (m2 != null) {
      final enc = m2.group(1)!.toLowerCase();
      return _encodingFromLabel(enc);
    }

    // 기본은 utf8, 실패하면 latin1
    try {
      utf8.decode(bodyBytes);
      return utf8;
    } catch (_) {
      return latin1;
    }
  }

  // 바이너리를 ASCII로만 안전 디코드(깨질 수 있으나 패턴 탐지용)
  String _safeDecodeAscii(List<int> bytes, int max) {
    final len = bytes.length < max ? bytes.length : max;
    final buf = StringBuffer();
    for (var i = 0; i < len; i++) {
      final b = bytes[i];
      buf.writeCharCode(b >= 32 && b < 127 ? b : 32); // 비ASCII는 공백
    }
    return buf.toString();
  }

  Encoding _encodingFromLabel(String label) {
    switch (label) {
      case 'utf-8':
      case 'utf8':
        return utf8;
      case 'latin1':
      case 'iso-8859-1':
        return latin1;
      default:
      // 모르는 라벨이면 utf8 시도 -> 실패 시 latin1
        return utf8;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HTML 파싱 (정규)
  // ─────────────────────────────────────────────────────────────

  String? _extractTitle(String html) {
    // og:title
    final og = RegExp(
      r"""<meta\s+(?:property|name)=["']og:title["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
    ).firstMatch(html);
    if (og != null) return og.group(1);

    // <title>...</title>
    final t = RegExp(
      r"""<title[^>]*>([^<]+)</title>""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (t != null) return t.group(1)?.trim();

    // twitter:title
    final tw = RegExp(
      r"""<meta\s+(?:property|name)=["']twitter:title["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
    ).firstMatch(html);
    if (tw != null) return tw.group(1);

    return null;
  }

  String? _extractOgImage(String html) {
    // og:image
    final og = RegExp(
      r"""<meta\s+(?:property|name)=["']og:image["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
    ).firstMatch(html);
    if (og != null) return og.group(1);

    // twitter:image
    final tw = RegExp(
      r"""<meta\s+(?:property|name)=["']twitter:image["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
    ).firstMatch(html);
    if (tw != null) return tw.group(1);

    // itemprop="image"
    final ip = RegExp(
      r"""<meta\s+itemprop=["']image["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
    ).firstMatch(html);
    if (ip != null) return ip.group(1);

    // <link rel="image_src" href="...">
    final link = RegExp(
      r"""<link\s+rel=["']image_src["']\s+href=["']([^"']+)["']""",
      caseSensitive: false,
    ).firstMatch(html);
    if (link != null) return link.group(1);

    return null;
  }
}
