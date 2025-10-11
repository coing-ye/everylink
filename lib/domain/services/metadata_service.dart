// lib/domain/services/metadata_service.dart
import 'dart:async';
import 'dart:convert' show utf8, latin1;
import 'package:http/http.dart' as http;

/// 간단한 메타데이터 수집기
/// - 제목(title/og:title/twitter:title)
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

    final raw = _extractTitle(html);
    if (raw == null || raw.trim().isEmpty) {
      _titleCache[url] = null;
      _gcIfNeeded(_titleCache);
      return null;
    }

    final clean = _sanitizeTitle(raw);
    _titleCache[url] = clean;
    _gcIfNeeded(_titleCache);
    return clean;
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

  // 캐시 무시하고 다시 시도(선택)
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
          'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      )
          .timeout(timeout);

      if (res.statusCode < 200 || res.statusCode >= 400) return null;

      final bodyBytes = res.bodyBytes;
      final headerCT = res.headers['content-type'];

      // meta charset은 전체 디코딩 전, 앞 8KB만 라틴1로 가볍게 스니핑
      final headLen = bodyBytes.length < 8192 ? bodyBytes.length : 8192;
      final headLatin1 = latin1.decode(bodyBytes.sublist(0, headLen), allowInvalid: true);

      // ✅ 단일 raw 문자열(r'...') 대신 삼중 raw 문자열(r"""...""")로 변경
      final metaCharset = RegExp(
        r"""<meta\s+charset=["']?([a-zA-Z0-9\-_]+)["']?""",
        caseSensitive: false,
      ).firstMatch(headLatin1)?.group(1);

      // 관대한 본문 디코딩
      final html = _bestEffortDecode(
        bodyBytes,
        headerContentType: headerCT,
        metaCharset: metaCharset,
      );

      return html;
    } catch (_) {
      return null;
    }
  }

  /// 관대한 바이트→문자열 디코딩
  String _bestEffortDecode(List<int> bodyBytes, {String? headerContentType, String? metaCharset}) {
    // 1) 헤더/메타에서 charset 후보 추출
    String? candidate = () {
      final h = headerContentType?.toLowerCase() ?? '';
      final m = RegExp(r'charset\s*=\s*([^\s;]+)', caseSensitive: false).firstMatch(h);
      if (m != null) return m.group(1);
      return metaCharset?.toLowerCase();
    }();

    String tryDecodeUtf8(List<int> b) {
      try {
        return utf8.decode(b); // 표준 UTF-8
      } catch (_) {
        return utf8.decode(b, allowMalformed: true); // 깨짐 허용
      }
    }

    // 2) charset 후보에 따라 디코딩 시도
    if (candidate != null) {
      switch (candidate) {
        case 'utf-8':
        case 'utf8':
          return tryDecodeUtf8(bodyBytes);
        case 'iso-8859-1':
        case 'latin1':
        case 'latin-1':
          return latin1.decode(bodyBytes, allowInvalid: true);
      // windows-1252 등은 dart:convert 기본에 없음 → UTF-8로 관대하게
        default:
          return tryDecodeUtf8(bodyBytes);
      }
    }

    // 3) charset 정보가 없으면 UTF-8 우선, 실패 시 latin1까지 시도
    try {
      return utf8.decode(bodyBytes);
    } catch (_) {
      try {
        return latin1.decode(bodyBytes, allowInvalid: true);
      } catch (_) {
        return utf8.decode(bodyBytes, allowMalformed: true);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────
  // HTML 파싱 (정규)
  // ─────────────────────────────────────────────────────────────

  String? _extractTitle(String html) {
    // 우선순위: og:title → twitter:title → <title>
    final og = RegExp(
      r"""<meta\s+(?:property|name)=["']og:title["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (og != null) return og.group(1);

    final tw = RegExp(
      r"""<meta\s+(?:property|name)=["']twitter:title["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (tw != null) return tw.group(1);

    final t = RegExp(
      r"""<title[^>]*>(.*?)</title>""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (t != null) return t.group(1);

    return null;
  }

  String? _extractOgImage(String html) {
    // og:image
    final og = RegExp(
      r"""<meta\s+(?:property|name)=["']og:image["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (og != null) return og.group(1);

    // twitter:image
    final tw = RegExp(
      r"""<meta\s+(?:property|name)=["']twitter:image["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (tw != null) return tw.group(1);

    // itemprop="image"
    final ip = RegExp(
      r"""<meta\s+itemprop=["']image["']\s+content=["']([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (ip != null) return ip.group(1);

    // <link rel="image_src" href="...">
    final link = RegExp(
      r"""<link\s+rel=["']image_src["']\s+href=["']([^"']+)["']""",
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (link != null) return link.group(1);

    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // 후처리 유틸
  // ─────────────────────────────────────────────────────────────

  // 최소 HTML 엔터티 해제(&amp; 등)
  String _htmlEntityDecode(String s) {
    return s
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
    // 숫자형 엔터티(16진/10진)
        .replaceAllMapped(RegExp(r'&#x([0-9A-Fa-f]+);'), (m) {
      final code = int.tryParse(m.group(1)!, radix: 16);
      if (code == null) return m.group(0)!;
      return String.fromCharCode(code);
    }).replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
      final code = int.tryParse(m.group(1)!);
      if (code == null) return m.group(0)!;
      return String.fromCharCode(code);
    });
  }

  // 제목 정리: 엔터티 해제 + 제어문자 제거 + 공백 정리
  String _sanitizeTitle(String s) {
    var out = _htmlEntityDecode(s);
    // ASCII 제어문자 제거
    out = out.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');
    // 공백 정리
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    return out;
  }
}
