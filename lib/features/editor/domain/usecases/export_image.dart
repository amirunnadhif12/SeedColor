import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/edit_session.dart';
import '../repositories/editor_repository.dart';

/// 🌱 SeedColor — Export Image Use Case
///
/// Use case untuk mengekspor gambar final beresolusi penuh
/// dengan memanggil EditorRepository.
class ExportImage {
  final EditorRepository repository;

  const ExportImage(this.repository);

  Future<Either<Failure, String>> call(
    EditSession session, {
    required String outputPath,
    required int quality,
  }) {
    return repository.exportImage(
      session,
      outputPath: outputPath,
      quality: quality,
    );
  }
}
