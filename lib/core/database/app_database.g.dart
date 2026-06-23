// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PhotosTableTable extends PhotosTable
    with TableInfo<$PhotosTableTable, PhotoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isTrashMeta = const VerificationMeta(
    'isTrash',
  );
  @override
  late final GeneratedColumn<bool> isTrash = GeneratedColumn<bool>(
    'is_trash',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trash" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    thumbnailPath,
    rating,
    isFavorite,
    isTrash,
    createdAt,
    keywords,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_trash')) {
      context.handle(
        _isTrashMeta,
        isTrash.isAcceptableOrUnknown(data['is_trash']!, _isTrashMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isTrash: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trash'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      ),
    );
  }

  @override
  $PhotosTableTable createAlias(String alias) {
    return $PhotosTableTable(attachedDatabase, alias);
  }
}

class PhotoData extends DataClass implements Insertable<PhotoData> {
  final String id;
  final String path;
  final String? thumbnailPath;
  final int rating;
  final bool isFavorite;
  final bool isTrash;
  final DateTime createdAt;
  final String? keywords;
  const PhotoData({
    required this.id,
    required this.path,
    this.thumbnailPath,
    required this.rating,
    required this.isFavorite,
    required this.isTrash,
    required this.createdAt,
    this.keywords,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    map['rating'] = Variable<int>(rating);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_trash'] = Variable<bool>(isTrash);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || keywords != null) {
      map['keywords'] = Variable<String>(keywords);
    }
    return map;
  }

  PhotosTableCompanion toCompanion(bool nullToAbsent) {
    return PhotosTableCompanion(
      id: Value(id),
      path: Value(path),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      rating: Value(rating),
      isFavorite: Value(isFavorite),
      isTrash: Value(isTrash),
      createdAt: Value(createdAt),
      keywords: keywords == null && nullToAbsent
          ? const Value.absent()
          : Value(keywords),
    );
  }

  factory PhotoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoData(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      rating: serializer.fromJson<int>(json['rating']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isTrash: serializer.fromJson<bool>(json['isTrash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      keywords: serializer.fromJson<String?>(json['keywords']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'rating': serializer.toJson<int>(rating),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isTrash': serializer.toJson<bool>(isTrash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'keywords': serializer.toJson<String?>(keywords),
    };
  }

  PhotoData copyWith({
    String? id,
    String? path,
    Value<String?> thumbnailPath = const Value.absent(),
    int? rating,
    bool? isFavorite,
    bool? isTrash,
    DateTime? createdAt,
    Value<String?> keywords = const Value.absent(),
  }) => PhotoData(
    id: id ?? this.id,
    path: path ?? this.path,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    rating: rating ?? this.rating,
    isFavorite: isFavorite ?? this.isFavorite,
    isTrash: isTrash ?? this.isTrash,
    createdAt: createdAt ?? this.createdAt,
    keywords: keywords.present ? keywords.value : this.keywords,
  );
  PhotoData copyWithCompanion(PhotosTableCompanion data) {
    return PhotoData(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      rating: data.rating.present ? data.rating.value : this.rating,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isTrash: data.isTrash.present ? data.isTrash.value : this.isTrash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoData(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rating: $rating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isTrash: $isTrash, ')
          ..write('createdAt: $createdAt, ')
          ..write('keywords: $keywords')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    thumbnailPath,
    rating,
    isFavorite,
    isTrash,
    createdAt,
    keywords,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoData &&
          other.id == this.id &&
          other.path == this.path &&
          other.thumbnailPath == this.thumbnailPath &&
          other.rating == this.rating &&
          other.isFavorite == this.isFavorite &&
          other.isTrash == this.isTrash &&
          other.createdAt == this.createdAt &&
          other.keywords == this.keywords);
}

class PhotosTableCompanion extends UpdateCompanion<PhotoData> {
  final Value<String> id;
  final Value<String> path;
  final Value<String?> thumbnailPath;
  final Value<int> rating;
  final Value<bool> isFavorite;
  final Value<bool> isTrash;
  final Value<DateTime> createdAt;
  final Value<String?> keywords;
  final Value<int> rowid;
  const PhotosTableCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isTrash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.keywords = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosTableCompanion.insert({
    required String id,
    required String path,
    this.thumbnailPath = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isTrash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.keywords = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       path = Value(path);
  static Insertable<PhotoData> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<String>? thumbnailPath,
    Expression<int>? rating,
    Expression<bool>? isFavorite,
    Expression<bool>? isTrash,
    Expression<DateTime>? createdAt,
    Expression<String>? keywords,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rating != null) 'rating': rating,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isTrash != null) 'is_trash': isTrash,
      if (createdAt != null) 'created_at': createdAt,
      if (keywords != null) 'keywords': keywords,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<String?>? thumbnailPath,
    Value<int>? rating,
    Value<bool>? isFavorite,
    Value<bool>? isTrash,
    Value<DateTime>? createdAt,
    Value<String?>? keywords,
    Value<int>? rowid,
  }) {
    return PhotosTableCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      isTrash: isTrash ?? this.isTrash,
      createdAt: createdAt ?? this.createdAt,
      keywords: keywords ?? this.keywords,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isTrash.present) {
      map['is_trash'] = Variable<bool>(isTrash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosTableCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rating: $rating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isTrash: $isTrash, ')
          ..write('createdAt: $createdAt, ')
          ..write('keywords: $keywords, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTableTable extends AlbumsTable
    with TableInfo<$AlbumsTableTable, AlbumData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'albums_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlbumData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AlbumsTableTable createAlias(String alias) {
    return $AlbumsTableTable(attachedDatabase, alias);
  }
}

class AlbumData extends DataClass implements Insertable<AlbumData> {
  final String id;
  final String name;
  final DateTime createdAt;
  const AlbumData({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AlbumsTableCompanion toCompanion(bool nullToAbsent) {
    return AlbumsTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory AlbumData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AlbumData copyWith({String? id, String? name, DateTime? createdAt}) =>
      AlbumData(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  AlbumData copyWithCompanion(AlbumsTableCompanion data) {
    return AlbumData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class AlbumsTableCompanion extends UpdateCompanion<AlbumData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AlbumsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumsTableCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<AlbumData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AlbumsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlbumPhotosTableTable extends AlbumPhotosTable
    with TableInfo<$AlbumPhotosTableTable, AlbumPhotoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlbumPhotosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _albumIdMeta = const VerificationMeta(
    'albumId',
  );
  @override
  late final GeneratedColumn<String> albumId = GeneratedColumn<String>(
    'album_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES albums_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES photos_table (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [albumId, photoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'album_photos_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlbumPhotoData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('album_id')) {
      context.handle(
        _albumIdMeta,
        albumId.isAcceptableOrUnknown(data['album_id']!, _albumIdMeta),
      );
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_photoIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {albumId, photoId};
  @override
  AlbumPhotoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlbumPhotoData(
      albumId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_id'],
      )!,
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      )!,
    );
  }

  @override
  $AlbumPhotosTableTable createAlias(String alias) {
    return $AlbumPhotosTableTable(attachedDatabase, alias);
  }
}

class AlbumPhotoData extends DataClass implements Insertable<AlbumPhotoData> {
  final String albumId;
  final String photoId;
  const AlbumPhotoData({required this.albumId, required this.photoId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['album_id'] = Variable<String>(albumId);
    map['photo_id'] = Variable<String>(photoId);
    return map;
  }

  AlbumPhotosTableCompanion toCompanion(bool nullToAbsent) {
    return AlbumPhotosTableCompanion(
      albumId: Value(albumId),
      photoId: Value(photoId),
    );
  }

  factory AlbumPhotoData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlbumPhotoData(
      albumId: serializer.fromJson<String>(json['albumId']),
      photoId: serializer.fromJson<String>(json['photoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'albumId': serializer.toJson<String>(albumId),
      'photoId': serializer.toJson<String>(photoId),
    };
  }

  AlbumPhotoData copyWith({String? albumId, String? photoId}) => AlbumPhotoData(
    albumId: albumId ?? this.albumId,
    photoId: photoId ?? this.photoId,
  );
  AlbumPhotoData copyWithCompanion(AlbumPhotosTableCompanion data) {
    return AlbumPhotoData(
      albumId: data.albumId.present ? data.albumId.value : this.albumId,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlbumPhotoData(')
          ..write('albumId: $albumId, ')
          ..write('photoId: $photoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(albumId, photoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlbumPhotoData &&
          other.albumId == this.albumId &&
          other.photoId == this.photoId);
}

class AlbumPhotosTableCompanion extends UpdateCompanion<AlbumPhotoData> {
  final Value<String> albumId;
  final Value<String> photoId;
  final Value<int> rowid;
  const AlbumPhotosTableCompanion({
    this.albumId = const Value.absent(),
    this.photoId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlbumPhotosTableCompanion.insert({
    required String albumId,
    required String photoId,
    this.rowid = const Value.absent(),
  }) : albumId = Value(albumId),
       photoId = Value(photoId);
  static Insertable<AlbumPhotoData> custom({
    Expression<String>? albumId,
    Expression<String>? photoId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (albumId != null) 'album_id': albumId,
      if (photoId != null) 'photo_id': photoId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlbumPhotosTableCompanion copyWith({
    Value<String>? albumId,
    Value<String>? photoId,
    Value<int>? rowid,
  }) {
    return AlbumPhotosTableCompanion(
      albumId: albumId ?? this.albumId,
      photoId: photoId ?? this.photoId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (albumId.present) {
      map['album_id'] = Variable<String>(albumId.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumPhotosTableCompanion(')
          ..write('albumId: $albumId, ')
          ..write('photoId: $photoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PresetsTableTable extends PresetsTable
    with TableInfo<$PresetsTableTable, PresetData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parametersJsonMeta = const VerificationMeta(
    'parametersJson',
  );
  @override
  late final GeneratedColumn<String> parametersJson = GeneratedColumn<String>(
    'parameters_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta(
    'isBookmarked',
  );
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bookmarked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    parametersJson,
    isBookmarked,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presets_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PresetData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('parameters_json')) {
      context.handle(
        _parametersJsonMeta,
        parametersJson.isAcceptableOrUnknown(
          data['parameters_json']!,
          _parametersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parametersJsonMeta);
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(
          data['is_bookmarked']!,
          _isBookmarkedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PresetData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresetData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      parametersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parameters_json'],
      )!,
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PresetsTableTable createAlias(String alias) {
    return $PresetsTableTable(attachedDatabase, alias);
  }
}

class PresetData extends DataClass implements Insertable<PresetData> {
  final String id;
  final String name;
  final String category;
  final String parametersJson;
  final bool isBookmarked;
  final DateTime createdAt;
  const PresetData({
    required this.id,
    required this.name,
    required this.category,
    required this.parametersJson,
    required this.isBookmarked,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['parameters_json'] = Variable<String>(parametersJson);
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PresetsTableCompanion toCompanion(bool nullToAbsent) {
    return PresetsTableCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      parametersJson: Value(parametersJson),
      isBookmarked: Value(isBookmarked),
      createdAt: Value(createdAt),
    );
  }

  factory PresetData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresetData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      parametersJson: serializer.fromJson<String>(json['parametersJson']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'parametersJson': serializer.toJson<String>(parametersJson),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PresetData copyWith({
    String? id,
    String? name,
    String? category,
    String? parametersJson,
    bool? isBookmarked,
    DateTime? createdAt,
  }) => PresetData(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    parametersJson: parametersJson ?? this.parametersJson,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    createdAt: createdAt ?? this.createdAt,
  );
  PresetData copyWithCompanion(PresetsTableCompanion data) {
    return PresetData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      parametersJson: data.parametersJson.present
          ? data.parametersJson.value
          : this.parametersJson,
      isBookmarked: data.isBookmarked.present
          ? data.isBookmarked.value
          : this.isBookmarked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresetData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, parametersJson, isBookmarked, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresetData &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.parametersJson == this.parametersJson &&
          other.isBookmarked == this.isBookmarked &&
          other.createdAt == this.createdAt);
}

class PresetsTableCompanion extends UpdateCompanion<PresetData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> parametersJson;
  final Value<bool> isBookmarked;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PresetsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.parametersJson = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PresetsTableCompanion.insert({
    required String id,
    required String name,
    required String category,
    required String parametersJson,
    this.isBookmarked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       parametersJson = Value(parametersJson);
  static Insertable<PresetData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? parametersJson,
    Expression<bool>? isBookmarked,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (parametersJson != null) 'parameters_json': parametersJson,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PresetsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String>? parametersJson,
    Value<bool>? isBookmarked,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PresetsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      parametersJson: parametersJson ?? this.parametersJson,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (parametersJson.present) {
      map['parameters_json'] = Variable<String>(parametersJson.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresetsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('parametersJson: $parametersJson, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PhotosTableTable photosTable = $PhotosTableTable(this);
  late final $AlbumsTableTable albumsTable = $AlbumsTableTable(this);
  late final $AlbumPhotosTableTable albumPhotosTable = $AlbumPhotosTableTable(
    this,
  );
  late final $PresetsTableTable presetsTable = $PresetsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    photosTable,
    albumsTable,
    albumPhotosTable,
    presetsTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'albums_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('album_photos_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'photos_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('album_photos_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PhotosTableTableCreateCompanionBuilder =
    PhotosTableCompanion Function({
      required String id,
      required String path,
      Value<String?> thumbnailPath,
      Value<int> rating,
      Value<bool> isFavorite,
      Value<bool> isTrash,
      Value<DateTime> createdAt,
      Value<String?> keywords,
      Value<int> rowid,
    });
typedef $$PhotosTableTableUpdateCompanionBuilder =
    PhotosTableCompanion Function({
      Value<String> id,
      Value<String> path,
      Value<String?> thumbnailPath,
      Value<int> rating,
      Value<bool> isFavorite,
      Value<bool> isTrash,
      Value<DateTime> createdAt,
      Value<String?> keywords,
      Value<int> rowid,
    });

final class $$PhotosTableTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTableTable, PhotoData> {
  $$PhotosTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlbumPhotosTableTable, List<AlbumPhotoData>>
  _albumPhotosTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.albumPhotosTable,
    aliasName: $_aliasNameGenerator(
      db.photosTable.id,
      db.albumPhotosTable.photoId,
    ),
  );

  $$AlbumPhotosTableTableProcessedTableManager get albumPhotosTableRefs {
    final manager = $$AlbumPhotosTableTableTableManager(
      $_db,
      $_db.albumPhotosTable,
    ).filter((f) => f.photoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _albumPhotosTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhotosTableTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTableTable> {
  $$PhotosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrash => $composableBuilder(
    column: $table.isTrash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> albumPhotosTableRefs(
    Expression<bool> Function($$AlbumPhotosTableTableFilterComposer f) f,
  ) {
    final $$AlbumPhotosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumPhotosTable,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumPhotosTableTableFilterComposer(
            $db: $db,
            $table: $db.albumPhotosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhotosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTableTable> {
  $$PhotosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrash => $composableBuilder(
    column: $table.isTrash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTableTable> {
  $$PhotosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTrash =>
      $composableBuilder(column: $table.isTrash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  Expression<T> albumPhotosTableRefs<T extends Object>(
    Expression<T> Function($$AlbumPhotosTableTableAnnotationComposer a) f,
  ) {
    final $$AlbumPhotosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumPhotosTable,
      getReferencedColumn: (t) => t.photoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumPhotosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.albumPhotosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhotosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTableTable,
          PhotoData,
          $$PhotosTableTableFilterComposer,
          $$PhotosTableTableOrderingComposer,
          $$PhotosTableTableAnnotationComposer,
          $$PhotosTableTableCreateCompanionBuilder,
          $$PhotosTableTableUpdateCompanionBuilder,
          (PhotoData, $$PhotosTableTableReferences),
          PhotoData,
          PrefetchHooks Function({bool albumPhotosTableRefs})
        > {
  $$PhotosTableTableTableManager(_$AppDatabase db, $PhotosTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isTrash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosTableCompanion(
                id: id,
                path: path,
                thumbnailPath: thumbnailPath,
                rating: rating,
                isFavorite: isFavorite,
                isTrash: isTrash,
                createdAt: createdAt,
                keywords: keywords,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String path,
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isTrash = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosTableCompanion.insert(
                id: id,
                path: path,
                thumbnailPath: thumbnailPath,
                rating: rating,
                isFavorite: isFavorite,
                isTrash: isTrash,
                createdAt: createdAt,
                keywords: keywords,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PhotosTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumPhotosTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (albumPhotosTableRefs) db.albumPhotosTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (albumPhotosTableRefs)
                    await $_getPrefetchedData<
                      PhotoData,
                      $PhotosTableTable,
                      AlbumPhotoData
                    >(
                      currentTable: table,
                      referencedTable: $$PhotosTableTableReferences
                          ._albumPhotosTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PhotosTableTableReferences(
                            db,
                            table,
                            p0,
                          ).albumPhotosTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.photoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PhotosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTableTable,
      PhotoData,
      $$PhotosTableTableFilterComposer,
      $$PhotosTableTableOrderingComposer,
      $$PhotosTableTableAnnotationComposer,
      $$PhotosTableTableCreateCompanionBuilder,
      $$PhotosTableTableUpdateCompanionBuilder,
      (PhotoData, $$PhotosTableTableReferences),
      PhotoData,
      PrefetchHooks Function({bool albumPhotosTableRefs})
    >;
typedef $$AlbumsTableTableCreateCompanionBuilder =
    AlbumsTableCompanion Function({
      required String id,
      required String name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AlbumsTableTableUpdateCompanionBuilder =
    AlbumsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AlbumsTableTableReferences
    extends BaseReferences<_$AppDatabase, $AlbumsTableTable, AlbumData> {
  $$AlbumsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlbumPhotosTableTable, List<AlbumPhotoData>>
  _albumPhotosTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.albumPhotosTable,
    aliasName: $_aliasNameGenerator(
      db.albumsTable.id,
      db.albumPhotosTable.albumId,
    ),
  );

  $$AlbumPhotosTableTableProcessedTableManager get albumPhotosTableRefs {
    final manager = $$AlbumPhotosTableTableTableManager(
      $_db,
      $_db.albumPhotosTable,
    ).filter((f) => f.albumId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _albumPhotosTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AlbumsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> albumPhotosTableRefs(
    Expression<bool> Function($$AlbumPhotosTableTableFilterComposer f) f,
  ) {
    final $$AlbumPhotosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumPhotosTable,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumPhotosTableTableFilterComposer(
            $db: $db,
            $table: $db.albumPhotosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlbumsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumsTableTable> {
  $$AlbumsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> albumPhotosTableRefs<T extends Object>(
    Expression<T> Function($$AlbumPhotosTableTableAnnotationComposer a) f,
  ) {
    final $$AlbumPhotosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.albumPhotosTable,
      getReferencedColumn: (t) => t.albumId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumPhotosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.albumPhotosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AlbumsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumsTableTable,
          AlbumData,
          $$AlbumsTableTableFilterComposer,
          $$AlbumsTableTableOrderingComposer,
          $$AlbumsTableTableAnnotationComposer,
          $$AlbumsTableTableCreateCompanionBuilder,
          $$AlbumsTableTableUpdateCompanionBuilder,
          (AlbumData, $$AlbumsTableTableReferences),
          AlbumData,
          PrefetchHooks Function({bool albumPhotosTableRefs})
        > {
  $$AlbumsTableTableTableManager(_$AppDatabase db, $AlbumsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumsTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlbumsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumPhotosTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (albumPhotosTableRefs) db.albumPhotosTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (albumPhotosTableRefs)
                    await $_getPrefetchedData<
                      AlbumData,
                      $AlbumsTableTable,
                      AlbumPhotoData
                    >(
                      currentTable: table,
                      referencedTable: $$AlbumsTableTableReferences
                          ._albumPhotosTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AlbumsTableTableReferences(
                            db,
                            table,
                            p0,
                          ).albumPhotosTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.albumId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AlbumsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumsTableTable,
      AlbumData,
      $$AlbumsTableTableFilterComposer,
      $$AlbumsTableTableOrderingComposer,
      $$AlbumsTableTableAnnotationComposer,
      $$AlbumsTableTableCreateCompanionBuilder,
      $$AlbumsTableTableUpdateCompanionBuilder,
      (AlbumData, $$AlbumsTableTableReferences),
      AlbumData,
      PrefetchHooks Function({bool albumPhotosTableRefs})
    >;
typedef $$AlbumPhotosTableTableCreateCompanionBuilder =
    AlbumPhotosTableCompanion Function({
      required String albumId,
      required String photoId,
      Value<int> rowid,
    });
typedef $$AlbumPhotosTableTableUpdateCompanionBuilder =
    AlbumPhotosTableCompanion Function({
      Value<String> albumId,
      Value<String> photoId,
      Value<int> rowid,
    });

final class $$AlbumPhotosTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $AlbumPhotosTableTable, AlbumPhotoData> {
  $$AlbumPhotosTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AlbumsTableTable _albumIdTable(_$AppDatabase db) =>
      db.albumsTable.createAlias(
        $_aliasNameGenerator(db.albumPhotosTable.albumId, db.albumsTable.id),
      );

  $$AlbumsTableTableProcessedTableManager get albumId {
    final $_column = $_itemColumn<String>('album_id')!;

    final manager = $$AlbumsTableTableTableManager(
      $_db,
      $_db.albumsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_albumIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PhotosTableTable _photoIdTable(_$AppDatabase db) =>
      db.photosTable.createAlias(
        $_aliasNameGenerator(db.albumPhotosTable.photoId, db.photosTable.id),
      );

  $$PhotosTableTableProcessedTableManager get photoId {
    final $_column = $_itemColumn<String>('photo_id')!;

    final manager = $$PhotosTableTableTableManager(
      $_db,
      $_db.photosTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_photoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlbumPhotosTableTableFilterComposer
    extends Composer<_$AppDatabase, $AlbumPhotosTableTable> {
  $$AlbumPhotosTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AlbumsTableTableFilterComposer get albumId {
    final $$AlbumsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albumsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableTableFilterComposer(
            $db: $db,
            $table: $db.albumsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhotosTableTableFilterComposer get photoId {
    final $$PhotosTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photosTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableTableFilterComposer(
            $db: $db,
            $table: $db.photosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumPhotosTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AlbumPhotosTableTable> {
  $$AlbumPhotosTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AlbumsTableTableOrderingComposer get albumId {
    final $$AlbumsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albumsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableTableOrderingComposer(
            $db: $db,
            $table: $db.albumsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhotosTableTableOrderingComposer get photoId {
    final $$PhotosTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photosTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableTableOrderingComposer(
            $db: $db,
            $table: $db.photosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumPhotosTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlbumPhotosTableTable> {
  $$AlbumPhotosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AlbumsTableTableAnnotationComposer get albumId {
    final $$AlbumsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.albumId,
      referencedTable: $db.albumsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlbumsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.albumsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PhotosTableTableAnnotationComposer get photoId {
    final $$PhotosTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.photoId,
      referencedTable: $db.photosTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableTableAnnotationComposer(
            $db: $db,
            $table: $db.photosTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlbumPhotosTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlbumPhotosTableTable,
          AlbumPhotoData,
          $$AlbumPhotosTableTableFilterComposer,
          $$AlbumPhotosTableTableOrderingComposer,
          $$AlbumPhotosTableTableAnnotationComposer,
          $$AlbumPhotosTableTableCreateCompanionBuilder,
          $$AlbumPhotosTableTableUpdateCompanionBuilder,
          (AlbumPhotoData, $$AlbumPhotosTableTableReferences),
          AlbumPhotoData,
          PrefetchHooks Function({bool albumId, bool photoId})
        > {
  $$AlbumPhotosTableTableTableManager(
    _$AppDatabase db,
    $AlbumPhotosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlbumPhotosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlbumPhotosTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlbumPhotosTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> albumId = const Value.absent(),
                Value<String> photoId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlbumPhotosTableCompanion(
                albumId: albumId,
                photoId: photoId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String albumId,
                required String photoId,
                Value<int> rowid = const Value.absent(),
              }) => AlbumPhotosTableCompanion.insert(
                albumId: albumId,
                photoId: photoId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AlbumPhotosTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({albumId = false, photoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (albumId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.albumId,
                                referencedTable:
                                    $$AlbumPhotosTableTableReferences
                                        ._albumIdTable(db),
                                referencedColumn:
                                    $$AlbumPhotosTableTableReferences
                                        ._albumIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (photoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.photoId,
                                referencedTable:
                                    $$AlbumPhotosTableTableReferences
                                        ._photoIdTable(db),
                                referencedColumn:
                                    $$AlbumPhotosTableTableReferences
                                        ._photoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlbumPhotosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlbumPhotosTableTable,
      AlbumPhotoData,
      $$AlbumPhotosTableTableFilterComposer,
      $$AlbumPhotosTableTableOrderingComposer,
      $$AlbumPhotosTableTableAnnotationComposer,
      $$AlbumPhotosTableTableCreateCompanionBuilder,
      $$AlbumPhotosTableTableUpdateCompanionBuilder,
      (AlbumPhotoData, $$AlbumPhotosTableTableReferences),
      AlbumPhotoData,
      PrefetchHooks Function({bool albumId, bool photoId})
    >;
typedef $$PresetsTableTableCreateCompanionBuilder =
    PresetsTableCompanion Function({
      required String id,
      required String name,
      required String category,
      required String parametersJson,
      Value<bool> isBookmarked,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PresetsTableTableUpdateCompanionBuilder =
    PresetsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<String> parametersJson,
      Value<bool> isBookmarked,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PresetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PresetsTableTable> {
  $$PresetsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PresetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PresetsTableTable> {
  $$PresetsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresetsTableTable> {
  $$PresetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get parametersJson => $composableBuilder(
    column: $table.parametersJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBookmarked => $composableBuilder(
    column: $table.isBookmarked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PresetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PresetsTableTable,
          PresetData,
          $$PresetsTableTableFilterComposer,
          $$PresetsTableTableOrderingComposer,
          $$PresetsTableTableAnnotationComposer,
          $$PresetsTableTableCreateCompanionBuilder,
          $$PresetsTableTableUpdateCompanionBuilder,
          (
            PresetData,
            BaseReferences<_$AppDatabase, $PresetsTableTable, PresetData>,
          ),
          PresetData,
          PrefetchHooks Function()
        > {
  $$PresetsTableTableTableManager(_$AppDatabase db, $PresetsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PresetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PresetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> parametersJson = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresetsTableCompanion(
                id: id,
                name: name,
                category: category,
                parametersJson: parametersJson,
                isBookmarked: isBookmarked,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required String parametersJson,
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PresetsTableCompanion.insert(
                id: id,
                name: name,
                category: category,
                parametersJson: parametersJson,
                isBookmarked: isBookmarked,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PresetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PresetsTableTable,
      PresetData,
      $$PresetsTableTableFilterComposer,
      $$PresetsTableTableOrderingComposer,
      $$PresetsTableTableAnnotationComposer,
      $$PresetsTableTableCreateCompanionBuilder,
      $$PresetsTableTableUpdateCompanionBuilder,
      (
        PresetData,
        BaseReferences<_$AppDatabase, $PresetsTableTable, PresetData>,
      ),
      PresetData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PhotosTableTableTableManager get photosTable =>
      $$PhotosTableTableTableManager(_db, _db.photosTable);
  $$AlbumsTableTableTableManager get albumsTable =>
      $$AlbumsTableTableTableManager(_db, _db.albumsTable);
  $$AlbumPhotosTableTableTableManager get albumPhotosTable =>
      $$AlbumPhotosTableTableTableManager(_db, _db.albumPhotosTable);
  $$PresetsTableTableTableManager get presetsTable =>
      $$PresetsTableTableTableManager(_db, _db.presetsTable);
}
