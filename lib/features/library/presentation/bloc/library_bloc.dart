import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/library_repository.dart';
import 'library_event.dart';
import 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  final LibraryRepository repository;
  final ImagePicker _picker = ImagePicker();

  LibraryBloc({required this.repository}) : super(LibraryInitial()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<ImportFromGallery>(_onImportFromGallery);
    on<UpdatePhotoRating>(_onUpdatePhotoRating);
    on<UpdatePhotoFavorite>(_onUpdatePhotoFavorite);
    on<UpdatePhotoTrash>(_onUpdatePhotoTrash);
    on<CreateNewAlbum>(_onCreateNewAlbum);
    on<AddPhotoToAlbumEvent>(_onAddPhotoToAlbum);
    on<RemovePhotoFromAlbumEvent>(_onRemovePhotoFromAlbum);
    on<DeletePhotoPermanentlyEvent>(_onDeletePhotoPermanently);
  }

  Future<void> _onLoadLibrary(LoadLibrary event, Emitter<LibraryState> emit) async {
    emit(LibraryLoading());
    try {
      final all = await repository.getAllPhotos();
      final favorites = await repository.getFavoritePhotos();
      final trash = await repository.getTrashPhotos();
      final albums = await repository.getAlbums();
      emit(LibraryLoaded(
        allPhotos: all,
        favoritePhotos: favorites,
        trashPhotos: trash,
        albums: albums,
      ));
    } catch (e) {
      emit(LibraryError(errorMessage: e.toString()));
    }
  }

  Future<void> _onImportFromGallery(ImportFromGallery event, Emitter<LibraryState> emit) async {
    final currentState = state;
    if (currentState is LibraryLoaded) {
      try {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image == null) return;

        emit(LibraryLoading());
        await repository.importPhoto(image.path);

        // Reload data
        final all = await repository.getAllPhotos();
        final favorites = await repository.getFavoritePhotos();
        final trash = await repository.getTrashPhotos();
        final albums = await repository.getAlbums();
        emit(LibraryLoaded(
          allPhotos: all,
          favoritePhotos: favorites,
          trashPhotos: trash,
          albums: albums,
          message: 'Photo imported successfully',
        ));
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdatePhotoRating(UpdatePhotoRating event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.updatePhotoRating(event.photoId, event.rating);
        await _reloadLibraryData(emit);
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdatePhotoFavorite(UpdatePhotoFavorite event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.updatePhotoFavorite(event.photoId, event.isFavorite);
        await _reloadLibraryData(emit);
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onUpdatePhotoTrash(UpdatePhotoTrash event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.updatePhotoTrash(event.photoId, event.isTrash);
        await _reloadLibraryData(emit);
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onCreateNewAlbum(CreateNewAlbum event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.createAlbum(event.name);
        await _reloadLibraryData(emit, message: 'Album "${event.name}" created');
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onAddPhotoToAlbum(AddPhotoToAlbumEvent event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.addPhotoToAlbum(event.albumId, event.photoId);
        await _reloadLibraryData(emit);
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onRemovePhotoFromAlbum(RemovePhotoFromAlbumEvent event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.removePhotoFromAlbum(event.albumId, event.photoId);
        await _reloadLibraryData(emit);
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onDeletePhotoPermanently(DeletePhotoPermanentlyEvent event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded) {
      try {
        await repository.deletePhotoPermanently(event.photoId);
        await _reloadLibraryData(emit, message: 'Photo permanently deleted');
      } catch (e) {
        emit(LibraryError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _reloadLibraryData(Emitter<LibraryState> emit, {String? message}) async {
    final all = await repository.getAllPhotos();
    final favorites = await repository.getFavoritePhotos();
    final trash = await repository.getTrashPhotos();
    final albums = await repository.getAlbums();
    emit(LibraryLoaded(
      allPhotos: all,
      favoritePhotos: favorites,
      trashPhotos: trash,
      albums: albums,
      message: message,
    ));
  }
}
