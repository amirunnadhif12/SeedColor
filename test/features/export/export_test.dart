import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/core/errors/either.dart';
import 'package:seed_color/core/errors/failures.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';
import 'package:seed_color/features/editor/domain/entities/edit_session.dart';
import 'package:seed_color/features/editor/domain/repositories/editor_repository.dart';
import 'package:seed_color/features/editor/domain/usecases/apply_adjustments.dart';
import 'package:seed_color/features/editor/domain/usecases/apply_curves.dart';
import 'package:seed_color/features/editor/domain/usecases/apply_hsl.dart';
import 'package:seed_color/features/editor/domain/usecases/export_image.dart';
import 'package:seed_color/features/editor/domain/usecases/reset_adjustments.dart';
import 'package:seed_color/features/editor/presentation/bloc/editor_bloc.dart';
import 'package:seed_color/features/editor/presentation/bloc/editor_event.dart';
import 'package:seed_color/features/editor/presentation/bloc/editor_state.dart';
import 'package:seed_color/features/export/domain/usecases/export_jpeg.dart';
import 'package:seed_color/features/export/domain/usecases/export_png.dart';

class MockEditorRepository implements EditorRepository {
  bool exportCalled = false;
  String? formatPassed;
  double? scalePassed;
  int? qualityPassed;

  @override
  Future<Either<Failure, EditSession>> startSession(String photoId, String imagePath) async {
    return Right(EditSession(
      photoId: photoId,
      imagePath: imagePath,
      currentParameters: EditParameters.identity(),
      originalWidth: 1920,
      originalHeight: 1080,
      createdAt: DateTime.now(),
    ));
  }

  @override
  Future<Either<Failure, void>> saveSession(EditSession session) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, EditSession>> getSession(String photoId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> exportImage(
    EditSession session, {
    required String outputPath,
    required int quality,
    String format = 'jpeg',
    double scale = 1.0,
  }) async {
    exportCalled = true;
    formatPassed = format;
    scalePassed = scale;
    qualityPassed = quality;
    return Right(outputPath);
  }
}

void main() {
  late MockEditorRepository mockRepository;
  late EditSession mockSession;

  setUp(() {
    mockRepository = MockEditorRepository();
    mockSession = EditSession(
      photoId: 'photo_1',
      imagePath: 'assets/images/mountain_lake.png',
      currentParameters: EditParameters.identity(),
      originalWidth: 100,
      originalHeight: 100,
      createdAt: DateTime.now(),
    );
  });

  group('Usecases Tests', () {
    test('ExportJpeg usecase should call repository with jpeg format', () async {
      final usecase = ExportJpeg(mockRepository);
      final result = await usecase.call(
        mockSession,
        outputPath: 'path/to/output.jpg',
        quality: 85,
        scale: 0.5,
      );

      expect(result.isRight, isTrue);
      expect(mockRepository.exportCalled, isTrue);
      expect(mockRepository.formatPassed, equals('jpeg'));
      expect(mockRepository.qualityPassed, equals(85));
      expect(mockRepository.scalePassed, equals(0.5));
    });

    test('ExportPng usecase should call repository with png format and quality 100', () async {
      final usecase = ExportPng(mockRepository);
      final result = await usecase.call(
        mockSession,
        outputPath: 'path/to/output.png',
        scale: 1.0,
      );

      expect(result.isRight, isTrue);
      expect(mockRepository.exportCalled, isTrue);
      expect(mockRepository.formatPassed, equals('png'));
      expect(mockRepository.qualityPassed, equals(100));
      expect(mockRepository.scalePassed, equals(1.0));
    });
  });

  group('EditorBloc Export Event Handling', () {
    late EditorBloc bloc;

    setUp(() {
      bloc = EditorBloc(
        repository: mockRepository,
        applyAdjustments: ApplyAdjustments(),
        applyCurves: ApplyCurves(),
        applyHsl: ApplyHsl(),
        resetAdjustments: ResetAdjustments(),
        exportImage: ExportImage(mockRepository),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('should load session and handle Export event correctly', () async {
      final states = <EditorState>[];
      final subscription = bloc.stream.listen(states.add);

      // Start session first
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);

      // Trigger export
      bloc.add(const Export(
        outputPath: 'path/to/export.jpg',
        quality: 90,
        format: 'jpeg',
        scale: 0.5,
      ));
      await Future.delayed(Duration.zero);

      // Check states: should have loading states and final exported path
      expect(mockRepository.exportCalled, isTrue);
      expect(mockRepository.formatPassed, equals('jpeg'));
      expect(mockRepository.qualityPassed, equals(90));
      expect(mockRepository.scalePassed, equals(0.5));

      final lastState = bloc.state;
      expect(lastState.exportedImagePath, equals('path/to/export.jpg'));
      expect(lastState.isProcessing, isFalse);

      subscription.cancel();
    });
  });
}
