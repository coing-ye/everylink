// lib/data/repositories/link_repository.dart
import 'package:everylink/data/local_db.dart';
import 'package:everylink/domain/models.dart';
import 'package:everylink/domain/services/normalize.dart';

/// 링크 및 카테고리 관리 리포지토리
///
/// 주요 기능:
/// - URL 저장, 수정, 삭제
/// - 카테고리 관리 (생성, 수정, 표시/숨김)
/// - 가시성 규칙 기반 링크 필터링
class LinkRepository {
  LinkRepository(this.db);
  final AppDatabase db;

  // ─────────────────────────────────────────────────────────────
  // URL & 링크 항목
  // ─────────────────────────────────────────────────────────────
  Future<List<UrlItem>> fetchAll() => db.fetchAll();

  Future<int> upsertUrl(String url, {String? title, String? memo}) =>
      db.upsertUrl(url, title: title, memo: memo);

  Future<void> updateUrlHref(int urlId, String newUrl) =>
      db.updateUrlHref(urlId, newUrl);

  Future<void> updateUrlTitle(int urlId, String title) =>
      db.updateUrlTitle(urlId, title);

  Future<void> updateUrlMemo(int urlId, String memo) =>
      db.updateUrlMemo(urlId, memo);

  Future<void> deleteUrlCascade(int urlId) => db.deleteUrlCascade(urlId);

  // ─────────────────────────────────────────────────────────────
  // 카테고리 CRUD
  // ─────────────────────────────────────────────────────────────
  Future<int> upsertCategory(String name) => db.upsertCategory(normalize(name));

  Future<void> renameOrMergeCategory(String oldName, String newName) =>
      db.renameOrMergeCategory(oldName, newName);

  Future<void> deleteCategoryByName(String name) => db.deleteCategoryByName(name);

  Future<void> updateCategoryNoteByName(String name, String note) =>
      db.updateCategoryNoteByName(name, note);

  // ─────────────────────────────────────────────────────────────
  // URL ↔ Category 매핑
  // ─────────────────────────────────────────────────────────────
  Future<void> attach(int urlId, List<int> categoryIds) =>
      db.attachCategoriesToUrl(urlId, categoryIds);

  Future<void> replaceCategoriesForUrl(int urlId, List<int> categoryIds) =>
      db.replaceCategoriesForUrl(urlId, categoryIds);

  // ─────────────────────────────────────────────────────────────
  // 통계 / 목록 / 추천 (활성 카테고리: 링크가 1개 이상 연결)
  // ─────────────────────────────────────────────────────────────
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchCategoryStats() =>
      db.fetchCategoryStats();

  Future<List<String>> allActiveCategoryNames() => db.allCategoryNames();

  Future<List<Category>> suggestPrefixActive(String prefix, {int limit = 8}) =>
      db.suggestPrefix(prefix, limit: limit);

  // ─────────────────────────────────────────────────────────────
  // 가시성 규칙 기반 조회 (권장)
  // ─────────────────────────────────────────────────────────────
  Future<void> updateCategoryVisibleByName(String name, bool visible) =>
      db.updateCategoryVisibleByName(name, visible);

  /// 가시성 규칙을 통과한 링크만 반환
  Future<List<UrlItem>> fetchAllVisibleLinks() => db.fetchAllVisibleLinks();

  /// 가시성 통과 링크 기준 카테고리 통계
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchCategoryStatsFromVisibleLinks() =>
      db.fetchCategoryStatsFromVisibleLinks();

  /// 가시성 통과 링크에서 등장하는 visible 카테고리명
  Future<List<String>> allCategoryNamesFromVisibleLinks() =>
      db.allCategoryNamesFromVisibleLinks();

  /// 접두사 자동완성 (가시성 통과 링크 + visible=1 범위)
  Future<List<Category>> suggestPrefixFromVisibleLinks(
      String prefix, {
        int limit = 8,
      }) =>
      db.suggestPrefixVisible(prefix, limit: limit);

  // ─────────────────────────────────────────────────────────────
  // 관리화면 / 이전 버전 호환 헬퍼
  // ─────────────────────────────────────────────────────────────
  Future<List<({int id, String name, int linkCount, String? note, bool visible})>>
  fetchCategoryStatsWithVisible() =>
      db.fetchCategoryStatsWithVisible();

  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchVisibleCategoryStats() =>
      db.fetchVisibleCategoryStats();

  Future<List<String>> allVisibleCategoryNames() =>
      db.allVisibleCategoryNames();

  Future<Set<String>> visibleCategoryNameSet() async =>
      (await db.allVisibleCategoryNames()).toSet();

  /// 문자열 기반 접두사 추천 (가시성 필터링)
  Future<List<String>> suggestPrefixVisible(String prefix, {int limit = 8}) =>
      db.allVisibleCategoryNames()
          .then((names) => names
          .where((n) => n.startsWith(prefix.trim().toLowerCase()))
          .take(limit)
          .toList());
}
