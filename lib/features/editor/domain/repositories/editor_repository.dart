import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/edit_session.dart';

/// 🌱 SeedColor — Editor Repository Interface
///
/// Kontrak repositori untuk mengelola sesi pengeditan dan ekspor gambar.
/// Implementasi repositori ini berada di Data Layer.
abstract class EditorRepository {
  /// Memulai sesi pengeditan baru untuk foto tertentu.
  /// Membaca dimensi gambar asli secara lokal.
  Future<Either<Failure, EditSession>> startSession(
    String photoId,
    String imagePath,
  );

  /// Menyimpan sesi pengeditan saat ini ke penyimpanan lokal (database/cache).
  Future<Either<Failure, void>> saveSession(EditSession session);

  /// Mendapatkan sesi pengeditan yang tersimpan sebelumnya untuk foto tertentu.
  Future<Either<Failure, EditSession>> getSession(String photoId);

  /// Mengekspor hasil pengeditan menjadi gambar final resolusi tinggi.
  ///
  /// [session]: Sesi pengeditan yang akan diekspor.
  /// [outputPath]: Path lokasi berkas ekspor disimpan.
  /// [quality]: Kualitas kompresi JPEG (1-100).
  /// Returns: Path berkas gambar yang berhasil diekspor.
  Future<Either<Failure, String>> exportImage(
    EditSession session, {
    required String outputPath,
    required int quality,
  });
}
