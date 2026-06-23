import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('PhotoData')
class PhotosTable extends Table {
  TextColumn get id => text()();
  TextColumn get path => text()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get rating => integer().withDefault(const Constant(0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get keywords => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AlbumData')
class AlbumsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AlbumPhotoData')
class AlbumPhotosTable extends Table {
  TextColumn get albumId => text().references(AlbumsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get photoId => text().references(PhotosTable, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {albumId, photoId};
}

@DataClassName('PresetData')
class PresetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // 'recommended', 'premium', 'yours'
  TextColumn get parametersJson => text()();
  BoolColumn get isBookmarked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PhotosTable, AlbumsTable, AlbumPhotosTable, PresetsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(photosTable, photosTable.keywords);
          }
        },
      );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'seed_color.db'));
    return NativeDatabase.createInBackground(file);
  });
}
