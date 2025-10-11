// lib/data/repositories/link_repository.dart
import 'package:drift/drift.dart';
import 'package:everylink/data/local_db.dart';
import 'package:everylink/domain/models.dart';
import 'package:everylink/domain/services/normalize.dart';

abstract class ILinkRepository {
  // ─────────────────────────────
  // 기존 기능 (레거시: 전 카테고리/전 링크 기준)
  // ─────────────────────────────
  Future<List<UrlItem>> fetchAll();
  Future<int> upsertUrl(String url, {String? title, String? memo});
  Future<void> updateUrlTitle(int urlId, String title);
  Future<void> updateUrlMemo(int urlId, String memo);
  Future<int> upsertCategory(String name);
  Future<void> attach(int urlId, List<int> categoryIds);
  Future<void> replaceCategoriesForUrl(int urlId, List<int> categoryIds);
  Future<void> deleteUrlCascade(int urlId);
  Future<void> updateCategoryNoteByName(String name, String note);
  Future<List<({int id, String name, int linkCount, String? note})>> fetchCategoryStats();
  Future<List<String>> allActiveCategoryNames();
  Future<List<Category>> suggestPrefixActive(String prefix, {int limit});

  // ─────────────────────────────
  // v3: visible(표시/숨김) 확장 — **가시성 규칙을 통과한 링크 집합 기준**
  // ─────────────────────────────
  /// 카테고리 표시 여부 토글(이름 기준)
  Future<void> updateCategoryVisibleByName(String name, bool visible);

  /// (권장) 홈 목록: 하나라도 숨김 카테고리가 붙은 링크는 제외
  Future<List<UrlItem>> fetchAllVisibleLinks();

  /// (권장) TOP5/카테고리 바: 가시성 통과 링크만 대상으로 카운트
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchCategoryStatsFromVisibleLinks();

  /// (권장) 추천/BK-tree용: 가시성 통과 링크에서 등장하는 visible 카테고리명
  Future<List<String>> allCategoryNamesFromVisibleLinks();

  /// (권장) 접두사 자동완성: 가시성 통과 링크 + visible=1 범위에서 Category 행 반환
  Future<List<Category>> suggestPrefixFromVisibleLinks(String prefix, {int limit});

  // (참고) 관리화면 전용: 숨김 포함 통계
  Future<List<({int id, String name, int linkCount, String? note, bool visible})>>
  fetchCategoryStatsWithVisible();

  // (이전 v3 방식; 필요 시 유지)
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchVisibleCategoryStats();
  Future<List<String>> allVisibleCategoryNames();
  Future<Set<String>> visibleCategoryNameSet();

  // (이전 v3 방식; 문자열 추천)
  Future<List<String>> suggestPrefixVisible(String prefix, {int limit});
}

class LinkRepository implements ILinkRepository {
  LinkRepository(this.db);
  final AppDatabase db;

  // ─────────────────────────────────────────────────────────────
  // URL & 링크 항목 (레거시)
  // ─────────────────────────────────────────────────────────────
  @override
  Future<List<UrlItem>> fetchAll() => db.fetchAll();

  @override
  Future<int> upsertUrl(String url, {String? title, String? memo}) =>
      db.upsertUrl(url, title: title, memo: memo);

  Future<void> updateUrlHref(int urlId, String newUrl) =>
      db.updateUrlHref(urlId, newUrl);

  @override
  Future<void> updateUrlTitle(int urlId, String title) =>
      db.updateUrlTitle(urlId, title);

  @override
  Future<void> updateUrlMemo(int urlId, String memo) =>
      db.updateUrlMemo(urlId, memo);

  @override
  Future<void> deleteUrlCascade(int urlId) => db.deleteUrlCascade(urlId);

  // ─────────────────────────────────────────────────────────────
  // 카테고리 CRUD (+note)
  // ─────────────────────────────────────────────────────────────
  @override
  Future<int> upsertCategory(String name) => db.upsertCategory(normalize(name));

  Future<void> renameOrMergeCategory(String oldName, String newName) =>
      db.renameOrMergeCategory(oldName, newName);

  Future<void> deleteCategoryByName(String name) => db.deleteCategoryByName(name);

  @override
  Future<void> updateCategoryNoteByName(String name, String note) =>
      db.updateCategoryNoteByName(name, note);

  // ─────────────────────────────────────────────────────────────
  // URL ↔ Category 매핑
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> attach(int urlId, List<int> categoryIds) =>
      db.attachCategoriesToUrl(urlId, categoryIds);

  @override
  Future<void> replaceCategoriesForUrl(int urlId, List<int> categoryIds) =>
      db.replaceCategoriesForUrl(urlId, categoryIds);

  // ─────────────────────────────────────────────────────────────
  // 통계 / 목록 / 추천 (레거시: '활성' = 링크가 1개 이상 연결)
  // ─────────────────────────────────────────────────────────────
  @override
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchCategoryStats() =>
      db.fetchCategoryStats();

  @override
  Future<List<String>> allActiveCategoryNames() => db.allCategoryNames();

  @override
  Future<List<Category>> suggestPrefixActive(String prefix, {int limit = 8}) =>
      db.suggestPrefix(prefix, limit: limit);

  // ─────────────────────────────────────────────────────────────
  // ✅ v3: visible(표시/숨김) 확장 — 가시성 통과 링크 기준
  // ─────────────────────────────────────────────────────────────
  @override
  Future<void> updateCategoryVisibleByName(String name, bool visible) =>
      db.updateCategoryVisibleByName(name, visible);

  @override
  Future<List<UrlItem>> fetchAllVisibleLinks() => db.fetchAllVisibleLinks();

  @override
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchCategoryStatsFromVisibleLinks() =>
      db.fetchCategoryStatsFromVisibleLinks();

  @override
  Future<List<String>> allCategoryNamesFromVisibleLinks() =>
      db.allCategoryNamesFromVisibleLinks();

  @override
  Future<List<Category>> suggestPrefixFromVisibleLinks(
      String prefix, {
        int limit = 8,
      }) =>
      db.suggestPrefixVisible(prefix, limit: limit);

  // ── 관리화면/이전 v3 헬퍼들 (필요 시 유지) ──
  @override
  Future<List<({int id, String name, int linkCount, String? note, bool visible})>>
  fetchCategoryStatsWithVisible() =>
      db.fetchCategoryStatsWithVisible();

  @override
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchVisibleCategoryStats() =>
      db.fetchVisibleCategoryStats();

  @override
  Future<List<String>> allVisibleCategoryNames() =>
      db.allVisibleCategoryNames();

  @override
  Future<Set<String>> visibleCategoryNameSet() async =>
      (await db.allVisibleCategoryNames()).toSet();

  @override
  Future<List<String>> suggestPrefixVisible(String prefix, {int limit = 8}) =>
      // 현재 DB의 가시성 기반 추천은 Category 행을 반환하는 메서드이므로,
  // 문자열 추천이 필요한 경우엔 allVisibleCategoryNames()를 이용해
  // prefix 매칭을 앱단에서 필터링하는 쪽을 권장.
  db.allVisibleCategoryNames()
      .then((names) => names
      .where((n) => n.startsWith(prefix.trim().toLowerCase()))
      .take(limit)
      .toList());
}
