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

class MockEditorRepository implements EditorRepository {
  @override
  Future<Either<Failure, EditSession>> startSession(
    String photoId,
    String imagePath,
  ) async {
    return Right(EditSession(
      photoId: photoId,
      imagePath: imagePath,
      currentParameters: EditParameters.identity(),
      originalWidth: 1000,
      originalHeight: 800,
      createdAt: DateTime(2026, 6, 19),
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
    return Right(outputPath);
  }
}

void main() {
  late MockEditorRepository mockRepository;
  late EditorBloc bloc;

  setUp(() {
    mockRepository = MockEditorRepository();
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

  group('EditorBloc History & Snapshots', () {
    test('StartSession should add "Impor Foto" as the first history entry', () async {
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.history.length, equals(1));
      expect(bloc.state.history.first.label, equals('Impor Foto'));
      expect(bloc.state.currentHistoryIndex, equals(0));
    });

    test('Updating parameters should automatically add descriptive history entries', () async {
      // 1. Start Session
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);

      final baseParams = bloc.state.session!.currentParameters;

      // 2. Update Exposure to +1.0
      bloc.add(UpdateLight(baseParams.copyWith(exposure: 1.0)));
      await Future.delayed(Duration.zero);

      expect(bloc.state.history.length, equals(2));
      expect(bloc.state.history[1].label, equals('Pencahayaan +1.00'));
      expect(bloc.state.currentHistoryIndex, equals(1));

      // 3. Update Contrast to +10.0
      bloc.add(UpdateLight(bloc.state.session!.currentParameters.copyWith(contrast: 10.0)));
      await Future.delayed(Duration.zero);

      expect(bloc.state.history.length, equals(3));
      expect(bloc.state.history[2].label, equals('Kontras +10'));
      expect(bloc.state.currentHistoryIndex, equals(2));
    });

    test('NavigateHistory should navigate to a past history index and revert params', () async {
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);

      final baseParams = bloc.state.session!.currentParameters;

      // Exposure +1.0
      bloc.add(UpdateLight(baseParams.copyWith(exposure: 1.0)));
      await Future.delayed(Duration.zero);

      // Contrast +10.0
      bloc.add(UpdateLight(bloc.state.session!.currentParameters.copyWith(contrast: 10.0)));
      await Future.delayed(Duration.zero);

      expect(bloc.state.session!.currentParameters.exposure, equals(1.0));
      expect(bloc.state.session!.currentParameters.contrast, equals(10.0));

      // Navigate back to "Pencahayaan +1.00" (index 1)
      bloc.add(const NavigateHistory(1));
      await Future.delayed(Duration.zero);

      expect(bloc.state.currentHistoryIndex, equals(1));
      expect(bloc.state.session!.currentParameters.exposure, equals(1.0));
      expect(bloc.state.session!.currentParameters.contrast, equals(0.0));

      // Navigate back to "Impor Foto" (index 0)
      bloc.add(const NavigateHistory(0));
      await Future.delayed(Duration.zero);

      expect(bloc.state.currentHistoryIndex, equals(0));
      expect(bloc.state.session!.currentParameters.exposure, equals(0.0));
      expect(bloc.state.session!.currentParameters.contrast, equals(0.0));
    });

    test('New edit after navigating back should truncate the future history stack', () async {
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);

      final baseParams = bloc.state.session!.currentParameters;

      // Step 1: Exposure +1.0
      bloc.add(UpdateLight(baseParams.copyWith(exposure: 1.0)));
      await Future.delayed(Duration.zero);

      // Step 2: Contrast +10.0
      bloc.add(UpdateLight(bloc.state.session!.currentParameters.copyWith(contrast: 10.0)));
      await Future.delayed(Duration.zero);

      expect(bloc.state.history.length, equals(3));

      // Navigate back to Step 1
      bloc.add(const NavigateHistory(1));
      await Future.delayed(Duration.zero);

      // Perform a new edit (Contrast = -5.0)
      bloc.add(UpdateLight(bloc.state.session!.currentParameters.copyWith(contrast: -5.0)));
      await Future.delayed(Duration.zero);

      // History stack should have truncated the old Step 2 and appended the new one
      expect(bloc.state.history.length, equals(3));
      expect(bloc.state.history[2].label, equals('Kontras -5'));
      expect(bloc.state.currentHistoryIndex, equals(2));
      expect(bloc.state.session!.currentParameters.exposure, equals(1.0));
      expect(bloc.state.session!.currentParameters.contrast, equals(-5.0));
    });

    test('Snapshot CRUD operations should work correctly', () async {
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);

      final baseParams = bloc.state.session!.currentParameters;

      // Make adjustment (Exposure = 1.5)
      bloc.add(UpdateLight(baseParams.copyWith(exposure: 1.5)));
      await Future.delayed(Duration.zero);

      // Create snapshot
      bloc.add(const CreateSnapshot('Filter Hangat'));
      await Future.delayed(Duration.zero);

      expect(bloc.state.snapshots.length, equals(1));
      expect(bloc.state.snapshots.first.name, equals('Filter Hangat'));
      expect(bloc.state.snapshots.first.parameters.exposure, equals(1.5));
      expect(bloc.state.history.last.label, equals('Buat Snapshot "Filter Hangat"'));

      final snapshot = bloc.state.snapshots.first;

      // Make another edit (Contrast = 20)
      bloc.add(UpdateLight(bloc.state.session!.currentParameters.copyWith(contrast: 20)));
      await Future.delayed(Duration.zero);
      expect(bloc.state.session!.currentParameters.contrast, equals(20));

      // Apply snapshot
      bloc.add(ApplySnapshot(snapshot));
      await Future.delayed(Duration.zero);

      expect(bloc.state.session!.currentParameters.exposure, equals(1.5));
      expect(bloc.state.session!.currentParameters.contrast, equals(0)); // Reverted to snapshot params
      expect(bloc.state.history.last.label, equals('Terapkan Snapshot "Filter Hangat"'));

      // Delete snapshot
      bloc.add(DeleteSnapshot(snapshot.id));
      await Future.delayed(Duration.zero);

      expect(bloc.state.snapshots.isEmpty, isTrue);
    });
  });
}
