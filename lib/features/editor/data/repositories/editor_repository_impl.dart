import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/edit_parameters.dart';
import '../../domain/entities/edit_session.dart';
import '../../domain/repositories/editor_repository.dart';

/// 🌱 SeedColor — Editor Repository Implementation
///
/// Implementasi repositori untuk mengelola sesi pengeditan dan ekspor gambar.
/// Saat ini menggunakan data mock untuk simulasi pemrosesan.
class EditorRepositoryImpl implements EditorRepository {
  // Simulasi penyimpanan sesi aktif di memori
  final Map<String, EditSession> _sessions = {};

  @override
  Future<Either<Failure, EditSession>> startSession(
    String photoId,
    String imagePath,
  ) async {
    try {
      // Jika sesi sudah ada, kembalikan sesi tersebut
      if (_sessions.containsKey(photoId)) {
        return Right(_sessions[photoId]!);
      }

      // Buat sesi baru dengan parameter default (identity)
      final session = EditSession(
        photoId: photoId,
        imagePath: imagePath,
        currentParameters: EditParameters.identity(),
        originalWidth: 1920,
        originalHeight: 1080,
        createdAt: DateTime.now(),
      );

      _sessions[photoId] = session;
      return Right(session);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSession(EditSession session) async {
    try {
      _sessions[session.photoId] = session;
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EditSession>> getSession(String photoId) async {
    try {
      final session = _sessions[photoId];
      if (session != null) {
        return Right(session);
      }
      return Left(StorageFailure('Sesi pengeditan untuk $photoId tidak ditemukan.'));
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> exportImage(
    EditSession session, {
    required String outputPath,
    required int quality,
  }) async {
    try {
      // Simulasi delay pemrosesan ekspor gambar
      await Future.delayed(const Duration(milliseconds: 1200));
      return Right(outputPath);
    } catch (e) {
      return Left(UnexpectedFailure(details: e.toString()));
    }
  }
}
