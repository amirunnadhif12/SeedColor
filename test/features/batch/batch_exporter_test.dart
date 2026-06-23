import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/batch/batch_exporter.dart';
import 'package:seed_color/features/editor/domain/entities/edit_session.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';
import 'package:seed_color/features/editor/domain/repositories/editor_repository.dart';
import 'package:seed_color/features/library/domain/entities/photo.dart';
import 'package:seed_color/core/errors/either.dart';
import 'package:seed_color/core/errors/failures.dart';

class MockEditorRepository implements EditorRepository {
  final Map<String, EditSession> sessions = {};
  int startSessionCount = 0;
  int getSessionCount = 0;
  int exportImageCount = 0;

  @override
  Future<Either<Failure, EditSession>> startSession(String photoId, String imagePath) async {
    startSessionCount++;
    final session = EditSession(
      photoId: photoId,
      imagePath: imagePath,
      currentParameters: EditParameters.identity(),
      originalWidth: 1920,
      originalHeight: 1080,
      createdAt: DateTime.now(),
    );
    sessions[photoId] = session;
    return Right(session);
  }

  @override
  Future<Either<Failure, EditSession>> getSession(String photoId) async {
    getSessionCount++;
    final session = sessions[photoId];
    if (session != null) {
      return Right(session);
    }
    return Left(StorageFailure('Not found'));
  }

  @override
  Future<Either<Failure, void>> saveSession(EditSession session) async {
    sessions[session.photoId] = session;
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> exportImage(
    EditSession session, {
    required String outputPath,
    required int quality,
    String format = 'jpeg',
    double scale = 1.0,
  }) async {
    exportImageCount++;
    return Right(outputPath);
  }
}

void main() {
  group('BatchExporter Tests', () {
    late MockEditorRepository mockEditorRepo;
    late BatchExporter batchExporter;

    setUp(() {
      mockEditorRepo = MockEditorRepository();
      batchExporter = BatchExporter(editorRepository: mockEditorRepo);
    });

    test('should sequentially export multiple photos and report progress', () async {
      final photos = [
        Photo(id: 'photo_1', path: 'path/to/1.jpg', createdAt: DateTime.now()),
        Photo(id: 'photo_2', path: 'path/to/2.jpg', createdAt: DateTime.now()),
      ];

      final List<Map<String, dynamic>> progressEvents = [];

      final result = await batchExporter.exportPhotos(
        photos,
        outputDirectory: 'output/dir',
        format: 'jpeg',
        quality: 85,
        scale: 0.5,
        onProgress: (current, total, photoPath) {
          progressEvents.add({'current': current, 'total': total, 'path': photoPath});
        },
      );

      // Verify that getSession/startSession and exportImage were called for each photo
      expect(mockEditorRepo.getSessionCount, equals(2));
      expect(mockEditorRepo.startSessionCount, equals(2));
      expect(mockEditorRepo.exportImageCount, equals(2));

      // Verify progress callback invocations
      expect(progressEvents.length, equals(2));
      expect(progressEvents[0]['current'], equals(1));
      expect(progressEvents[0]['total'], equals(2));
      expect(progressEvents[0]['path'], equals('path/to/1.jpg'));
      expect(progressEvents[1]['current'], equals(2));
      expect(progressEvents[1]['total'], equals(2));
      expect(progressEvents[1]['path'], equals('path/to/2.jpg'));

      // Verify output paths returned
      expect(result.length, equals(2));
      expect(result[0], contains('SeedColor_1'));
      expect(result[1], contains('SeedColor_2'));
    });
  });
}
