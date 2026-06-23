import '../../domain/entities/photo.dart';
import '../../domain/entities/album.dart';

abstract class LibraryRepository {
  Future<List<Photo>> getAllPhotos();
  Future<List<Photo>> getFavoritePhotos();
  Future<List<Photo>> getTrashPhotos();
  Future<Photo> importPhoto(String filePath);
  Future<void> updatePhotoRating(String id, int rating);
  Future<void> updatePhotoFavorite(String id, bool isFavorite);
  Future<void> updatePhotoTrash(String id, bool isTrash);
  Future<void> deletePhotoPermanently(String id);
  Future<void> updatePhotoKeywords(String id, List<String> keywords);
  Future<List<Album>> getAlbums();
  Future<Album> createAlbum(String name);
  Future<void> addPhotoToAlbum(String albumId, String photoId);
  Future<void> removePhotoFromAlbum(String albumId, String photoId);
  Future<List<Photo>> getPhotosInAlbum(String albumId);
}
