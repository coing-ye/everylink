// lib/presentation/sheets/add_link_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/services/normalize.dart'; // normalizeUrl, parseCategoriesInput

const kBrandMint = Color(0xFF16BEA8);

typedef SuggestFn = Future<List<String>> Function(String input, {int limit});
typedef SaveFn = void Function(
    String url,
    List<String> cats, {
    String? title,
    String? memo,
    });

Future<bool?> showAddLinkSheet(
    BuildContext context, {
      required SuggestFn suggest,
      required SaveFn onSave,
      String initialUrl = '',
      List<String> initialCategories = const [],
      String initialTitle = '',
      String initialMemo = '',
    }) {
  return showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: 0.92,
      child: _AddLinkSheet(
        suggest: suggest,
        onSave: onSave,
        initialUrl: initialUrl,
        initialCategories: initialCategories,
        initialTitle: initialTitle,
        initialMemo: initialMemo,
      ),
    ),
  );
}

class _AddLinkSheet extends StatefulWidget {
  const _AddLinkSheet({
    required this.suggest,
    required this.onSave,
    required this.initialUrl,
    required this.initialCategories,
    required this.initialTitle,
    required this.initialMemo,
  });

  final SuggestFn suggest;
  final SaveFn onSave;

  final String initialUrl;
  final List<String> initialCategories;
  final String initialTitle;
  final String initialMemo;

  @override
  State<_AddLinkSheet> createState() => _AddLinkSheetState();
}

class _AddLinkSheetState extends State<_AddLinkSheet> {
  // URL은 즉시 생성해두고, initState에서 text를 주입
  final TextEditingController urlCtrl = TextEditingController();

  late final TextEditingController titleCtrl;
  late final TextEditingController memoCtrl;
  late final TextEditingController catCtrl;

  bool _canSave = false; // 저장 버튼 활성화 여부

  final List<String> selected = [];
  List<String> suggestions = [];

  Timer? _debouncer;
  bool _closing = false; // 닫힘 전후 setState/타이머 방지 플래그

  @override
  void initState() {
    super.initState();

    // ✅ 초기값 주입 순서 중요!
    urlCtrl.text = widget.initialUrl;           // 1) 먼저 세팅
    urlCtrl.addListener(_recomputeCanSave);     // 2) 리스너 등록

    titleCtrl = TextEditingController(text: widget.initialTitle);
    memoCtrl  = TextEditingController(text: widget.initialMemo);
    catCtrl   = TextEditingController();

    selected.addAll(widget.initialCategories);

    _recomputeCanSave(); // 3) 활성화 상태 계산 (초기 URL 반영됨)
  }

  void _recomputeCanSave() {
    final ok = urlCtrl.text.trim().isNotEmpty;
    if (_canSave != ok) {
      setState(() => _canSave = ok);
    }
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    urlCtrl.removeListener(_recomputeCanSave); // ✅ 리스너 해제
    urlCtrl.dispose();
    titleCtrl.dispose();
    memoCtrl.dispose();
    catCtrl.dispose();
    super.dispose();
  }

  void _runSuggest() {
    _debouncer?.cancel();
    _debouncer = Timer(const Duration(milliseconds: 180), () async {
      if (!mounted || _closing) return;
      final r = await widget.suggest(catCtrl.text, limit: 8);
      if (!mounted || _closing) return;
      setState(() => suggestions = r);
    });
  }

  void _addCategoriesFromInput() {
    final parsed = parseCategoriesInput(catCtrl.text);
    if (parsed.isEmpty) return;
    setState(() {
      for (final v in parsed) {
        if (!selected.contains(v)) selected.add(v);
      }
      catCtrl.clear();
      suggestions = [];
    });
  }

  void _removeCategory(String c) {
    setState(() {
      selected.remove(c);
    });
  }

  // 외부 공유로 진입 시, 필요하면 이 헬퍼로 즉시 반영 가능
  void _handleIncomingSharedUrl(String shared) {
    urlCtrl.text = shared;
    _recomputeCanSave(); // 즉시 활성화 반영
  }

  void _save() {
    final url  = urlCtrl.text.trim();
    final tRaw = titleCtrl.text.trim();
    final mRaw = memoCtrl.text.trim();

    if (url.isEmpty) {
      // URL은 필수값: 비어있으면 저장하지 않고 안내
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL을 입력해 주세요')),
      );
      return;
    }

    // 남은 입력 반영(쉼표 분리 입력)
    final pending = parseCategoriesInput(catCtrl.text);
    for (final v in pending) {
      if (!selected.contains(v)) selected.add(v);
    }

    widget.onSave(
      url,
      selected,
      // 제목: 비우면 null → 호출측에서 자동수집/URL fallback 로직
      title: tRaw.isEmpty ? null : tRaw,
      // 메모: 호출측에서 ''로 정규화
      memo: mRaw,
    );

    _closing = true;
    _debouncer?.cancel();
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.add_link_rounded, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('링크 추가 / 편집', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 16),

            // URL
            TextField(
              controller: urlCtrl,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.url,                // ✅ URL 키보드
              autofillHints: const [AutofillHints.url],       // ✅ 자동완성 힌트
              smartDashesType: SmartDashesType.disabled,      // ‘–’ 자동 치환 방지
              decoration: const InputDecoration(hintText: 'https://example.com/...'),
            ),
            const SizedBox(height: 12),

            // 제목(선택)
            TextField(
              controller: titleCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(hintText: '제목 (선택, 비우면 자동 수집)'),
            ),
            const SizedBox(height: 12),

            // 메모(선택)
            TextField(
              controller: memoCtrl,
              minLines: 2,
              maxLines: 6,
              decoration: const InputDecoration(hintText: '메모 (선택)'),
            ),
            const SizedBox(height: 12),

            // 선택된 카테고리 칩
            if (selected.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selected.map((c) {
                  return ColoredCategoryChip(
                    label: c,
                    selected: true,
                    removable: true,
                    onTap: () => _removeCategory(c),
                    onRemove: () => _removeCategory(c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // 카테고리 입력
            TextField(
              controller: catCtrl,
              decoration: const InputDecoration(hintText: '카테고리 입력 (예: 쇼핑, 바지)'),
              onChanged: (_) => _runSuggest(),
              onSubmitted: (_) => _addCategoriesFromInput(),
            ),
            const SizedBox(height: 8),

            // 자동완성 + 새 카테고리 (컬러 칩 적용)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (catCtrl.text.trim().isNotEmpty)
                  ColoredCategoryChip(
                    label: '+ 새 카테고리: ${parseCategoriesInput(catCtrl.text).join(', ')}',
                    selected: false,
                    onTap: _addCategoriesFromInput,
                  ),

                ...suggestions.map((s) {
                  final isSel = selected.contains(s);
                  return ColoredCategoryChip(
                    label: s,
                    selected: isSel,
                    onTap: () {
                      if (!isSel) {
                        setState(() {
                          selected.add(s);
                          catCtrl.clear();
                          suggestions = [];
                        });
                      }
                    },
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _canSave ? _save : null, // ✅ URL 없으면 비활성
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────
// 칼라 칩(추가/편집 시트용) — 링크 타일의 칩 스타일과 통일
class ColoredCategoryChip extends StatelessWidget {
  const ColoredCategoryChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.removable = false,
    this.onRemove,
  });

  final String label;
  final bool selected;         // 선택 상태
  final bool removable;        // 선택 목록에서 'x' 버튼 표시 여부
  final VoidCallback onTap;    // 탭 시 동작(선택/해제/추가 등)
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 선택/비선택 배경/텍스트
    final bg = selected
        ? kBrandMint.withOpacity(isDark ? 0.60 : 0.45)
        : kBrandMint.withOpacity(isDark ? 0.30 : 0.20);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black, // 텍스트는 검정으로 통일
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              if (removable) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.black87),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
