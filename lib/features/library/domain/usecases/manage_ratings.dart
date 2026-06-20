import '../repositories/library_repository.dart';

class ManageRatings {
  final LibraryRepository repository;

  ManageRatings(this.repository);

  Future<void> updateRating(String id, int rating) {
    return repository.updatePhotoRating(id, rating);
  }

  Future<void> updateFavorite(String id, bool isFavorite) {
    return repository.updatePhotoFavorite(id, isFavorite);
  }

  Future<void> updateTrash(String id, bool isTrash) {
    return repository.updatePhotoTrash(id, isTrash);
  }

  Future<void> deletePermanently(String id) {
    return repository.deletePhotoPermanently(id);
  }
}
