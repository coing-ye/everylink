// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $UrlsTable extends Urls with TableInfo<$UrlsTable, Url> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UrlsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
      'memo', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, url, title, memo, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'urls';
  @override
  VerificationContext validateIntegrity(Insertable<Url> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('memo')) {
      context.handle(
          _memoMeta, memo.isAcceptableOrUnknown(data['memo']!, _memoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Url map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Url(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      memo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memo']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UrlsTable createAlias(String alias) {
    return $UrlsTable(attachedDatabase, alias);
  }
}

class Url extends DataClass implements Insertable<Url> {
  final int id;
  final String url;
  final String? title;
  final String? memo;
  final DateTime createdAt;
  const Url(
      {required this.id,
      required this.url,
      this.title,
      this.memo,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UrlsCompanion toCompanion(bool nullToAbsent) {
    return UrlsCompanion(
      id: Value(id),
      url: Value(url),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory Url.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Url(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String?>(title),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Url copyWith(
          {int? id,
          String? url,
          Value<String?> title = const Value.absent(),
          Value<String?> memo = const Value.absent(),
          DateTime? createdAt}) =>
      Url(
        id: id ?? this.id,
        url: url ?? this.url,
        title: title.present ? title.value : this.title,
        memo: memo.present ? memo.value : this.memo,
        createdAt: createdAt ?? this.createdAt,
      );
  Url copyWithCompanion(UrlsCompanion data) {
    return Url(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Url(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, title, memo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Url &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class UrlsCompanion extends UpdateCompanion<Url> {
  final Value<int> id;
  final Value<String> url;
  final Value<String?> title;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const UrlsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UrlsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    this.title = const Value.absent(),
    this.memo = const Value.absent(),
    required DateTime createdAt,
  })  : url = Value(url),
        createdAt = Value(createdAt);
  static Insertable<Url> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UrlsCompanion copyWith(
      {Value<int>? id,
      Value<String>? url,
      Value<String?>? title,
      Value<String?>? memo,
      Value<DateTime>? createdAt}) {
    return UrlsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UrlsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usedCountMeta =
      const VerificationMeta('usedCount');
  @override
  late final GeneratedColumn<int> usedCount = GeneratedColumn<int>(
      'used_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _visibleMeta =
      const VerificationMeta('visible');
  @override
  late final GeneratedColumn<bool> visible = GeneratedColumn<bool>(
      'visible', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("visible" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [id, name, usedCount, note, visible];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<Category> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('used_count')) {
      context.handle(_usedCountMeta,
          usedCount.isAcceptableOrUnknown(data['used_count']!, _usedCountMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('visible')) {
      context.handle(_visibleMeta,
          visible.isAcceptableOrUnknown(data['visible']!, _visibleMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      usedCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}used_count'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      visible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}visible'])!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final int usedCount;
  final String? note;

  /// ✅ v3: 표시 여부(기본 true)
  final bool visible;
  const Category(
      {required this.id,
      required this.name,
      required this.usedCount,
      this.note,
      required this.visible});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['used_count'] = Variable<int>(usedCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['visible'] = Variable<bool>(visible);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      usedCount: Value(usedCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      visible: Value(visible),
    );
  }

  factory Category.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      usedCount: serializer.fromJson<int>(json['usedCount']),
      note: serializer.fromJson<String?>(json['note']),
      visible: serializer.fromJson<bool>(json['visible']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'usedCount': serializer.toJson<int>(usedCount),
      'note': serializer.toJson<String?>(note),
      'visible': serializer.toJson<bool>(visible),
    };
  }

  Category copyWith(
          {int? id,
          String? name,
          int? usedCount,
          Value<String?> note = const Value.absent(),
          bool? visible}) =>
      Category(
        id: id ?? this.id,
        name: name ?? this.name,
        usedCount: usedCount ?? this.usedCount,
        note: note.present ? note.value : this.note,
        visible: visible ?? this.visible,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      usedCount: data.usedCount.present ? data.usedCount.value : this.usedCount,
      note: data.note.present ? data.note.value : this.note,
      visible: data.visible.present ? data.visible.value : this.visible,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('usedCount: $usedCount, ')
          ..write('note: $note, ')
          ..write('visible: $visible')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, usedCount, note, visible);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.usedCount == this.usedCount &&
          other.note == this.note &&
          other.visible == this.visible);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> usedCount;
  final Value<String?> note;
  final Value<bool> visible;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.usedCount = const Value.absent(),
    this.note = const Value.absent(),
    this.visible = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.usedCount = const Value.absent(),
    this.note = const Value.absent(),
    this.visible = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? usedCount,
    Expression<String>? note,
    Expression<bool>? visible,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (usedCount != null) 'used_count': usedCount,
      if (note != null) 'note': note,
      if (visible != null) 'visible': visible,
    });
  }

  CategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? usedCount,
      Value<String?>? note,
      Value<bool>? visible}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      usedCount: usedCount ?? this.usedCount,
      note: note ?? this.note,
      visible: visible ?? this.visible,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (usedCount.present) {
      map['used_count'] = Variable<int>(usedCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (visible.present) {
      map['visible'] = Variable<bool>(visible.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('usedCount: $usedCount, ')
          ..write('note: $note, ')
          ..write('visible: $visible')
          ..write(')'))
        .toString();
  }
}

class $UrlCategoriesTable extends UrlCategories
    with TableInfo<$UrlCategoriesTable, UrlCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UrlCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlIdMeta = const VerificationMeta('urlId');
  @override
  late final GeneratedColumn<int> urlId = GeneratedColumn<int>(
      'url_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES urls (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  @override
  List<GeneratedColumn> get $columns => [urlId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'url_categories';
  @override
  VerificationContext validateIntegrity(Insertable<UrlCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url_id')) {
      context.handle(
          _urlIdMeta, urlId.isAcceptableOrUnknown(data['url_id']!, _urlIdMeta));
    } else if (isInserting) {
      context.missing(_urlIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {urlId, categoryId};
  @override
  UrlCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UrlCategory(
      urlId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}url_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
    );
  }

  @override
  $UrlCategoriesTable createAlias(String alias) {
    return $UrlCategoriesTable(attachedDatabase, alias);
  }
}

class UrlCategory extends DataClass implements Insertable<UrlCategory> {
  final int urlId;
  final int categoryId;
  const UrlCategory({required this.urlId, required this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url_id'] = Variable<int>(urlId);
    map['category_id'] = Variable<int>(categoryId);
    return map;
  }

  UrlCategoriesCompanion toCompanion(bool nullToAbsent) {
    return UrlCategoriesCompanion(
      urlId: Value(urlId),
      categoryId: Value(categoryId),
    );
  }

  factory UrlCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UrlCategory(
      urlId: serializer.fromJson<int>(json['urlId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'urlId': serializer.toJson<int>(urlId),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  UrlCategory copyWith({int? urlId, int? categoryId}) => UrlCategory(
        urlId: urlId ?? this.urlId,
        categoryId: categoryId ?? this.categoryId,
      );
  UrlCategory copyWithCompanion(UrlCategoriesCompanion data) {
    return UrlCategory(
      urlId: data.urlId.present ? data.urlId.value : this.urlId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UrlCategory(')
          ..write('urlId: $urlId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(urlId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UrlCategory &&
          other.urlId == this.urlId &&
          other.categoryId == this.categoryId);
}

class UrlCategoriesCompanion extends UpdateCompanion<UrlCategory> {
  final Value<int> urlId;
  final Value<int> categoryId;
  final Value<int> rowid;
  const UrlCategoriesCompanion({
    this.urlId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UrlCategoriesCompanion.insert({
    required int urlId,
    required int categoryId,
    this.rowid = const Value.absent(),
  })  : urlId = Value(urlId),
        categoryId = Value(categoryId);
  static Insertable<UrlCategory> custom({
    Expression<int>? urlId,
    Expression<int>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (urlId != null) 'url_id': urlId,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UrlCategoriesCompanion copyWith(
      {Value<int>? urlId, Value<int>? categoryId, Value<int>? rowid}) {
    return UrlCategoriesCompanion(
      urlId: urlId ?? this.urlId,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (urlId.present) {
      map['url_id'] = Variable<int>(urlId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UrlCategoriesCompanion(')
          ..write('urlId: $urlId, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UrlsTable urls = $UrlsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $UrlCategoriesTable urlCategories = $UrlCategoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [urls, categories, urlCategories];
}

typedef $$UrlsTableCreateCompanionBuilder = UrlsCompanion Function({
  Value<int> id,
  required String url,
  Value<String?> title,
  Value<String?> memo,
  required DateTime createdAt,
});
typedef $$UrlsTableUpdateCompanionBuilder = UrlsCompanion Function({
  Value<int> id,
  Value<String> url,
  Value<String?> title,
  Value<String?> memo,
  Value<DateTime> createdAt,
});

final class $$UrlsTableReferences
    extends BaseReferences<_$AppDatabase, $UrlsTable, Url> {
  $$UrlsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UrlCategoriesTable, List<UrlCategory>>
      _urlCategoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.urlCategories,
              aliasName:
                  $_aliasNameGenerator(db.urls.id, db.urlCategories.urlId));

  $$UrlCategoriesTableProcessedTableManager get urlCategoriesRefs {
    final manager = $$UrlCategoriesTableTableManager($_db, $_db.urlCategories)
        .filter((f) => f.urlId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_urlCategoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UrlsTableFilterComposer extends Composer<_$AppDatabase, $UrlsTable> {
  $$UrlsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> urlCategoriesRefs(
      Expression<bool> Function($$UrlCategoriesTableFilterComposer f) f) {
    final $$UrlCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.urlCategories,
        getReferencedColumn: (t) => t.urlId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.urlCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UrlsTableOrderingComposer extends Composer<_$AppDatabase, $UrlsTable> {
  $$UrlsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memo => $composableBuilder(
      column: $table.memo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UrlsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UrlsTable> {
  $$UrlsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> urlCategoriesRefs<T extends Object>(
      Expression<T> Function($$UrlCategoriesTableAnnotationComposer a) f) {
    final $$UrlCategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.urlCategories,
        getReferencedColumn: (t) => t.urlId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlCategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.urlCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UrlsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UrlsTable,
    Url,
    $$UrlsTableFilterComposer,
    $$UrlsTableOrderingComposer,
    $$UrlsTableAnnotationComposer,
    $$UrlsTableCreateCompanionBuilder,
    $$UrlsTableUpdateCompanionBuilder,
    (Url, $$UrlsTableReferences),
    Url,
    PrefetchHooks Function({bool urlCategoriesRefs})> {
  $$UrlsTableTableManager(_$AppDatabase db, $UrlsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UrlsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UrlsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UrlsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UrlsCompanion(
            id: id,
            url: url,
            title: title,
            memo: memo,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String url,
            Value<String?> title = const Value.absent(),
            Value<String?> memo = const Value.absent(),
            required DateTime createdAt,
          }) =>
              UrlsCompanion.insert(
            id: id,
            url: url,
            title: title,
            memo: memo,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UrlsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({urlCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (urlCategoriesRefs) db.urlCategories
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (urlCategoriesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$UrlsTableReferences._urlCategoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UrlsTableReferences(db, table, p0)
                                .urlCategoriesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.urlId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UrlsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UrlsTable,
    Url,
    $$UrlsTableFilterComposer,
    $$UrlsTableOrderingComposer,
    $$UrlsTableAnnotationComposer,
    $$UrlsTableCreateCompanionBuilder,
    $$UrlsTableUpdateCompanionBuilder,
    (Url, $$UrlsTableReferences),
    Url,
    PrefetchHooks Function({bool urlCategoriesRefs})>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  Value<int> usedCount,
  Value<String?> note,
  Value<bool> visible,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> usedCount,
  Value<String?> note,
  Value<bool> visible,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UrlCategoriesTable, List<UrlCategory>>
      _urlCategoriesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.urlCategories,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.urlCategories.categoryId));

  $$UrlCategoriesTableProcessedTableManager get urlCategoriesRefs {
    final manager = $$UrlCategoriesTableTableManager($_db, $_db.urlCategories)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_urlCategoriesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get usedCount => $composableBuilder(
      column: $table.usedCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get visible => $composableBuilder(
      column: $table.visible, builder: (column) => ColumnFilters(column));

  Expression<bool> urlCategoriesRefs(
      Expression<bool> Function($$UrlCategoriesTableFilterComposer f) f) {
    final $$UrlCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.urlCategories,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.urlCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get usedCount => $composableBuilder(
      column: $table.usedCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get visible => $composableBuilder(
      column: $table.visible, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get usedCount =>
      $composableBuilder(column: $table.usedCount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get visible =>
      $composableBuilder(column: $table.visible, builder: (column) => column);

  Expression<T> urlCategoriesRefs<T extends Object>(
      Expression<T> Function($$UrlCategoriesTableAnnotationComposer a) f) {
    final $$UrlCategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.urlCategories,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlCategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.urlCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool urlCategoriesRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> usedCount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> visible = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            usedCount: usedCount,
            note: note,
            visible: visible,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> usedCount = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> visible = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            usedCount: usedCount,
            note: note,
            visible: visible,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({urlCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (urlCategoriesRefs) db.urlCategories
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (urlCategoriesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._urlCategoriesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .urlCategoriesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    Category,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (Category, $$CategoriesTableReferences),
    Category,
    PrefetchHooks Function({bool urlCategoriesRefs})>;
typedef $$UrlCategoriesTableCreateCompanionBuilder = UrlCategoriesCompanion
    Function({
  required int urlId,
  required int categoryId,
  Value<int> rowid,
});
typedef $$UrlCategoriesTableUpdateCompanionBuilder = UrlCategoriesCompanion
    Function({
  Value<int> urlId,
  Value<int> categoryId,
  Value<int> rowid,
});

final class $$UrlCategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $UrlCategoriesTable, UrlCategory> {
  $$UrlCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $UrlsTable _urlIdTable(_$AppDatabase db) => db.urls
      .createAlias($_aliasNameGenerator(db.urlCategories.urlId, db.urls.id));

  $$UrlsTableProcessedTableManager get urlId {
    final manager = $$UrlsTableTableManager($_db, $_db.urls)
        .filter((f) => f.id($_item.urlId));
    final item = $_typedResult.readTableOrNull(_urlIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.urlCategories.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UrlCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $UrlCategoriesTable> {
  $$UrlCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UrlsTableFilterComposer get urlId {
    final $$UrlsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.urlId,
        referencedTable: $db.urls,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlsTableFilterComposer(
              $db: $db,
              $table: $db.urls,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UrlCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UrlCategoriesTable> {
  $$UrlCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UrlsTableOrderingComposer get urlId {
    final $$UrlsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.urlId,
        referencedTable: $db.urls,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlsTableOrderingComposer(
              $db: $db,
              $table: $db.urls,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UrlCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UrlCategoriesTable> {
  $$UrlCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UrlsTableAnnotationComposer get urlId {
    final $$UrlsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.urlId,
        referencedTable: $db.urls,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UrlsTableAnnotationComposer(
              $db: $db,
              $table: $db.urls,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UrlCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UrlCategoriesTable,
    UrlCategory,
    $$UrlCategoriesTableFilterComposer,
    $$UrlCategoriesTableOrderingComposer,
    $$UrlCategoriesTableAnnotationComposer,
    $$UrlCategoriesTableCreateCompanionBuilder,
    $$UrlCategoriesTableUpdateCompanionBuilder,
    (UrlCategory, $$UrlCategoriesTableReferences),
    UrlCategory,
    PrefetchHooks Function({bool urlId, bool categoryId})> {
  $$UrlCategoriesTableTableManager(_$AppDatabase db, $UrlCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UrlCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UrlCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UrlCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> urlId = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UrlCategoriesCompanion(
            urlId: urlId,
            categoryId: categoryId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int urlId,
            required int categoryId,
            Value<int> rowid = const Value.absent(),
          }) =>
              UrlCategoriesCompanion.insert(
            urlId: urlId,
            categoryId: categoryId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UrlCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({urlId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (urlId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.urlId,
                    referencedTable:
                        $$UrlCategoriesTableReferences._urlIdTable(db),
                    referencedColumn:
                        $$UrlCategoriesTableReferences._urlIdTable(db).id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$UrlCategoriesTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$UrlCategoriesTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UrlCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UrlCategoriesTable,
    UrlCategory,
    $$UrlCategoriesTableFilterComposer,
    $$UrlCategoriesTableOrderingComposer,
    $$UrlCategoriesTableAnnotationComposer,
    $$UrlCategoriesTableCreateCompanionBuilder,
    $$UrlCategoriesTableUpdateCompanionBuilder,
    (UrlCategory, $$UrlCategoriesTableReferences),
    UrlCategory,
    PrefetchHooks Function({bool urlId, bool categoryId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UrlsTableTableManager get urls => $$UrlsTableTableManager(_db, _db.urls);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$UrlCategoriesTableTableManager get urlCategories =>
      $$UrlCategoriesTableTableManager(_db, _db.urlCategories);
}
