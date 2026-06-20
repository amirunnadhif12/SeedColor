import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../editor/domain/entities/edit_session.dart';
import '../../../editor/domain/repositories/editor_repository.dart';

/// 🌱 SeedColor — Export JPEG Use Case
///
/// Use case untuk mengekspor gambar ke format JPEG dengan kualitas tertentu.
class ExportJpeg {
  final EditorRepository repository;

  const ExportJpeg(this.repository);

  Future<Either<Failure, String>> call(
    EditSession session, {
    required String outputPath,
    required int quality,
    required double scale,
  }) {
    return repository.exportImage(
      session,
      outputPath: outputPath,
      quality: quality,
      format: 'jpeg',
      scale: scale,
    );
  }
}
