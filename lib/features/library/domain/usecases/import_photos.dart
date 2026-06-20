import '../entities/photo.dart';
import '../repositories/library_repository.dart';

class ImportPhotos {
  final LibraryRepository repository;

  ImportPhotos(this.repository);

  Future<Photo> call(String filePath) {
    return repository.importPhoto(filePath);
  }
}
