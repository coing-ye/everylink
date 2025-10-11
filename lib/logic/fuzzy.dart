// lib/logic/fuzzy.dart
import 'dart:math';
import 'package:everylink/domain/services/normalize.dart';


/// Levenshtein 편집 거리 (삽입/삭제/치환 비용 1)
int editDistance(String a, String b) {
  final m = a.length, n = b.length;
  if (m == 0) return n;
  if (n == 0) return m;
  final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
  for (var i = 0; i <= m; i++) dp[i][0] = i;
  for (var j = 0; j <= n; j++) dp[0][j] = j;
  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      final cost = (a[i - 1] == b[j - 1]) ? 0 : 1;
      dp[i][j] = min(
        dp[i - 1][j] + 1, // 삭제
        min(
          dp[i][j - 1] + 1, // 삽입
          dp[i - 1][j - 1] + cost, // 치환
        ),
      );
    }
  }
  return dp[m][n];
}

/// BK-tree 노드
class _BKNode {
  _BKNode(this.term);
  final String term;
  final Map<int, _BKNode> edges = {}; // 거리 -> 다음 노드
}

/// 아주 단순한 BK-tree (문자열 사전)
class BKTree {
  _BKNode? _root;

  void clear() => _root = null;

  void add(String term) {
    final t = normalize(term);
    if (t.isEmpty) return;
    if (_root == null) {
      _root = _BKNode(t);
      return;
    }
    var node = _root!;
    while (true) {
      final d = editDistance(t, node.term);
      final next = node.edges[d];
      if (next == null) {
        node.edges[d] = _BKNode(t);
        break;
      }
      node = next;
    }
  }

  /// query와 편집거리 <= maxDistance 인 후보들
  List<String> search(String query, int maxDistance) {
    final q = normalize(query);
    final res = <String>[];
    final root = _root;
    if (root == null || q.isEmpty) return res;

    void dfs(_BKNode node) {
      final d = editDistance(q, node.term);
      if (d <= maxDistance) res.add(node.term);
      final start = d - maxDistance;
      final end = d + maxDistance;
      for (final entry in node.edges.entries) {
        final key = entry.key;
        if (key >= start && key <= end) dfs(entry.value);
      }
    }

    dfs(root);
    return res;
  }
}
