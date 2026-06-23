import 'dart:io';
import 'package:path/path.dart' as p;
import '../editor/domain/entities/edit_session.dart';
import '../editor/domain/repositories/editor_repository.dart';
import '../library/domain/entities/photo.dart';

/// Callback type for batch export progress reporting.
///
/// [current]: The 1-based index of the currently processing photo.
/// [total]: The total number of photos in the batch.
/// [photoPath]: The path of the photo currently being processed.
typedef BatchExportProgressCallback = void Function(int current, int total, String photoPath);

/// 🌱 SeedColor — Batch Exporter Utility
///
/// Handles exporting multiple photos sequentially.
/// Relies on [EditorRepository.exportImage] which renders on the GPU (main thread)
/// and offloads compression (encoding) to a background isolate.
class BatchExporter {
  final EditorRepository editorRepository;

  BatchExporter({required this.editorRepository});

  /// Exports a list of [photos] to [outputDirectory] in batch.
  ///
  /// [format]: 'jpeg' or 'png'.
  /// [quality]: compression quality (1-100) for JPEG.
  /// [scale]: resolution scale (1.0, 0.5, or 0.25).
  /// [onProgress]: callback invoked as each photo starts/finishes exporting.
  Future<List<String>> exportPhotos(
    List<Photo> photos, {
    required String outputDirectory,
    String format = 'jpeg',
    int quality = 90,
    double scale = 1.0,
    BatchExportProgressCallback? onProgress,
  }) async {
    final List<String> exportedPaths = [];
    final total = photos.length;

    // Ensure output directory exists
    final dir = Directory(outputDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    for (int i = 0; i < total; i++) {
      final photo = photos[i];
      onProgress?.call(i + 1, total, photo.path);

      // 1. Retrieve or start editing session for the photo
      EditSession session;
      final sessionResult = await editorRepository.getSession(photo.id);
      
      session = await sessionResult.fold(
        (failure) async {
          // If session doesn't exist, start one
          final startResult = await editorRepository.startSession(photo.id, photo.path);
          return startResult.fold(
            (fail) => throw Exception('Gagal memulai sesi ekspor untuk ${photo.path}: $fail'),
            (s) => s,
          );
        },
        (s) => s,
      );

      // 2. Determine file name and output path
      final ext = format.toLowerCase() == 'png' ? 'png' : 'jpg';
      final baseName = p.basenameWithoutExtension(photo.path);
      final uniquePath = p.join(outputDirectory, 'SeedColor_${baseName}_${DateTime.now().millisecondsSinceEpoch}.$ext').replaceAll('\\', '/');

      // 3. Export the image (renders on GPU and encodes on Isolate)
      final exportResult = await editorRepository.exportImage(
        session,
        outputPath: uniquePath,
        quality: quality,
        format: format,
        scale: scale,
      );

      exportResult.fold(
        (failure) => throw Exception('Ekspor gagal untuk ${photo.path}: $failure'),
        (path) {
          exportedPaths.add(path);
        },
      );
    }

    return exportedPaths;
  }
}
