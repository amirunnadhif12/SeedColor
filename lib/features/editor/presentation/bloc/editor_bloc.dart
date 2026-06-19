import 'package:replay_bloc/replay_bloc.dart';
import '../../domain/repositories/editor_repository.dart';
import '../../domain/usecases/apply_adjustments.dart';
import '../../domain/usecases/apply_curves.dart';
import '../../domain/usecases/apply_hsl.dart';
import '../../domain/usecases/export_image.dart';
import '../../domain/usecases/reset_adjustments.dart';
import 'editor_event.dart';
import 'editor_state.dart';

/// 🌱 SeedColor — Editor BLoC
///
/// Logika bisnis dan State Management untuk editor foto.
/// Mewarisi [ReplayBloc] untuk mendukung fitur undo (batal) dan redo (ulangi) otomatis
/// berdasarkan riwayat emisi state.
class EditorBloc extends ReplayBloc<EditorEvent, EditorState> {
  final EditorRepository repository;
  final ApplyAdjustments applyAdjustments;
  final ApplyCurves applyCurves;
  final ApplyHsl applyHsl;
  final ResetAdjustments resetAdjustments;
  final ExportImage exportImage;

  EditorBloc({
    required this.repository,
    required this.applyAdjustments,
    required this.applyCurves,
    required this.applyHsl,
    required this.resetAdjustments,
    required this.exportImage,
  }) : super(EditorState.initial()) {
    on<StartSession>(_onStartSession);
    on<UpdateLight>(_onUpdateLight);
    on<UpdateColor>(_onUpdateColor);
    on<UpdateHSL>(_onUpdateHSL);
    on<UpdateCurves>(_onUpdateCurves);
    on<UpdateEffects>(_onUpdateEffects);
    on<UpdateColorGrading>(_onUpdateColorGrading);
    on<ResetAll>(_onResetAll);
    on<Export>(_onExport);
  }

  Future<void> _onStartSession(
    StartSession event,
    Emitter<EditorState> emit,
  ) async {
    emit(state.copyWith(
      isProcessing: true,
      clearFailure: true,
      clearExportPath: true,
    ));

    final result = await repository.startSession(
      event.photoId,
      event.imagePath,
    );

    result.fold(
      (failure) => emit(state.copyWith(isProcessing: false, failure: failure)),
      (session) => emit(state.copyWith(isProcessing: false, session: session)),
    );
  }

  void _onUpdateLight(UpdateLight event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  void _onUpdateColor(UpdateColor event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  void _onUpdateHSL(UpdateHSL event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = applyHsl(
      session,
      colorChannel: event.colorChannel,
      adjustment: event.adjustment,
    );
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  void _onUpdateCurves(UpdateCurves event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = applyCurves(
      session,
      channel: event.channel,
      points: event.points,
    );
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  void _onUpdateEffects(UpdateEffects event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  void _onUpdateColorGrading(
    UpdateColorGrading event,
    Emitter<EditorState> emit,
  ) {
    final session = state.session;
    if (session == null) return;

    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  void _onResetAll(ResetAll event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = resetAdjustments(session);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) => emit(state.copyWith(session: updatedSession)),
    );
  }

  Future<void> _onExport(Export event, Emitter<EditorState> emit) async {
    final session = state.session;
    if (session == null) return;

    emit(state.copyWith(
      isProcessing: true,
      clearFailure: true,
      clearExportPath: true,
    ));

    final result = await exportImage(
      session,
      outputPath: event.outputPath,
      quality: event.quality,
    );

    result.fold(
      (failure) => emit(state.copyWith(isProcessing: false, failure: failure)),
      (path) => emit(state.copyWith(
        isProcessing: false,
        exportedImagePath: path,
      )),
    );
  }
}
