import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

class AlbumWithStats {
  final AlbumData album;
  final int photoCount;
  final String? coverPhotoPath;

  AlbumWithStats({
    required this.album,
    required this.photoCount,
    this.coverPhotoPath,
  });
}

abstract class AlbumLocalDataSource {
  Future<List<AlbumWithStats>> getAlbumsWithStats();
  Future<void> createAlbum(AlbumData album);
  Future<void> addPhotoToAlbum(String albumId, String photoId);
  Future<void> removePhotoFromAlbum(String albumId, String photoId);
  Future<List<PhotoData>> getPhotosInAlbum(String albumId);
  Future<AlbumData?> getAlbumById(String id);
  Future<void> deleteAlbum(String id);
}

class AlbumLocalDataSourceImpl implements AlbumLocalDataSource {
  final AppDatabase database;

  AlbumLocalDataSourceImpl(this.database);

  @override
  Future<List<AlbumWithStats>> getAlbumsWithStats() async {
    final albums = await (database.select(database.albumsTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();

    final List<AlbumWithStats> results = [];
    for (final album in albums) {
      final query = database.select(database.albumPhotosTable).join([
        innerJoin(
          database.photosTable,
          database.photosTable.id.equalsExp(database.albumPhotosTable.photoId),
        ),
      ])..where(
          database.albumPhotosTable.albumId.equals(album.id) &
          database.photosTable.isTrash.equals(false),
        );

      final rows = await query.get();
      final count = rows.length;
      String? coverPath;
      if (rows.isNotEmpty) {
        final photo = rows.first.readTable(database.photosTable);
        coverPath = photo.path;
      }
      results.add(AlbumWithStats(
        album: album,
        photoCount: count,
        coverPhotoPath: coverPath,
      ));
    }
    return results;
  }

  @override
  Future<void> createAlbum(AlbumData album) {
    return database.into(database.albumsTable).insert(album);
  }

  @override
  Future<void> addPhotoToAlbum(String albumId, String photoId) {
    return database.into(database.albumPhotosTable).insert(
          AlbumPhotoData(albumId: albumId, photoId: photoId),
          mode: InsertMode.insertOrIgnore,
        );
  }

  @override
  Future<void> removePhotoFromAlbum(String albumId, String photoId) {
    return (database.delete(database.albumPhotosTable)
          ..where((t) => t.albumId.equals(albumId) & t.photoId.equals(photoId)))
        .go();
  }

  @override
  Future<List<PhotoData>> getPhotosInAlbum(String albumId) async {
    final query = database.select(database.albumPhotosTable).join([
      innerJoin(
        database.photosTable,
        database.photosTable.id.equalsExp(database.albumPhotosTable.photoId),
      ),
    ])..where(
        database.albumPhotosTable.albumId.equals(albumId) &
        database.photosTable.isTrash.equals(false),
      )..orderBy([
        OrderingTerm.desc(database.photosTable.createdAt),
      ]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(database.photosTable)).toList();
  }

  @override
  Future<AlbumData?> getAlbumById(String id) {
    return (database.select(database.albumsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> deleteAlbum(String id) {
    return (database.delete(database.albumsTable)..where((t) => t.id.equals(id))).go();
  }
}
