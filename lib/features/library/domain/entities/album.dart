import 'package:equatable/equatable.dart';

class Album extends Equatable {
  final String id;
  final String name;
  final int photoCount;
  final String? coverPhotoPath;
  final DateTime createdAt;

  const Album({
    required this.id,
    required this.name,
    required this.photoCount,
    this.coverPhotoPath,
    required this.createdAt,
  });

  Album copyWith({
    String? id,
    String? name,
    int? photoCount,
    String? coverPhotoPath,
    DateTime? createdAt,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      photoCount: photoCount ?? this.photoCount,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, photoCount, coverPhotoPath, createdAt];
}
