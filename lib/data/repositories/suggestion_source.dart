// lib/data/repositories/suggestion_source.dart
import 'package:everylink/logic/fuzzy.dart'; // normalize 제외
import 'package:everylink/domain/services/normalize.dart';             // 여기 normalize만 사용
import 'link_repository.dart';
import 'package:everylink/domain/constants.dart';

class SuggestionSource {
  SuggestionSource(this.repo);
  final LinkRepository repo;

  final BKTree _bk = BKTree();
  bool _ready = false;
  final Map<String, int> _catLinkCount = {};

  Future<void> rebuild() async {
    final names = await repo.allActiveCategoryNames();
    _bk.clear();
    for (final n in names) { _bk.add(n); }
    _ready = true;

    final stats = await repo.fetchCategoryStats();
    _catLinkCount
      ..clear()
      ..addEntries(stats.map((e) => MapEntry(e.name, e.linkCount)));
  }

  Future<List<String>> suggest(String input, {int limit = 8}) async {
    final q = normalize(input);
    if (q.isEmpty) return [];
    final prefixRows = await repo.suggestPrefixActive(q, limit: limit);
    final prefix = prefixRows.map((c) => c.name).toList();

    List<String> fuzzy = [];
    if (_ready && prefix.length < limit) {
      final cand = _bk.search(q, 2).where((s) => s != q && !prefix.contains(s)).toList();
      cand.sort((a, b) {
        final da = editDistance(q, a);
        final dbb = editDistance(q, b);
        if (da != dbb) return da.compareTo(dbb);
        final ca = _catLinkCount[a] ?? 0, cb = _catLinkCount[b] ?? 0;
        if (ca != cb) return cb.compareTo(ca);
        return a.compareTo(b);
      });
      fuzzy = cand;
    }

    final merged = <String>[];
    for (final s in prefix) { if (!merged.contains(s)) merged.add(s); if (merged.length >= limit) break; }
    for (final s in fuzzy)  { if (!merged.contains(s)) merged.add(s); if (merged.length >= limit) break; }
    return merged.where((name) => name != kUncategorized).toList();
  }
}
