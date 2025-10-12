// lib/data/local_db.dart
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

import 'package:everylink/domain/models.dart'; // UrlItem 도메인 모델

part 'local_db.g.dart';

/// -------------------------------
/// Drift Tables
/// -------------------------------
class Urls extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();   // 페이지 제목(OG/title)
  TextColumn get memo => text().nullable()();    // 사용자 메모 (v2 추가)
  DateTimeColumn get createdAt => dateTime()();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();               // 정규화된 카테고리명 (소문자/trim)
  IntColumn get usedCount => integer().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();    // 카테고리 메모 (v2 추가)

  /// ✅ v3: 표시 여부(기본 true)
  BoolColumn get visible => boolean().withDefault(const Constant(true))();
}

/// URL : Category = N:M
class UrlCategories extends Table {
  IntColumn get urlId => integer().references(Urls, #id)();
  IntColumn get categoryId => integer().references(Categories, #id)();

  @override
  Set<Column> get primaryKey => {urlId, categoryId};
}

/// -------------------------------
/// Open connection (Sqflite backend)
/// -------------------------------
LazyDatabase _openConnection() => LazyDatabase(() async {
  final dir = await getDatabasesPath();
  final file = p.join(dir, 'everylink.db');
  // drift_sqflite 2.x: 이름 있는 인자 사용 (path)
  return SqfliteQueryExecutor(
    path: file,
    logStatements: false,
  );
});

@DriftDatabase(tables: [Urls, Categories, UrlCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 스키마 버전
  /// v2: Urls.memo, Categories.note 추가
  /// v3: Categories.visible 추가
  @override
  int get schemaVersion => 3;

  /// 마이그레이션
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // 생성 직후 보정: NULL이면 1(true)로
      await customStatement('UPDATE categories SET visible = 1 WHERE visible IS NULL;');
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(urls, urls.memo);
        await m.addColumn(categories, categories.note);
      }
      if (from < 3) {
        // ✅ 제네릭 충돌 피하려고 SQL로 직접 추가
        await customStatement(
            'ALTER TABLE categories ADD COLUMN visible INTEGER NOT NULL DEFAULT 1;'
        );
        await customStatement('UPDATE categories SET visible = 1 WHERE visible IS NULL;');
      }
    },
  );

  // ------------------------------------------------------------
  // URL CRUD (+ title/memo)
  // ------------------------------------------------------------

  /// URL upsert (url로 고유성 가정). title/memo가 주어지면 갱신.
  Future<int> upsertUrl(String url, {String? title, String? memo}) async {
    final existing =
    await (select(urls)..where((u) => u.url.equals(url))).getSingleOrNull();

    if (existing != null) {
      final comp = UrlsCompanion(
        title: title != null ? Value(title) : const Value.absent(),
        memo: memo != null ? Value(memo) : const Value.absent(),
      );
      if (comp.title.present || comp.memo.present) {
        await (update(urls)..where((u) => u.id.equals(existing.id))).write(comp);
      }
      return existing.id;
    } else {
      return into(urls).insert(
        UrlsCompanion.insert(
          url: url,
          title: Value(title),
          memo: Value(memo),
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> updateCategoryVisibleByName(String name, bool visible) async {
    final n = name.trim().toLowerCase();
    final row =
    await (select(categories)..where((c) => c.name.equals(n))).getSingleOrNull();
    if (row == null) return;

    await (update(categories)..where((c) => c.id.equals(row.id))).write(
      CategoriesCompanion(visible: Value(visible)),
    );
  }

  Future<void> updateUrlHref(int urlId, String newUrl) async {
    await (update(urls)..where((u) => u.id.equals(urlId)))
        .write(UrlsCompanion(url: Value(newUrl)));
  }

  Future<void> updateUrlTitle(int urlId, String title) async {
    await (update(urls)..where((u) => u.id.equals(urlId)))
        .write(UrlsCompanion(title: Value(title)));
  }

  Future<void> updateUrlMemo(int urlId, String memo) async {
    await (update(urls)..where((u) => u.id.equals(urlId)))
        .write(UrlsCompanion(memo: Value(memo)));
  }

  /// URL 삭제 (연결 매핑 제거 + 고아 카테고리 정리)
  Future<void> deleteUrlCascade(int urlId) async {
    await transaction(() async {
      await (delete(urlCategories)..where((r) => r.urlId.equals(urlId))).go();
      await (delete(urls)..where((u) => u.id.equals(urlId))).go();
      await pruneOrphanCategories();
    });
  }

  // ------------------------------------------------------------
  // Category CRUD (+ note)
  // ------------------------------------------------------------

  /// 카테고리 upsert (name 기준)
  Future<int> upsertCategory(String name) async {
    final n = name.trim().toLowerCase();
    final existing =
    await (select(categories)..where((c) => c.name.equals(n))).getSingleOrNull();
    if (existing != null) {
      return existing.id;
    } else {
      return into(categories).insert(CategoriesCompanion.insert(name: n));
    }
  }

  /// 카테고리 이름 변경 or 병합
  Future<void> renameOrMergeCategory(String oldName, String newName) async {
    final oldN = oldName.trim().toLowerCase();
    final newN = newName.trim().toLowerCase();
    if (oldN.isEmpty || newN.isEmpty || oldN == newN) return;

    final oldRow =
    await (select(categories)..where((c) => c.name.equals(oldN))).getSingleOrNull();
    if (oldRow == null) return;

    final newRow =
    await (select(categories)..where((c) => c.name.equals(newN))).getSingleOrNull();

    if (newRow == null) {
      // 단순 이름 변경
      await (update(categories)..where((c) => c.id.equals(oldRow.id))).write(
        CategoriesCompanion(name: Value(newN)),
      );
    } else {
      // 병합: 매핑 이동 → 기존 삭제
      await customUpdate(
        'UPDATE url_categories SET category_id = ? WHERE category_id = ?',
        variables: [
          Variable<int>(newRow.id),
          Variable<int>(oldRow.id),
        ],
        updates: {urlCategories},
      );
      await (delete(categories)..where((c) => c.id.equals(oldRow.id))).go();
    }
  }

  Future<void> updateCategoryNoteByName(String name, String note) async {
    final n = name.trim().toLowerCase();
    final row =
    await (select(categories)..where((c) => c.name.equals(n))).getSingleOrNull();
    if (row == null) return;
    await (update(categories)..where((c) => c.id.equals(row.id))).write(
      CategoriesCompanion(note: Value(note)),
    );
  }

  Future<void> deleteCategoryByName(String name) async {
    final n = name.trim().toLowerCase();
    final row =
    await (select(categories)..where((c) => c.name.equals(n))).getSingleOrNull();
    if (row == null) return;

    await (delete(urlCategories)..where((uc) => uc.categoryId.equals(row.id))).go();
    await (delete(categories)..where((c) => c.id.equals(row.id))).go();
  }

  /// url_categories에 더 이상 매핑이 없는 카테고리 제거
  Future<int> pruneOrphanCategories() async {
    return customUpdate(
      '''
      DELETE FROM categories
      WHERE id NOT IN (SELECT DISTINCT category_id FROM url_categories)
      ''',
      updates: {categories},
    );
  }

  // ------------------------------------------------------------
  // URL <-> Category 매핑
  // ------------------------------------------------------------

  /// URL에 카테고리 부착 (중복 무시)
  Future<void> attachCategoriesToUrl(int urlId, List<int> categoryIds) async {
    if (categoryIds.isEmpty) return;
    await batch((b) {
      for (final cid in categoryIds) {
        b.insert(
          urlCategories,
          UrlCategoriesCompanion.insert(urlId: urlId, categoryId: cid),
          mode: InsertMode.insertOrIgnore, // 중복 매핑 무시
        );
      }
    });
  }

  /// URL의 카테고리들을 주어진 목록으로 '교체'
  Future<void> replaceCategoriesForUrl(int urlId, List<int> newCategoryIds) async {
    await transaction(() async {
      await (delete(urlCategories)..where((r) => r.urlId.equals(urlId))).go();
      if (newCategoryIds.isNotEmpty) {
        await batch((b) {
          for (final cid in newCategoryIds) {
            b.insert(
              urlCategories,
              UrlCategoriesCompanion.insert(urlId: urlId, categoryId: cid),
              mode: InsertMode.insertOrIgnore,
            );
          }
        });
      }
      await pruneOrphanCategories();
    });
  }

  // ------------------------------------------------------------
  // Helper methods
  // ------------------------------------------------------------

  /// DateTime 파싱 헬퍼 (중복 제거)
  DateTime _parseCreatedAt(dynamic rawCreated) {
    if (rawCreated is int) {
      if (rawCreated > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(rawCreated);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(rawCreated * 1000);
      }
    } else if (rawCreated is String) {
      return DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else if (rawCreated is DateTime) {
      return rawCreated;
    } else {
      return DateTime.now();
    }
  }

  // ------------------------------------------------------------
  // (이전) 일반 조회/검색/추천 — 필요시 유지
  // ------------------------------------------------------------

  /// 전체 URL + 연결된 카테고리 목록을 UrlItem으로 반환 (최근순)
  /// createdAt: INTEGER 저장단위(초/밀리초 모두) 안전 복원
  Future<List<UrlItem>> fetchAll() async {
    final rows = await customSelect(
      '''
      SELECT 
        u.id          AS id,
        u.url         AS url,
        u.title       AS title,
        u.memo        AS memo,
        u.created_at  AS createdAt,
        GROUP_CONCAT(c.name, ',') AS cats
      FROM urls u
      LEFT JOIN url_categories uc ON uc.url_id = u.id
      LEFT JOIN categories     c  ON c.id      = uc.category_id
      GROUP BY u.id, u.url, u.title, u.memo, u.created_at
      ORDER BY u.created_at DESC
      ''',
      readsFrom: {urls, urlCategories, categories},
    ).get();

    return rows.map((r) {
      final data = r.data;

      final catStr = (data['cats'] as String?) ?? '';
      final catList = catStr.isEmpty
          ? <String>[]
          : catStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      return UrlItem(
        id: (data['id'] as num).toInt(),
        url: data['url'] as String,
        title: data['title'] as String?,
        memo: data['memo'] as String?,
        createdAt: _parseCreatedAt(data['createdAt']),
        categories: catList,
      );
    }).toList();
  }

  /// (관리화면) 카테고리 통계: 숨김 포함, 0개 카테고리도 노출
  Future<List<({int id, String name, int linkCount, String? note, bool visible})>>
  fetchCategoryStatsWithVisible() async {
    final rows = await customSelect(
      '''
      SELECT 
        c.id        AS id,
        c.name      AS name,
        c.note      AS note,
        c.visible   AS visible,
        COUNT(uc.url_id) AS linkCount
      FROM categories c
      LEFT JOIN url_categories uc ON uc.category_id = c.id
      GROUP BY c.id, c.name, c.note, c.visible
      ORDER BY c.name ASC
      ''',
      readsFrom: {categories, urlCategories},
    ).get();

    return rows.map((r) => (
    id: r.read<int>('id'),
    name: r.read<String>('name'),
    linkCount: r.read<int>('linkCount'),
    note: r.readNullable<String>('note'),
    visible: (r.read<int>('visible')) != 0,
    )).toList();
  }

  /// (예전 방식) 보이는 카테고리만의 통계(링크가 있는 것만)
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchVisibleCategoryStats() async {
    final rows = await customSelect(
      '''
      SELECT 
        c.id   AS id,
        c.name AS name,
        c.note AS note,
        COUNT(uc.url_id) AS linkCount
      FROM categories c
      JOIN url_categories uc ON uc.category_id = c.id
      WHERE c.visible = 1
      GROUP BY c.id, c.name, c.note
      ORDER BY linkCount DESC, name ASC
      ''',
      readsFrom: {categories, urlCategories},
    ).get();

    return rows.map((r) {
      final d = r.data;
      return (
      id: (d['id'] as num).toInt(),
      name: d['name'] as String,
      linkCount: (d['linkCount'] as num).toInt(),
      note: d['note'] as String?,
      );
    }).toList();
  }

  // ------------------------------------------------------------
  // ✅ v3 핵심: '가시성 규칙을 통과한 링크' 기반 조회/추천
  // ------------------------------------------------------------

  /// ✅ 가시성 규칙을 만족하는 링크만 반환
  /// - 조건: 해당 URL에 연결된 카테고리 중 하나라도 invisible(false)이면 **그 링크 전체를 제외**
  /// - 표시용 카테고리는 visible=1 만 group_concat
  Future<List<UrlItem>> fetchAllVisibleLinks() async {
    final rows = await customSelect(
      '''
      WITH visible_links AS (
        SELECT u.id
        FROM urls u
        WHERE NOT EXISTS (
          SELECT 1
          FROM url_categories uc2
          JOIN categories c2 ON c2.id = uc2.category_id
          WHERE uc2.url_id = u.id AND c2.visible = 0
        )
      )
      SELECT 
        u.id          AS id,
        u.url         AS url,
        u.title       AS title,
        u.memo        AS memo,
        u.created_at  AS createdAt,
        GROUP_CONCAT(c.name, ',') AS cats
      FROM urls u
      JOIN visible_links vl ON vl.id = u.id
      LEFT JOIN url_categories uc ON uc.url_id = u.id
      LEFT JOIN categories     c  ON c.id      = uc.category_id AND c.visible = 1
      GROUP BY u.id, u.url, u.title, u.memo, u.created_at
      ORDER BY u.created_at DESC
      ''',
      readsFrom: {urls, urlCategories, categories},
    ).get();

    return rows.map((r) {
      final data = r.data;

      final catStr = (data['cats'] as String?) ?? '';
      final catList = catStr.isEmpty
          ? <String>[]
          : catStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      return UrlItem(
        id: (data['id'] as num).toInt(),
        url: data['url'] as String,
        title: data['title'] as String?,
        memo: data['memo'] as String?,
        createdAt: _parseCreatedAt(data['createdAt']),
        categories: catList,
      );
    }).toList();
  }

  /// ✅ '가시성 규칙을 통과한 링크'만 기준으로 카테고리 통계
  /// - 카테고리도 visible=1 인 것만
  /// - 링크 카운트는 "해당 링크가 가시성 규칙을 통과한 경우"에만 카운트
  Future<List<({int id, String name, int linkCount, String? note})>>
  fetchCategoryStatsFromVisibleLinks() async {
    final rows = await customSelect(
      '''
      WITH visible_links AS (
        SELECT u.id
        FROM urls u
        WHERE NOT EXISTS (
          SELECT 1
          FROM url_categories uc2
          JOIN categories c2 ON c2.id = uc2.category_id
          WHERE uc2.url_id = u.id AND c2.visible = 0
        )
      )
      SELECT 
        c.id   AS id,
        c.name AS name,
        c.note AS note,
        COUNT(DISTINCT uc.url_id) AS linkCount
      FROM categories c
      JOIN url_categories uc ON uc.category_id = c.id
      JOIN visible_links vl ON vl.id = uc.url_id
      WHERE c.visible = 1
      GROUP BY c.id, c.name, c.note
      ORDER BY linkCount DESC, name ASC
      ''',
      readsFrom: {categories, urlCategories, urls},
    ).get();

    return rows.map((r) {
      final d = r.data;
      return (
      id: (d['id'] as num).toInt(),
      name: d['name'] as String,
      linkCount: (d['linkCount'] as num).toInt(),
      note: d['note'] as String?,
      );
    }).toList();
  }

  /// 보이는 카테고리 이름(정렬)
  Future<List<String>> allVisibleCategoryNames() async {
    final rows = await customSelect( 'SELECT name FROM categories WHERE visible = 1 ORDER BY name ASC', readsFrom: {categories}, ).get(); return rows.map((r) => r.read<String>('name')).toList();
  }

  /// BK-tree 구축용 이름 리스트 (visible 관계없이 모두)
  Future<List<String>> allCategoryNames() async {
    final activeCatIds = selectOnly(urlCategories)
      ..addColumns([urlCategories.categoryId]);

    final rows = await (select(categories)
      ..where((c) => c.id.isInQuery(activeCatIds))
      ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();

    return rows.map((e) => e.name).toList(growable: false);
  }

  /// ✅ 추천/자동완성용: 가시성 규칙을 통과한 링크들에서 등장하는 'visible=1' 카테고리 이름
  Future<List<String>> allCategoryNamesFromVisibleLinks() async {
    final rows = await customSelect(
      '''
      WITH visible_links AS (
        SELECT u.id
        FROM urls u
        WHERE NOT EXISTS (
          SELECT 1
          FROM url_categories uc2
          JOIN categories c2 ON c2.id = uc2.category_id
          WHERE uc2.url_id = u.id AND c2.visible = 0
        )
      )
      SELECT DISTINCT c.name AS name
      FROM categories c
      JOIN url_categories uc ON uc.category_id = c.id
      JOIN visible_links vl ON vl.id = uc.url_id
      WHERE c.visible = 1
      ORDER BY c.name ASC
      ''',
      readsFrom: {categories, urlCategories, urls},
    ).get();

    return rows.map((e) => (e.data['name'] as String)).toList(growable: false);
  }

  /// 카테고리 사용 통계 (visible 관계없이 모두) - note 포함
  Future<List<({int id, String name, int linkCount, String? note})>> fetchCategoryStats() async {
    final rows = await customSelect( ''' SELECT c.id AS id, c.name AS name, c.note AS note, COUNT(uc.url_id) AS linkCount FROM categories c JOIN url_categories uc ON uc.category_id = c.id GROUP BY c.id, c.name, c.note ORDER BY linkCount DESC, name ASC ''',
      readsFrom: {categories, urlCategories}, ).get();
    return rows .map((r) {
      final d = r.data;
      return ( id: (d['id'] as num).toInt(), name: d['name'] as String, linkCount: (d['linkCount'] as num).toInt(), note: d['note'] as String?, );
    }).toList();
  }

  /// 접두사 자동완성(visible 관계없이 모두)
  Future<List<Category>> suggestPrefix(String prefix, {int limit = 8}) async {
    final q = prefix.trim().toLowerCase();
    if (q.isEmpty) return [];

    final activeCatIds = selectOnly(urlCategories)
      ..addColumns([urlCategories.categoryId]);

    return (select(categories)
      ..where((c) => c.name.like('$q%') & c.id.isInQuery(activeCatIds))
      ..orderBy([(c) => OrderingTerm.asc(c.name)])
      ..limit(limit))
        .get();
  }
  
  /// ✅ 접두사 자동완성(가시성 규칙을 통과한 링크들 범위 + visible=1)
  /// 반환: Category 행(리포지토리에서 그대로 노출 가능)
  Future<List<Category>> suggestPrefixVisible(String prefix, {int limit = 8}) async {
    final q = prefix.trim().toLowerCase();
    if (q.isEmpty) return [];

    return customSelect(
      '''
      WITH visible_links AS (
        SELECT u.id
        FROM urls u
        WHERE NOT EXISTS (
          SELECT 1
          FROM url_categories uc2
          JOIN categories c2 ON c2.id = uc2.category_id
          WHERE uc2.url_id = u.id AND c2.visible = 0
        )
      )
      SELECT c.*
      FROM categories c
      JOIN url_categories uc ON uc.category_id = c.id
      JOIN visible_links vl ON vl.id = uc.url_id
      WHERE c.visible = 1 AND c.name LIKE ?
      GROUP BY c.id
      ORDER BY c.name ASC
      LIMIT ?
      ''',
      variables: [Variable<String>('$q%'), Variable<int>(limit)],
      readsFrom: {categories, urlCategories, urls},
    ).map((row) => categories.map(row.data)).get();
  }
}
