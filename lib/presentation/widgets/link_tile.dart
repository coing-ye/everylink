// lib/presentation/widgets/link_tile.dart
import 'package:flutter/material.dart';
import 'package:everylink/domain/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:everylink/domain/services/metadata_service.dart';

const kBrandMint = Color(0xFF16BEA8);

class LinkTile extends StatelessWidget {
  const LinkTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onMore,
    required this.meta,
  });

  final UrlItem item;
  final VoidCallback onTap;
  final VoidCallback onMore;
  final MetadataService meta;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timeText = _relativeTime(item.createdAt);

    final bg = Theme.of(context).brightness == Brightness.light
        ? cs.surface
        : const Color(0xFF121316);

    // ── 파비콘 빌드 ──
    final uri = Uri.tryParse(item.url);
    final host = (uri?.host.isNotEmpty == true) ? uri!.host : null;

    final fallbackIcon = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.link_rounded, color: cs.primary),
    );

    Widget favicon;
    if (host == null) {
      favicon = fallbackIcon;
    } else {
      final primary = _googleFavicon(item.url, sz: 128);
      final secondary = _duckFavicon(host);
      favicon = _FaviconWithFallback(
        size: 36,
        borderRadius: 10,
        primary: primary,
        secondary: secondary,
        placeholderColor: cs.surfaceContainerHighest.withOpacity(0.6),
        fallback: fallbackIcon,
      );
    }

    return Card(
      elevation: 0,
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───────────────────────────────
              // [파비콘 + 썸네일] 세로 정렬
              // ───────────────────────────────
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  favicon,
                  const SizedBox(height: 8),
                  FutureBuilder<String?>(
                    future: meta.fetchOgImage(item.url),
                    builder: (ctx, snap) {
                      final url = snap.data;
                      if (url == null || url.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          url,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // ───────────────────────────────
              // 본문 내용
              // ───────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 등록 시간
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _titleOrFallback(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeText,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 메모
                    if ((item.memo ?? '').trim().isNotEmpty) ...[
                      Text(
                        item.memo!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // URL
                    Text(
                      item.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 카테고리 칩
                    if (item.categories.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: -8,
                        children: item.categories.map((c) {
                          return Chip(
                            label: Text(
                              c,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: kBrandMint.withOpacity(0.15),
                            side: BorderSide.none,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),

              // 더보기 버튼
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: onMore,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleOrFallback(UrlItem it) {
    final t = (it.title ?? '').trim();
    if (t.isNotEmpty) return t;
    try {
      final u = Uri.parse(it.url);
      return u.host.isNotEmpty ? u.host : it.url;
    } catch (_) {
      return it.url;
    }
  }

  String _relativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    final y = createdAt.year.toString().padLeft(4, '0');
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  String _googleFavicon(String url, {int sz = 128}) =>
      'https://www.google.com/s2/favicons?sz=$sz&domain_url=$url';
  String _duckFavicon(String host) =>
      'https://icons.duckduckgo.com/ip3/$host.ico';
}

/// 구글 → 덕덕고 → fallback 순서로 파비콘 표시
class _FaviconWithFallback extends StatelessWidget {
  const _FaviconWithFallback({
    required this.primary,
    required this.secondary,
    required this.fallback,
    this.size = 36,
    this.borderRadius = 10,
    this.placeholderColor,
  });

  final String primary;
  final String secondary;
  final Widget fallback;
  final double size;
  final double borderRadius;
  final Color? placeholderColor;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(borderRadius);
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final target = (size * dpr).round();

    return ClipRRect(
      borderRadius: br,
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: primary,
          fit: BoxFit.cover,
          memCacheWidth: target,
          memCacheHeight: target,
          fadeInDuration: const Duration(milliseconds: 120),
          placeholder: (_, __) => Container(color: placeholderColor ?? Colors.black12),
          errorWidget: (_, __, ___) => CachedNetworkImage(
            imageUrl: secondary,
            fit: BoxFit.cover,
            memCacheWidth: target,
            memCacheHeight: target,
            placeholder: (_, __) => Container(color: placeholderColor ?? Colors.black12),
            errorWidget: (_, __, ___) => fallback,
          ),
        ),
      ),
    );
  }
}
