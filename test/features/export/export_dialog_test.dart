import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:seed_color/features/export/presentation/widgets/export_dialog.dart';

class MockEditorRepository implements EditorRepository {
  bool exportCalled = false;
  String? formatPassed;
  int? qualityPassed;
  double? scalePassed;

  @override
  Future<Either<Failure, EditSession>> startSession(String photoId, String imagePath) async {
    return Right(EditSession(
      photoId: photoId,
      imagePath: imagePath,
      currentParameters: EditParameters.identity(),
      originalWidth: 100,
      originalHeight: 100,
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
    qualityPassed = quality;
    scalePassed = scale;
    return Right(outputPath);
  }
}

void main() {
  late MockEditorRepository mockRepository;
  late EditorBloc bloc;
  late EditSession mockSession;

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
    mockSession = EditSession(
      photoId: 'photo_test',
      imagePath: 'assets/images/mountain_lake.png',
      currentParameters: EditParameters.identity(),
      originalWidth: 100,
      originalHeight: 100,
      createdAt: DateTime.now(),
    );
  });

  tearDown(() {
    bloc.close();
  });

  Widget createWidgetUnderTesting() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<EditorBloc>.value(
          value: bloc,
          child: ExportDialog(session: mockSession),
        ),
      ),
    );
  }

  testWidgets('should render all basic UI components of ExportDialog', (tester) async {
    await tester.pumpWidget(createWidgetUnderTesting());
    await tester.pumpAndSettle();

    // Verify title and headers
    expect(find.text('Ekspor Foto'), findsOneWidget);
    expect(find.text('FORMAT GAMBAR'), findsOneWidget);
    expect(find.text('UKURAN OUTPUT'), findsOneWidget);
    expect(find.text('JALUR BERKAS KELUARAN'), findsOneWidget);

    // Verify action buttons
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Ekspor'), findsOneWidget);
  });

  testWidgets('should show quality slider only when format is JPEG', (tester) async {
    await tester.pumpWidget(createWidgetUnderTesting());
    await tester.pumpAndSettle();

    // By default, format is JPEG. Quality slider should be visible
    expect(find.text('KUALITAS KOMPRESI'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    // Switch to PNG
    await tester.tap(find.text('PNG (Lossless)'));
    await tester.pumpAndSettle();

    // Quality slider should now be hidden
    expect(find.text('KUALITAS KOMPRESI'), findsNothing);
    expect(find.byType(Slider), findsNothing);

    // Switch back to JPEG
    await tester.tap(find.text('JPEG'));
    await tester.pumpAndSettle();

    // Quality slider should be visible again
    expect(find.text('KUALITAS KOMPRESI'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
