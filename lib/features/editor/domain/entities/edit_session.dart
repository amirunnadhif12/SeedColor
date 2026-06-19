import 'package:equatable/equatable.dart';
import 'edit_parameters.dart';

/// 🌱 SeedColor — Edit Session
///
/// Menyimpan informasi sesi pengeditan aktif untuk sebuah foto.
class EditSession extends Equatable {
  final String photoId;
  final String imagePath;
  final EditParameters currentParameters;
  final int originalWidth;
  final int originalHeight;
  final DateTime createdAt;

  const EditSession({
    required this.photoId,
    required this.imagePath,
    required this.currentParameters,
    required this.originalWidth,
    required this.originalHeight,
    required this.createdAt,
  });

  EditSession copyWith({
    String? photoId,
    String? imagePath,
    EditParameters? currentParameters,
    int? originalWidth,
    int? originalHeight,
    DateTime? createdAt,
  }) {
    return EditSession(
      photoId: photoId ?? this.photoId,
      imagePath: imagePath ?? this.imagePath,
      currentParameters: currentParameters ?? this.currentParameters,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        photoId,
        imagePath,
        currentParameters,
        originalWidth,
        originalHeight,
        createdAt,
      ];
}
