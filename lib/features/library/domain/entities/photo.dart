import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  final String id;
  final String path;
  final String? thumbnailPath;
  final int rating;
  final bool isFavorite;
  final bool isTrash;
  final DateTime createdAt;
  final List<String> keywords;

  const Photo({
    required this.id,
    required this.path,
    this.thumbnailPath,
    this.rating = 0,
    this.isFavorite = false,
    this.isTrash = false,
    required this.createdAt,
    this.keywords = const [],
  });

  Photo copyWith({
    String? id,
    String? path,
    String? thumbnailPath,
    int? rating,
    bool? isFavorite,
    bool? isTrash,
    DateTime? createdAt,
    List<String>? keywords,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      isTrash: isTrash ?? this.isTrash,
      createdAt: createdAt ?? this.createdAt,
      keywords: keywords ?? this.keywords,
    );
  }

  @override
  List<Object?> get props => [
        id,
        path,
        thumbnailPath,
        rating,
        isFavorite,
        isTrash,
        createdAt,
        keywords,
      ];
}
