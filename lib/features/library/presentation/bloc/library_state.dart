import 'package:equatable/equatable.dart';
import '../../domain/entities/photo.dart';
import '../../domain/entities/album.dart';

abstract class LibraryState extends Equatable {
  const LibraryState();

  @override
  List<Object?> get props => [];
}

class LibraryInitial extends LibraryState {}

class LibraryLoading extends LibraryState {}

class LibraryLoaded extends LibraryState {
  final List<Photo> allPhotos;
  final List<Photo> favoritePhotos;
  final List<Photo> trashPhotos;
  final List<Album> albums;
  final String? message;

  const LibraryLoaded({
    required this.allPhotos,
    required this.favoritePhotos,
    required this.trashPhotos,
    required this.albums,
    this.message,
  });

  LibraryLoaded copyWith({
    List<Photo>? allPhotos,
    List<Photo>? favoritePhotos,
    List<Photo>? trashPhotos,
    List<Album>? albums,
    String? message,
  }) {
    return LibraryLoaded(
      allPhotos: allPhotos ?? this.allPhotos,
      favoritePhotos: favoritePhotos ?? this.favoritePhotos,
      trashPhotos: trashPhotos ?? this.trashPhotos,
      albums: albums ?? this.albums,
      message: message,
    );
  }

  @override
  List<Object?> get props => [allPhotos, favoritePhotos, trashPhotos, albums, message];
}

class LibraryError extends LibraryState {
  final String errorMessage;

  const LibraryError({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
