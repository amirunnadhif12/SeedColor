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

class MockEditorRepository implements EditorRepository {
  bool startSessionCalled = false;
  bool saveSessionCalled = false;
  bool exportImageCalled = false;

  @override
  Future<Either<Failure, EditSession>> startSession(
    String photoId,
    String imagePath,
  ) async {
    startSessionCalled = true;
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
    saveSessionCalled = true;
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
  }) async {
    exportImageCalled = true;
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

  test('initial state should be EditorState.initial()', () {
    expect(bloc.state, equals(EditorState.initial()));
  });

  group('StartSession', () {
    test('should load session and update state correctly', () async {
      final states = <EditorState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));

      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0].isProcessing, isTrue);
      expect(states[1].isProcessing, isFalse);
      expect(states[1].session!.photoId, equals('photo_1'));
      expect(mockRepository.startSessionCalled, isTrue);

      sub.cancel();
    });
  });

  group('Sliders and Parameter Updates', () {
    late EditSession session;

    setUp(() async {
      // Pre-load session for updating sliders
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);
      session = bloc.state.session!;
    });

    test('UpdateLight should emit updated parameters', () async {
      final newParams = session.currentParameters.copyWith(exposure: 1.5, contrast: 10.0);
      bloc.add(UpdateLight(newParams));

      await Future.delayed(Duration.zero);
      expect(bloc.state.session!.currentParameters.exposure, equals(1.5));
      expect(bloc.state.session!.currentParameters.contrast, equals(10.0));
    });

    test('ResetAll should revert all settings to identity', () async {
      // Modify first
      bloc.add(UpdateLight(session.currentParameters.copyWith(exposure: 3.0)));
      await Future.delayed(Duration.zero);
      expect(bloc.state.session!.currentParameters.exposure, equals(3.0));

      // Reset
      bloc.add(const ResetAll());
      await Future.delayed(Duration.zero);
      expect(bloc.state.session!.currentParameters.exposure, equals(0.0));
    });
  });

  group('ReplayBloc History (Undo / Redo)', () {
    test('should record and traverse history using undo and redo', () async {
      // Load session
      bloc.add(const StartSession(photoId: 'photo_1', imagePath: 'image.png'));
      await Future.delayed(Duration.zero);
      final initialParams = bloc.state.session!.currentParameters;

      // Update 1 (Exposure = 1.0)
      bloc.add(UpdateLight(initialParams.copyWith(exposure: 1.0)));
      await Future.delayed(Duration.zero);
      expect(bloc.state.session!.currentParameters.exposure, equals(1.0));

      // Update 2 (Exposure = 2.0)
      bloc.add(UpdateLight(bloc.state.session!.currentParameters.copyWith(exposure: 2.0)));
      await Future.delayed(Duration.zero);
      expect(bloc.state.session!.currentParameters.exposure, equals(2.0));

      // Test undo to Update 1 (Exposure = 1.0)
      expect(bloc.canUndo, isTrue);
      bloc.undo();
      expect(bloc.state.session!.currentParameters.exposure, equals(1.0));

      // Test undo to initial (Exposure = 0.0)
      bloc.undo();
      expect(bloc.state.session!.currentParameters.exposure, equals(0.0));

      // Test redo back to Update 1 (Exposure = 1.0)
      expect(bloc.canRedo, isTrue);
      bloc.redo();
      expect(bloc.state.session!.currentParameters.exposure, equals(1.0));
    });
  });
}
