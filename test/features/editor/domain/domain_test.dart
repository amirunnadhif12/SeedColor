import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/core/errors/either.dart';
import 'package:seed_color/core/errors/failures.dart';
import 'package:seed_color/features/editor/domain/entities/curve_data.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';
import 'package:seed_color/features/editor/domain/entities/edit_session.dart';
import 'package:seed_color/features/editor/domain/entities/hsl_adjustments.dart';
import 'package:seed_color/features/editor/domain/repositories/editor_repository.dart';
import 'package:seed_color/features/editor/domain/usecases/apply_adjustments.dart';
import 'package:seed_color/features/editor/domain/usecases/apply_curves.dart';
import 'package:seed_color/features/editor/domain/usecases/apply_hsl.dart';
import 'package:seed_color/features/editor/domain/usecases/export_image.dart';
import 'package:seed_color/features/editor/domain/usecases/reset_adjustments.dart';

// Mock Repository untuk pengujian
class MockEditorRepository implements EditorRepository {
  bool exportImageCalled = false;
  EditSession? lastExportedSession;

  @override
  Future<Either<Failure, String>> exportImage(
    EditSession session, {
    required String outputPath,
    required int quality,
  }) async {
    exportImageCalled = true;
    lastExportedSession = session;
    return Right(outputPath);
  }

  @override
  Future<Either<Failure, EditSession>> getSession(String photoId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> saveSession(EditSession session) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, EditSession>> startSession(
    String photoId,
    String imagePath,
  ) async {
    throw UnimplementedError();
  }
}

void main() {
  late EditSession tSession;
  late MockEditorRepository mockRepository;

  setUp(() {
    tSession = EditSession(
      photoId: 'test_123',
      imagePath: 'path/to/test.jpg',
      currentParameters: EditParameters.identity(),
      originalWidth: 1920,
      originalHeight: 1080,
      createdAt: DateTime(2026, 6, 19),
    );
    mockRepository = MockEditorRepository();
  });

  group('HslAdjustments & HslColorAdjustment', () {
    test('should support value equality and copyWith', () {
      const adj1 = HslColorAdjustment(hue: 10, saturation: -20, lightness: 30);
      const adj2 = HslColorAdjustment(hue: 10, saturation: -20, lightness: 30);
      expect(adj1, equals(adj2));

      final adj3 = adj1.copyWith(hue: 15);
      expect(adj3.hue, equals(15.0));
      expect(adj3.saturation, equals(-20.0));

      const hsl1 = HslAdjustments(red: adj1);
      const hsl2 = HslAdjustments(red: adj2);
      expect(hsl1, equals(hsl2));

      final hsl3 = hsl1.copyWith(orange: const HslColorAdjustment(saturation: 50));
      expect(hsl3.red.hue, equals(10.0));
      expect(hsl3.orange.saturation, equals(50.0));
    });
  });

  group('CurveData', () {
    test('should construct standard identity', () {
      final curve = CurveData.identity();
      expect(curve.rgb, equals([const math.Point(0.0, 0.0), const math.Point(1.0, 1.0)]));
      expect(curve.red, equals([const math.Point(0.0, 0.0), const math.Point(1.0, 1.0)]));
    });

    test('should add point safely, avoiding horizontal overlap and clamping coordinates', () {
      final curve = CurveData.identity();
      final updated = curve.addPoint('red', const math.Point(0.5, 0.4));
      
      // Points should be sorted and red channel should have 3 points
      expect(updated.red.length, equals(3));
      expect(updated.red[1], equals(const math.Point(0.5, 0.4)));

      // Try adding another point too close (within 0.02)
      final tooClose = updated.addPoint('red', const math.Point(0.51, 0.8));
      expect(tooClose.red.length, equals(3)); // unchanged
    });

    test('should update point, keeping endpoints locked on x-axis', () {
      final curve = CurveData.identity();
      
      // Try to update index 0 (endpoint left)
      final updatedLeft = curve.updatePoint('red', 0, const math.Point(0.2, 0.1));
      expect(updatedLeft.red[0].x, equals(0.0)); // X must remain 0.0
      expect(updatedLeft.red[0].y, equals(0.1)); // Y can change

      // Try to update index 1 (endpoint right)
      final updatedRight = curve.updatePoint('red', 1, const math.Point(0.8, 0.9));
      expect(updatedRight.red[1].x, equals(1.0)); // X must remain 1.0
      expect(updatedRight.red[1].y, equals(0.9)); // Y can change
    });

    test('should remove intermediate points but lock endpoints', () {
      final curve = CurveData.identity().addPoint('red', const math.Point(0.5, 0.5));
      expect(curve.red.length, equals(3));

      // Remove intermediate index 1
      final removed = curve.removePoint('red', 1);
      expect(removed.red.length, equals(2));

      // Try to remove endpoint index 0
      final triedEndpoint = removed.removePoint('red', 0);
      expect(triedEndpoint.red.length, equals(2)); // unchanged
    });
  });

  group('EditParameters', () {
    test('should support value equality and copyWith', () {
      final params1 = EditParameters.identity();
      final params2 = EditParameters.identity();
      expect(params1, equals(params2));

      final params3 = params1.copyWith(exposure: 1.5);
      expect(params3.exposure, equals(1.5));
      expect(params3.contrast, equals(0.0));
    });
  });

  group('Use Cases', () {
    test('ApplyAdjustments should update session parameters', () {
      final usecase = ApplyAdjustments();
      final newParams = tSession.currentParameters.copyWith(exposure: 1.0, contrast: 25.0);
      
      final result = usecase(tSession, newParams);
      expect(result.isRight, isTrue);
      expect(result.rightOrNull!.currentParameters.exposure, equals(1.0));
      expect(result.rightOrNull!.currentParameters.contrast, equals(25.0));
    });

    test('ApplyCurves should update curves correctly', () {
      final usecase = ApplyCurves();
      final newPoints = [const math.Point(0.0, 0.0), const math.Point(0.5, 0.6), const math.Point(1.0, 1.0)];
      
      final result = usecase(tSession, channel: 'red', points: newPoints);
      expect(result.isRight, isTrue);
      expect(result.rightOrNull!.currentParameters.curveData.red, equals(newPoints));
    });

    test('ApplyHsl should update color HSL shifts', () {
      final usecase = ApplyHsl();
      const adjustment = HslColorAdjustment(hue: 20, saturation: -30);
      
      final result = usecase(tSession, colorChannel: 'red', adjustment: adjustment);
      expect(result.isRight, isTrue);
      expect(result.rightOrNull!.currentParameters.hslAdjustments.red, equals(adjustment));
    });

    test('ResetAdjustments should revert to identity', () {
      final usecase = ResetAdjustments();
      final customizedSession = tSession.copyWith(
        currentParameters: tSession.currentParameters.copyWith(exposure: 2.0, contrast: -10.0),
      );
      
      final result = usecase(customizedSession);
      expect(result.isRight, isTrue);
      expect(result.rightOrNull!.currentParameters.exposure, equals(0.0));
      expect(result.rightOrNull!.currentParameters.contrast, equals(0.0));
    });

    test('ExportImage should delegate call to repository', () async {
      final usecase = ExportImage(mockRepository);
      const outputPath = 'exports/photo1.jpg';
      
      final result = await usecase(tSession, outputPath: outputPath, quality: 90);
      expect(result.isRight, isTrue);
      expect(result.rightOrNull, equals(outputPath));
      expect(mockRepository.exportImageCalled, isTrue);
      expect(mockRepository.lastExportedSession, equals(tSession));
    });
  });
}
