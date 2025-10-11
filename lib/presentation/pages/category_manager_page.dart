// lib/presentation/pages/category_manager_page.dart
import 'package:flutter/material.dart';
import 'package:everylink/data/repositories/link_repository.dart';

class CategoryManagerPage extends StatefulWidget {
  const CategoryManagerPage({super.key, required this.repo});
  final LinkRepository repo;

  @override
  State<CategoryManagerPage> createState() => _CategoryManagerPageState();
}

class _CategoryManagerPageState extends State<CategoryManagerPage> {
  // id, name, linkCount, note, visible
  List<({int id, String name, int linkCount, String? note, bool visible})> _stats = [];

  String _query = '';
  bool _booting = true;   // 로딩 게이트
  bool _changed = false;  // 홈으로 되돌아갈 때 새로고침 유도용

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _reload();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리를 불러오지 못했어요. 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _booting = false);
    }
  }

  Future<void> _reload() async {
    final s = await widget.repo.fetchCategoryStatsWithVisible(); // ✅ visible 포함
    if (!mounted) return;
    setState(() => _stats = s);
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _edit({
    required String oldName,
    required String initialNote,
  }) async {
    final nameCtrl = TextEditingController(text: oldName);
    final noteCtrl = TextEditingController(text: initialNote);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카테고리 편집'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: '새 이름 (기존과 같으면 메모만 수정)',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtrl,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '메모 (선택)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('저장')),
        ],
      ),
    );

    if (ok == true) {
      final newName = nameCtrl.text.trim();
      final newNote = noteCtrl.text.trim();

      // 이름 변경/병합 (새 이름이 비어있거나 동일하면 스킵)
      if (newName.isNotEmpty && newName.toLowerCase() != oldName.toLowerCase()) {
        await widget.repo.renameOrMergeCategory(oldName, newName);
        _changed = true;
      }

      // 메모 업데이트 (변경된 이름 기준)
      final targetName = newName.isEmpty ? oldName : newName;
      await widget.repo.updateCategoryNoteByName(targetName, newNote);

      await _reload();
      if (mounted) _snack('저장되었습니다');
    }
  }

  Future<void> _delete(String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('"$name" 카테고리를 삭제할까요?\n해당 카테고리에 연결된 링크와의 관계만 제거됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await widget.repo.deleteCategoryByName(name);
      _changed = true;
      await _reload();
      if (mounted) _snack('삭제되었습니다');
    }
  }

  // 뒤로가기 시 홈에 변경사항 알림(리로드 유도)
  Future<bool> _onWillPop() async {
    Navigator.of(context).pop(_changed);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // ✅ 부팅 게이트: DB에서 로드 끝나기 전엔 로더만
    if (_booting) {
      return Scaffold(
        appBar: AppBar(title: const Text('카테고리 관리')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 검색 필터링(숨김/보임 상관없이 관리자에서 모두 표시)
    final filtered = _stats.where((e) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return e.name.toLowerCase().contains(q) ||
          (e.note ?? '').toLowerCase().contains(q);
    }).toList();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(title: const Text('카테고리 관리')),
        body: RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            slivers: [
              // 검색창
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: '카테고리/메모 검색',
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
              ),

              // 빈 상태
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_off_rounded, size: 56, color: cs.outline),
                          const SizedBox(height: 12),
                          const Text('표시할 카테고리가 없어요',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          const Text(
                            '링크를 저장해서 카테고리를 만들어 보세요.\n또는 검색어를 지워보세요.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
              // 리스트 (간격 포함)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (ctx, index) {
                        if (index.isOdd) return const SizedBox(height: 8);
                        final i = index ~/ 2;
                        final it = filtered[i];

                        final subtitleWidgets = <Widget>[
                          Text('연결된 링크: ${it.linkCount}개'),
                        ];
                        if ((it.note ?? '').trim().isNotEmpty) {
                          subtitleWidgets.add(
                            Text(
                              it.note!.trim(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: cs.shadow.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.label_rounded,
                                  color: cs.onPrimaryContainer, size: 20),
                            ),
                            title: Text(
                              it.name,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: subtitleWidgets,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✅ DB visible 컬럼과 연결된 "숨기기" 스위치
                                Row(
                                  children: [
                                    const Text('숨기기'),
                                    Switch(
                                      value: it.visible == false ? true : false, // visible=false ⇒ 숨김 스위치 ON
                                      onChanged: (hidden) async {
                                        // hidden=true ⇒ visible=false
                                        final newVisible = !hidden;
                                        await widget.repo.updateCategoryVisibleByName(
                                          it.name,
                                          newVisible,
                                        );
                                        _changed = true;
                                        await _reload();
                                      },
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') {
                                      _edit(oldName: it.name, initialNote: it.note ?? '');
                                    } else if (v == 'delete') {
                                      _delete(it.name);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'edit', child: Text('편집(이름/메모)')),
                                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filtered.isEmpty ? 0 : filtered.length * 2 - 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
