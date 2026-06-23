import 'package:equatable/equatable.dart';

abstract class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

class LoadLibrary extends LibraryEvent {}

class ImportFromGallery extends LibraryEvent {}

class UpdatePhotoRating extends LibraryEvent {
  final String photoId;
  final int rating;

  const UpdatePhotoRating({required this.photoId, required this.rating});

  @override
  List<Object?> get props => [photoId, rating];
}

class UpdatePhotoFavorite extends LibraryEvent {
  final String photoId;
  final bool isFavorite;

  const UpdatePhotoFavorite({required this.photoId, required this.isFavorite});

  @override
  List<Object?> get props => [photoId, isFavorite];
}

class UpdatePhotoTrash extends LibraryEvent {
  final String photoId;
  final bool isTrash;

  const UpdatePhotoTrash({required this.photoId, required this.isTrash});

  @override
  List<Object?> get props => [photoId, isTrash];
}

class CreateNewAlbum extends LibraryEvent {
  final String name;

  const CreateNewAlbum({required this.name});

  @override
  List<Object?> get props => [name];
}

class AddPhotoToAlbumEvent extends LibraryEvent {
  final String albumId;
  final String photoId;

  const AddPhotoToAlbumEvent({required this.albumId, required this.photoId});

  @override
  List<Object?> get props => [albumId, photoId];
}

class RemovePhotoFromAlbumEvent extends LibraryEvent {
  final String albumId;
  final String photoId;

  const RemovePhotoFromAlbumEvent({required this.albumId, required this.photoId});

  @override
  List<Object?> get props => [albumId, photoId];
}

class DeletePhotoPermanentlyEvent extends LibraryEvent {
  final String photoId;

  const DeletePhotoPermanentlyEvent({required this.photoId});

  @override
  List<Object?> get props => [photoId];
}

class UpdatePhotoKeywords extends LibraryEvent {
  final String photoId;
  final List<String> keywords;

  const UpdatePhotoKeywords({required this.photoId, required this.keywords});

  @override
  List<Object?> get props => [photoId, keywords];
}
