import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../editor/domain/entities/edit_session.dart';
import '../../../editor/domain/repositories/editor_repository.dart';

/// 🌱 SeedColor — Export PNG Use Case
///
/// Use case untuk mengekspor gambar ke format PNG (lossless).
class ExportPng {
  final EditorRepository repository;

  const ExportPng(this.repository);

  Future<Either<Failure, String>> call(
    EditSession session, {
    required String outputPath,
    required double scale,
  }) {
    return repository.exportImage(
      session,
      outputPath: outputPath,
      quality: 100, // PNG is lossless
      format: 'png',
      scale: scale,
    );
  }
}
