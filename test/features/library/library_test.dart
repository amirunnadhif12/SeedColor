import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/library/domain/entities/photo.dart';
import 'package:seed_color/features/library/domain/entities/album.dart';
import 'package:seed_color/features/library/domain/repositories/library_repository.dart';
import 'package:seed_color/features/library/presentation/bloc/library_bloc.dart';
import 'package:seed_color/features/library/presentation/bloc/library_event.dart';
import 'package:seed_color/features/library/presentation/bloc/library_state.dart';

class MockLibraryRepository implements LibraryRepository {
  List<Photo> allPhotos = [];
  List<Photo> favoritePhotos = [];
  List<Photo> trashPhotos = [];
  List<Album> albums = [];

  @override
  Future<List<Photo>> getAllPhotos() async => allPhotos;

  @override
  Future<List<Photo>> getFavoritePhotos() async => favoritePhotos;

  @override
  Future<List<Photo>> getTrashPhotos() async => trashPhotos;

  @override
  Future<Photo> importPhoto(String filePath) async {
    final photo = Photo(
      id: 'test_photo_id',
      path: filePath,
      thumbnailPath: filePath,
      createdAt: DateTime.now(),
    );
    allPhotos.add(photo);
    return photo;
  }

  @override
  Future<void> updatePhotoRating(String id, int rating) async {
    final index = allPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      allPhotos[index] = allPhotos[index].copyWith(rating: rating);
    }
  }

  @override
  Future<void> updatePhotoFavorite(String id, bool isFavorite) async {
    final index = allPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      allPhotos[index] = allPhotos[index].copyWith(isFavorite: isFavorite);
      if (isFavorite) {
        favoritePhotos.add(allPhotos[index]);
      } else {
        favoritePhotos.removeWhere((p) => p.id == id);
      }
    }
  }

  @override
  Future<void> updatePhotoTrash(String id, bool isTrash) async {
    final index = allPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      allPhotos[index] = allPhotos[index].copyWith(isTrash: isTrash);
      if (isTrash) {
        trashPhotos.add(allPhotos[index]);
        allPhotos.removeAt(index);
      }
    }
  }

  @override
  Future<void> deletePhotoPermanently(String id) async {
    trashPhotos.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> updatePhotoKeywords(String id, List<String> keywords) async {
    final index = allPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      allPhotos[index] = allPhotos[index].copyWith(keywords: keywords);
    }
  }

  @override
  Future<List<Album>> getAlbums() async => albums;

  @override
  Future<Album> createAlbum(String name) async {
    final album = Album(
      id: 'test_album_id',
      name: name,
      photoCount: 0,
      createdAt: DateTime.now(),
    );
    albums.add(album);
    return album;
  }

  @override
  Future<void> addPhotoToAlbum(String albumId, String photoId) async {}

  @override
  Future<void> removePhotoFromAlbum(String albumId, String photoId) async {}

  @override
  Future<List<Photo>> getPhotosInAlbum(String albumId) async => [];
}

void main() {
  late MockLibraryRepository mockRepository;
  late LibraryBloc bloc;

  setUp(() {
    mockRepository = MockLibraryRepository();
    bloc = LibraryBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state should be LibraryInitial', () {
    expect(bloc.state, equals(LibraryInitial()));
  });

  group('LoadLibrary', () {
    test('should emit loading then loaded with lists from repository', () async {
      mockRepository.allPhotos = [
        Photo(id: '1', path: 'path1', createdAt: DateTime.now()),
      ];
      mockRepository.albums = [
        Album(id: 'a1', name: 'Nature', photoCount: 1, createdAt: DateTime.now()),
      ];

      final states = <LibraryState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(LoadLibrary());

      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0], equals(LibraryLoading()));
      expect(states[1], isA<LibraryLoaded>());
      final loaded = states[1] as LibraryLoaded;
      expect(loaded.allPhotos.length, equals(1));
      expect(loaded.albums.length, equals(1));

      sub.cancel();
    });
  });

  group('Rating & Favorite Updates', () {
    late Photo photo;

    setUp(() async {
      photo = Photo(id: 'p1', path: 'path1', createdAt: DateTime.now());
      mockRepository.allPhotos = [photo];

      bloc.add(LoadLibrary());
      await Future.delayed(Duration.zero);
    });

    test('UpdatePhotoRating should update photo rating and reload lists', () async {
      bloc.add(const UpdatePhotoRating(photoId: 'p1', rating: 4));
      await Future.delayed(Duration.zero);

      expect(mockRepository.allPhotos.first.rating, equals(4));
      final loaded = bloc.state as LibraryLoaded;
      expect(loaded.allPhotos.first.rating, equals(4));
    });

    test('UpdatePhotoFavorite should add photo to favorites list and reload', () async {
      bloc.add(const UpdatePhotoFavorite(photoId: 'p1', isFavorite: true));
      await Future.delayed(Duration.zero);

      expect(mockRepository.allPhotos.first.isFavorite, isTrue);
      final loaded = bloc.state as LibraryLoaded;
      expect(loaded.favoritePhotos.length, equals(1));
      expect(loaded.favoritePhotos.first.id, equals('p1'));
    });

    test('UpdatePhotoKeywords should update keywords and reload', () async {
      bloc.add(const UpdatePhotoKeywords(photoId: 'p1', keywords: ['nature', 'sunset']));
      await Future.delayed(Duration.zero);

      expect(mockRepository.allPhotos.first.keywords, equals(['nature', 'sunset']));
      final loaded = bloc.state as LibraryLoaded;
      expect(loaded.allPhotos.first.keywords, equals(['nature', 'sunset']));
    });
  });

  group('Album Actions', () {
    setUp(() async {
      bloc.add(LoadLibrary());
      await Future.delayed(Duration.zero);
    });

    test('CreateNewAlbum should append album to list', () async {
      bloc.add(const CreateNewAlbum(name: 'Vacation'));
      await Future.delayed(Duration.zero);

      expect(mockRepository.albums.length, equals(1));
      expect(mockRepository.albums.first.name, equals('Vacation'));

      final loaded = bloc.state as LibraryLoaded;
      expect(loaded.albums.length, equals(1));
      expect(loaded.albums.first.name, equals('Vacation'));
    });
  });
}
