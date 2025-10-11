// lib/presentation/pages/home_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:url_launcher/url_launcher.dart'; // launchUrl, LaunchMode

import 'package:everylink/domain/models.dart';
import 'package:everylink/domain/constants.dart'; // kUncategorized
import 'package:everylink/domain/services/normalize.dart'; // normalizeUrl, parseCategoriesInput
import 'package:everylink/domain/services/metadata_service.dart';

import 'package:everylink/data/local_db.dart';
import 'package:everylink/data/repositories/link_repository.dart';
// import 'package:everylink/data/repositories/suggestion_source.dart'; // ❌ 더이상 필요없음

import 'package:everylink/presentation/sheets/add_link_sheet.dart';
import 'package:everylink/presentation/widgets/link_tile.dart';
import 'package:everylink/presentation/pages/category_manager_page.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:everylink/app/app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ─────────────────────────────
  // Services / State
  // ─────────────────────────────
  late final AppDatabase db;
  late final LinkRepository repo;
  final _meta = MetadataService();

  final _searchCtrl = TextEditingController();
  List<UrlItem> _all = [];
  List<UrlItem> _filtered = [];

  // TOP5/전체 카테고리(가시성 통과 링크 기준)
  List<({int id, String name, int linkCount, String? note})> _topCats = [];
  List<({int id, String name, int linkCount, String? note})> _allCats = [];
  String _selectedCategory = '전체';

  // 공유 수신 관련
  StreamSubscription<List<SharedMediaFile>>? _mediaShareSub;
  bool _isAddSheetOpen = false;

  // 부팅 게이트
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
    repo = LinkRepository(db);

    _bootstrap(); // 부팅 루틴

    _searchCtrl.addListener(_applyFilter);

    // 공유 수신 설정(미디어 스트림)
    final sharing = ReceiveSharingIntent.instance;
    _mediaShareSub = sharing.getMediaStream().listen((files) {
      if (!mounted) return;
      final url = _extractUrlFromMedia(files);
      if (url != null) _openAddLinkSheet(initialUrl: url);
    }, onError: (_) {});
    sharing.getInitialMedia().then((files) {
      if (!mounted) return;
      final url = _extractUrlFromMedia(files);
      if (url != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _openAddLinkSheet(initialUrl: url);
        });
      }
    });
  }

  @override
  void dispose() {
    _mediaShareSub?.cancel();
    _searchCtrl.dispose();
    db.close();
    super.dispose();
  }

  // ─────────────────────────────
  // Boot / Init / Reload
  // ─────────────────────────────
  Future<void> _bootstrap() async {
    bool okReload = false, okCats = false;
    try {
      await _reload();            // 가시성 통과 링크 로딩
      okReload = true;
    } catch (_) {}

    try {
      await _rebuildCategoryBar(); // 가시성 통과 링크 기준 TOP5/전체
      okCats = true;
    } catch (_) {}

    if (!mounted) return;
    setState(() => _booting = false);

    if (!(okReload && okCats)) {
      _snack('초기 데이터를 일부 불러오지 못했어요.');
    }
  }

  /// ✅ 가시성 통과 링크만 로드
  Future<void> _reload() async {
    if (!mounted) return;
    final items = await repo.fetchAllVisibleLinks();
    if (!mounted) return;
    setState(() => _all = items);
    _applyFilter();
  }

  /// ✅ 가시성 통과 링크만 기준으로 TOP5/전체 카테고리 집계
  Future<void> _rebuildCategoryBar() async {
    if (!mounted) return;

    final stats = await repo.fetchCategoryStatsFromVisibleLinks();
    final top = stats.take(5).toList();

    final allStats = stats.toList()..sort((a, b) => a.name.compareTo(b.name));

    if (!mounted) return;
    setState(() {
      _topCats = top;
      _allCats = allStats;
    });
  }

  void _applyFilter() {
    if (!mounted) return;
    final q = _searchCtrl.text.trim().toLowerCase();

    // 선택 카테고리 필터 (이미 _all은 가시성 통과 링크만 들어있음)
    List<UrlItem> base;
    if (_selectedCategory == '전체') {
      base = _all;
    } else {
      base = _all.where((e) => e.categories.contains(_selectedCategory)).toList();
    }

    // 검색어 필터
    final res = q.isEmpty
        ? base
        : base.where((e) {
      final title = (e.title ?? '').toLowerCase();
      final memo = (e.memo ?? '').toLowerCase();
      return e.url.toLowerCase().contains(q) ||
          title.contains(q) ||
          memo.contains(q) ||
          e.categories.any((c) => c.toLowerCase().contains(q));
    }).toList();

    setState(() => _filtered = res);
  }

  // ─────────────────────────────
  // Share helpers
  // ─────────────────────────────
  String? _extractUrlFromMedia(List<SharedMediaFile> files) {
    for (final f in files) {
      final mime = (f.mimeType ?? '').toLowerCase();
      final p = f.path.trim();

      if (mime.startsWith('text/') || f.type == SharedMediaType.text) {
        final reg = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
        final m = reg.firstMatch(p);
        if (m != null) return m.group(0);
      }
      if (p.startsWith('http://') || p.startsWith('https://')) return p;
    }
    return null;
  }

  Future<void> _openAddLinkSheet({String? initialUrl}) async {
    if (!mounted || _isAddSheetOpen) return;
    _isAddSheetOpen = true;
    await showAddLinkSheet(
      context,
      // ✅ 가시성 통과 카테고리만 추천 (문자열 리스트)
      suggest: (q, {limit = 8}) => repo.suggestPrefixVisible(q, limit: limit),
      onSave: _save,
      initialUrl: initialUrl ?? '',
    );
    _isAddSheetOpen = false;
  }

  // ─────────────────────────────
  // Save / Edit / Delete
  // ─────────────────────────────
  Future<void> _save(
      String url,
      List<String> cats, {
        String? title,
        String? memo,
      }) async {
    final normalized = normalizeUrl(url);
    if (normalized.isEmpty) return;

    // 쉼표 섞인 입력 방어 + ‘미지정’ 규칙
    final expanded = <String>{};
    for (final c in cats) {
      for (final p in parseCategoriesInput(c)) {
        expanded.add(p);
      }
    }
    var finalCats = expanded.toList();
    if (finalCats.isEmpty) {
      finalCats = [kUncategorized];
    } else if (finalCats.length > 1 && finalCats.contains(kUncategorized)) {
      finalCats.remove(kUncategorized);
    }

    final urlId =
    await repo.upsertUrl(normalized, title: title, memo: (memo ?? ''));

    // 카테고리 부착
    final ids = <int>[];
    for (final c in finalCats) {
      ids.add(await repo.upsertCategory(c));
    }
    await repo.attach(urlId, ids);

    // 자동 제목 수집 (사용자가 비웠을 때)
    if ((title == null || title.isEmpty)) {
      () async {
        final t = await _meta.fetchTitle(normalized);
        if (!mounted) return;
        if (t != null && t.isNotEmpty) {
          await repo.updateUrlTitle(urlId, t);
          if (!mounted) return;
          await _reload();
        }
      }();
    }

    await _reload();
    if (!mounted) return;
    await _rebuildCategoryBar();
    if (mounted) _snack('저장 완료!');
  }

  Future<void> _openEditSheet(UrlItem it) async {
    await showAddLinkSheet(
      context,
      // ✅ 편집 화면 추천도 가시성 통과 카테고리만
      suggest: (q, {limit = 8}) => repo.suggestPrefixVisible(q, limit: limit),
      initialUrl: it.url,
      initialCategories: it.categories,
      initialTitle: it.title ?? '',
      initialMemo: it.memo ?? '',
      onSave: (newUrl, newCats, {String? title, String? memo}) async {
        final urlId = it.id;

        final newNorm = normalizeUrl(newUrl);
        if (newNorm.isEmpty) {
          if (mounted) _snack('URL을 입력해 주세요');
          return;
        }

        // URL 변경
        if (newNorm != it.url) {
          await repo.updateUrlHref(urlId, newNorm);
        }

        // 카테고리 교체(쉼표 분할 + ‘미지정’ 규칙)
        final expanded = <String>{};
        for (final c in newCats) {
          for (final p in parseCategoriesInput(c)) {
            expanded.add(p);
          }
        }
        var finalCats = expanded.toList();
        if (finalCats.isEmpty) {
          finalCats = [kUncategorized];
        } else if (finalCats.length > 1 && finalCats.contains(kUncategorized)) {
          finalCats.remove(kUncategorized);
        }
        final catIds = <int>[];
        for (final c in finalCats) {
          catIds.add(await repo.upsertCategory(c));
        }
        await repo.replaceCategoriesForUrl(urlId, catIds);

        // 제목/메모
        if (title == null) {
          final t = await _meta.fetchTitle(newNorm);
          if (t != null && t.isNotEmpty) {
            await repo.updateUrlTitle(urlId, t);
          } else {
            await repo.updateUrlTitle(urlId, newNorm);
          }
        } else {
          await repo.updateUrlTitle(urlId, title);
        }
        if (memo != null) {
          await repo.updateUrlMemo(urlId, memo);
        }

        if (!mounted) return;
        await _reload();
        if (!mounted) return;
        await _rebuildCategoryBar();
        if (mounted) _snack('수정 완료!');
      },
    );
    if (!mounted) return;
  }

  Future<void> _delete(UrlItem it) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: Text('이 링크를 삭제할까요?\n\n${it.url}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteUrlCascade(it.id);
      if (!mounted) return;
      await _reload();
      if (!mounted) return;
      await _rebuildCategoryBar();
      if (mounted) _snack('삭제했습니다');
    }
  }

  // ─────────────────────────────
  // UI helpers
  // ─────────────────────────────
  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _openUrlExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _snack('URL 형식이 올바르지 않아요');
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _snack('앱에서 열 수 없어요');
  }

  void _onMore(UrlItem it) async {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('열기'),
              onTap: () async {
                Navigator.pop(ctx);
                await _openUrlExternal(it.url);
              },
            ),
            ListTile(
              leading: const Icon(Icons.content_copy_rounded),
              title: const Text('URL 복사'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: it.url));
                if (mounted) _snack('복사되었습니다');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('편집'),
              onTap: () {
                Navigator.pop(ctx);
                _openEditSheet(it);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: const Text('삭제'),
              onTap: () {
                Navigator.pop(ctx);
                _delete(it);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────
  // Build
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ⬇️ 현재 테마에 맞춘 오버레이 스타일 생성
    final isLight = Theme.of(context).brightness == Brightness.light;
    final overlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // ← 투명으로! (중요)
      statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
      // navigationBarColor 등은 건드릴 필요 없으면 생략
    );

    // 부팅 게이트
    if (_booting) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [CircularProgressIndicator()],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await _reload();
              await _rebuildCategoryBar();
            },
            child: CustomScrollView(
              slivers: [
                const SliverSafeArea(top: true, bottom: false, sliver: SliverToBoxAdapter(child: SizedBox.shrink())),
                SliverAppBar(
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle: Theme.of(context).brightness == Brightness.light
                      ? SystemUiOverlayStyle.dark    // 밝은 배경 → 어두운 아이콘
                      : SystemUiOverlayStyle.light,  // 어두운 배경 → 밝은 아이콘
                  title: Text(
                    '모링',
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: '카테고리 관리',
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () async {
                        final changed = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => CategoryManagerPage(repo: repo)),
                        );
                        if (!mounted) return;
                        if (changed == true) {
                          await _reload();
                          if (!mounted) return;
                          await _rebuildCategoryBar();
                        }
                      },
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(64),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: '검색어 또는 카테고리',
                        ),
                      ),
                    ),
                  ),
                ),

                // 카테고리 바 (윗줄: TOP5, 아랫줄: 전체) — 모두 가시성 통과 링크 기준
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TOP 5
                      SizedBox(
                        height: _topCats.isEmpty ? 0 : 46,
                        child: ScrollConfiguration(
                          behavior: NoGlowScrollBehavior(),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                            children: [
                              for (int i = 0; i < _topCats.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _CategoryChip(
                                    label: '${_topCats[i].name} (${_topCats[i].linkCount})',
                                    selected: _selectedCategory == _topCats[i].name,
                                    onTap: () {
                                      setState(() => _selectedCategory = _topCats[i].name);
                                      _applyFilter();
                                    },
                                    variant: CategoryChipVariant.favorite,
                                    leadingStar: true,
                                    accent: kTop5Accents[i % kTop5Accents.length],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 전체
                      SizedBox(
                        height: 46,
                        child: ScrollConfiguration(
                          behavior: NoGlowScrollBehavior(),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const ClampingScrollPhysics(),
                            clipBehavior: Clip.none,
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _CategoryChip(
                                  label: '전체',
                                  selected: _selectedCategory == '전체',
                                  onTap: () {
                                    setState(() => _selectedCategory = '전체');
                                    _applyFilter();
                                  },
                                  variant: CategoryChipVariant.normal,
                                ),
                              ),
                              ..._allCats.map((c) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _CategoryChip(
                                  label: '${c.name} (${c.linkCount})',
                                  selected: _selectedCategory == c.name,
                                  onTap: () {
                                    setState(() => _selectedCategory = c.name);
                                    _applyFilter();
                                  },
                                  variant: CategoryChipVariant.normal,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 링크 목록
                if (_filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.link_off_rounded, size: 56, color: cs.outline),
                          const SizedBox(height: 12),
                          const Text('저장된 링크가 없어요',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text('오른쪽 아래 + 버튼이나 공유 메뉴에서 추가해 보세요.'),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) {
                        final it = _filtered[i];
                        return LinkTile(
                          item: it,
                          onTap: () => _openUrlExternal(it.url),
                          onMore: () => _onMore(it),
                          meta: _meta,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 추가 버튼
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await _openAddLinkSheet();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('추가'),
          ),
        ),
      ),
    );
  }
}

enum CategoryChipVariant { favorite, normal }

// TOP5 팔레트(깔끔하게 고정)
const kTop5Accents = <Color>[
  Color(0xFFF59E0B), // Amber 600
];

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.variant = CategoryChipVariant.normal,
    this.leadingStar = false,
    this.accent,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final CategoryChipVariant variant;
  final bool leadingStar;
  final Color? accent;

  static const _brandMint = Color(0xFF16BEA8);
  static const _amberStar = Color(0xFFFFB300);

  Color _darken(Color c, [double amount = .18]) =>
      Color.alphaBlend(Colors.black.withOpacity(amount), c);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseAccent =
    (variant == CategoryChipVariant.favorite) ? (accent ?? _brandMint) : _brandMint;

    final Color baseBg = (variant == CategoryChipVariant.favorite)
        ? baseAccent.withOpacity(isDark ? 0.30 : 0.22)
        : cs.surfaceContainerHighest.withOpacity(0.6);

    final Color bg = selected ? baseAccent.withOpacity(isDark ? 0.60 : 0.45) : baseBg;

    final Color textColor = selected ? Colors.black : cs.onSurface.withOpacity(0.72);
    final Color checkColor = selected ? _darken(baseAccent, .25) : Colors.transparent;
    final Color starColor = leadingStar ? _amberStar : Colors.transparent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingStar)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.star_rounded, size: 16, color: starColor),
                ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_rounded, size: 16, color: checkColor),
                ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
