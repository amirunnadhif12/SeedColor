import '../entities/album.dart';
import '../repositories/library_repository.dart';

class GetAlbums {
  final LibraryRepository repository;

  GetAlbums(this.repository);

  Future<List<Album>> call() {
    return repository.getAlbums();
  }
}
