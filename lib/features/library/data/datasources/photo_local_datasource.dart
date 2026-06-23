import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class PhotoLocalDataSource {
  Future<List<PhotoData>> getAllPhotos();
  Future<List<PhotoData>> getFavoritePhotos();
  Future<List<PhotoData>> getTrashPhotos();
  Future<void> insertPhoto(PhotoData photo);
  Future<void> updatePhotoRating(String id, int rating);
  Future<void> updatePhotoFavorite(String id, bool isFavorite);
  Future<void> updatePhotoTrash(String id, bool isTrash);
  Future<void> deletePhotoPermanently(String id);
  Future<PhotoData?> getPhotoById(String id);
  Future<void> updatePhotoKeywords(String id, String? keywords);
}

class PhotoLocalDataSourceImpl implements PhotoLocalDataSource {
  final AppDatabase database;

  PhotoLocalDataSourceImpl(this.database);

  @override
  Future<List<PhotoData>> getAllPhotos() {
    return (database.select(database.photosTable)
          ..where((t) => t.isTrash.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  @override
  Future<List<PhotoData>> getFavoritePhotos() {
    return (database.select(database.photosTable)
          ..where((t) => t.isFavorite.equals(true) & t.isTrash.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  @override
  Future<List<PhotoData>> getTrashPhotos() {
    return (database.select(database.photosTable)
          ..where((t) => t.isTrash.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  @override
  Future<void> insertPhoto(PhotoData photo) {
    return database.into(database.photosTable).insert(photo, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> updatePhotoRating(String id, int rating) {
    return (database.update(database.photosTable)..where((t) => t.id.equals(id)))
        .write(PhotosTableCompanion(rating: Value(rating)));
  }

  @override
  Future<void> updatePhotoFavorite(String id, bool isFavorite) {
    return (database.update(database.photosTable)..where((t) => t.id.equals(id)))
        .write(PhotosTableCompanion(isFavorite: Value(isFavorite)));
  }

  @override
  Future<void> updatePhotoTrash(String id, bool isTrash) {
    // If sent to trash, we probably remove isFavorite or keep it?
    // Let's just keep the favorite flag or set to false. Usually keep is fine, but in query we exclude trash from favorites.
    return (database.update(database.photosTable)..where((t) => t.id.equals(id)))
        .write(PhotosTableCompanion(isTrash: Value(isTrash)));
  }

  @override
  Future<void> deletePhotoPermanently(String id) {
    return (database.delete(database.photosTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<PhotoData?> getPhotoById(String id) {
    return (database.select(database.photosTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<void> updatePhotoKeywords(String id, String? keywords) {
    return (database.update(database.photosTable)..where((t) => t.id.equals(id)))
        .write(PhotosTableCompanion(keywords: Value(keywords)));
  }
}
