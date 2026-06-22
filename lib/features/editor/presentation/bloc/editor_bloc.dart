import 'package:replay_bloc/replay_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/edit_parameters.dart';
import '../../domain/entities/edit_session.dart';
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
  final _uuid = const Uuid();

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
    on<UpdateDetail>(_onUpdateDetail);
    on<UpdateOptics>(_onUpdateOptics);
    on<UpdateGeometry>(_onUpdateGeometry);
    on<ResetAll>(_onResetAll);
    on<Export>(_onExport);
    on<ApplyPreset>(_onApplyPreset);
    on<NavigateHistory>(_onNavigateHistory);
    on<CreateSnapshot>(_onCreateSnapshot);
    on<ApplySnapshot>(_onApplySnapshot);
    on<DeleteSnapshot>(_onDeleteSnapshot);
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
      (session) {
        final entry = HistoryEntry(
          id: _uuid.v4(),
          label: 'Impor Foto',
          parameters: session.currentParameters,
          timestamp: DateTime.now(),
        );
        emit(state.copyWith(
          isProcessing: false,
          session: session,
          history: [entry],
          currentHistoryIndex: 0,
        ));
      },
    );
  }

  void _onUpdateLight(UpdateLight event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onUpdateColor(UpdateColor event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
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
      (updatedSession) {
        final label = 'HSL Mixer: ${event.colorChannel[0].toUpperCase()}${event.colorChannel.substring(1)}';
        _addHistoryState(emit, updatedSession, label);
      },
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
      (updatedSession) {
        final label = 'Kurva Warna: ${event.channel.toUpperCase()}';
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onUpdateEffects(UpdateEffects event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onUpdateColorGrading(
    UpdateColorGrading event,
    Emitter<EditorState> emit,
  ) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onUpdateDetail(UpdateDetail event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onUpdateOptics(UpdateOptics event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onUpdateGeometry(UpdateGeometry event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final oldParams = session.currentParameters;
    final result = applyAdjustments(session, event.parameters);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        final label = _getAdjustmentDiffLabel(oldParams, updatedSession.currentParameters);
        _addHistoryState(emit, updatedSession, label);
      },
    );
  }

  void _onResetAll(ResetAll event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final result = resetAdjustments(session);
    result.fold(
      (failure) => emit(state.copyWith(failure: failure)),
      (updatedSession) {
        _addHistoryState(emit, updatedSession, 'Reset Semua Pengaturan');
      },
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
      format: event.format,
      scale: event.scale,
    );

    result.fold(
      (failure) => emit(state.copyWith(isProcessing: false, failure: failure)),
      (path) => emit(state.copyWith(
        isProcessing: false,
        exportedImagePath: path,
      )),
    );
  }

  void _onApplyPreset(ApplyPreset event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final updatedSession = session.copyWith(currentParameters: event.parameters);
    _addHistoryState(emit, updatedSession, 'Terapkan Preset');
  }

  void _onNavigateHistory(NavigateHistory event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null || event.index < 0 || event.index >= state.history.length) return;

    final entry = state.history[event.index];
    final updatedSession = session.copyWith(currentParameters: entry.parameters);

    emit(state.copyWith(
      session: updatedSession,
      currentHistoryIndex: event.index,
    ));
  }

  void _onCreateSnapshot(CreateSnapshot event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final snapshot = NamedSnapshot(
      id: _uuid.v4(),
      name: event.name.trim().isEmpty ? 'Snapshot Kustom' : event.name,
      parameters: session.currentParameters,
      createdAt: DateTime.now(),
    );

    final updatedSnapshots = [...state.snapshots, snapshot];
    final currentHistory = List<HistoryEntry>.from(state.history);
    final currentIndex = state.currentHistoryIndex;
    final truncatedHistory = (currentIndex >= 0 && currentIndex < currentHistory.length - 1)
        ? currentHistory.sublist(0, currentIndex + 1)
        : currentHistory;

    final entry = HistoryEntry(
      id: _uuid.v4(),
      label: 'Buat Snapshot "${snapshot.name}"',
      parameters: session.currentParameters,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      snapshots: updatedSnapshots,
      history: [...truncatedHistory, entry],
      currentHistoryIndex: truncatedHistory.length,
    ));
  }

  void _onApplySnapshot(ApplySnapshot event, Emitter<EditorState> emit) {
    final session = state.session;
    if (session == null) return;

    final updatedSession = session.copyWith(currentParameters: event.snapshot.parameters);

    final currentHistory = List<HistoryEntry>.from(state.history);
    final currentIndex = state.currentHistoryIndex;
    final truncatedHistory = (currentIndex >= 0 && currentIndex < currentHistory.length - 1)
        ? currentHistory.sublist(0, currentIndex + 1)
        : currentHistory;

    final entry = HistoryEntry(
      id: _uuid.v4(),
      label: 'Terapkan Snapshot "${event.snapshot.name}"',
      parameters: event.snapshot.parameters,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      session: updatedSession,
      history: [...truncatedHistory, entry],
      currentHistoryIndex: truncatedHistory.length,
    ));
  }

  void _onDeleteSnapshot(DeleteSnapshot event, Emitter<EditorState> emit) {
    final updatedSnapshots = state.snapshots.where((s) => s.id != event.id).toList();
    emit(state.copyWith(snapshots: updatedSnapshots));
  }

  void _addHistoryState(Emitter<EditorState> emit, EditSession updatedSession, String label) {
    final currentHistory = List<HistoryEntry>.from(state.history);
    final currentIndex = state.currentHistoryIndex;

    // Potong riwayat jika pengguna berada di langkah masa lalu saat melakukan edit baru
    final truncatedHistory = (currentIndex >= 0 && currentIndex < currentHistory.length - 1)
        ? currentHistory.sublist(0, currentIndex + 1)
        : currentHistory;

    final entry = HistoryEntry(
      id: _uuid.v4(),
      label: label,
      parameters: updatedSession.currentParameters,
      timestamp: DateTime.now(),
    );

    emit(state.copyWith(
      session: updatedSession,
      history: [...truncatedHistory, entry],
      currentHistoryIndex: truncatedHistory.length,
    ));
  }

  String _getAdjustmentDiffLabel(EditParameters oldParams, EditParameters newParams) {
    // 1. Light
    if (oldParams.exposure != newParams.exposure) {
      return 'Pencahayaan ${newParams.exposure >= 0 ? '+' : ''}${newParams.exposure.toStringAsFixed(2)}';
    }
    if (oldParams.contrast != newParams.contrast) {
      return 'Kontras ${newParams.contrast >= 0 ? '+' : ''}${newParams.contrast.round()}';
    }
    if (oldParams.highlights != newParams.highlights) {
      return 'Highlights ${newParams.highlights >= 0 ? '+' : ''}${newParams.highlights.round()}';
    }
    if (oldParams.shadows != newParams.shadows) {
      return 'Shadows ${newParams.shadows >= 0 ? '+' : ''}${newParams.shadows.round()}';
    }
    if (oldParams.whites != newParams.whites) {
      return 'Whites ${newParams.whites >= 0 ? '+' : ''}${newParams.whites.round()}';
    }
    if (oldParams.blacks != newParams.blacks) {
      return 'Blacks ${newParams.blacks >= 0 ? '+' : ''}${newParams.blacks.round()}';
    }

    // 2. Color
    if (oldParams.temperature != newParams.temperature) {
      return 'Temperatur ${newParams.temperature >= 0 ? '+' : ''}${newParams.temperature.round()}';
    }
    if (oldParams.tint != newParams.tint) {
      return 'Corak (Tint) ${newParams.tint >= 0 ? '+' : ''}${newParams.tint.round()}';
    }
    if (oldParams.vibrance != newParams.vibrance) {
      return 'Vibrance ${newParams.vibrance >= 0 ? '+' : ''}${newParams.vibrance.round()}';
    }
    if (oldParams.saturation != newParams.saturation) {
      return 'Saturasi ${newParams.saturation >= 0 ? '+' : ''}${newParams.saturation.round()}';
    }

    // 3. Effects
    if (oldParams.texture != newParams.texture) {
      return 'Tekstur ${newParams.texture >= 0 ? '+' : ''}${newParams.texture.round()}';
    }
    if (oldParams.clarity != newParams.clarity) {
      return 'Kejernihan (Clarity) ${newParams.clarity >= 0 ? '+' : ''}${newParams.clarity.round()}';
    }
    if (oldParams.dehaze != newParams.dehaze) {
      return 'Dehaze ${newParams.dehaze >= 0 ? '+' : ''}${newParams.dehaze.round()}';
    }
    if (oldParams.vignette != newParams.vignette) {
      return 'Vignette ${newParams.vignette >= 0 ? '+' : ''}${newParams.vignette.round()}';
    }
    if (oldParams.grain != newParams.grain) {
      return 'Grain ${newParams.grain.round()}';
    }

    // 4. Detail
    if (oldParams.sharpeningAmount != newParams.sharpeningAmount) {
      return 'Penajaman ${newParams.sharpeningAmount.round()}';
    }
    if (oldParams.sharpeningRadius != newParams.sharpeningRadius) {
      return 'Radius Penajaman ${newParams.sharpeningRadius.toStringAsFixed(1)}';
    }
    if (oldParams.sharpeningDetail != newParams.sharpeningDetail) {
      return 'Detail Penajaman ${newParams.sharpeningDetail.round()}';
    }
    if (oldParams.sharpeningMasking != newParams.sharpeningMasking) {
      return 'Masking Penajaman ${newParams.sharpeningMasking.round()}';
    }
    if (oldParams.luminanceNR != newParams.luminanceNR) {
      return 'Reduksi Noise Luminance ${newParams.luminanceNR.round()}';
    }
    if (oldParams.colorNR != newParams.colorNR) {
      return 'Reduksi Noise Warna ${newParams.colorNR.round()}';
    }

    // 5. Optics
    if (oldParams.removeChromaticAberration != newParams.removeChromaticAberration) {
      return newParams.removeChromaticAberration ? 'Hapus Aberasi Kromatik Aktif' : 'Hapus Aberasi Kromatik Nonaktif';
    }
    if (oldParams.enableLensCorrection != newParams.enableLensCorrection) {
      return newParams.enableLensCorrection ? 'Koreksi Lensa Aktif' : 'Koreksi Lensa Nonaktif';
    }

    // 6. Geometry
    if (oldParams.rotation != newParams.rotation) {
      return 'Rotasi ${newParams.rotation.toStringAsFixed(1)}°';
    }
    if (oldParams.perspectiveHorizontal != newParams.perspectiveHorizontal) {
      return 'Perspektif Horizontal ${newParams.perspectiveHorizontal >= 0 ? '+' : ''}${newParams.perspectiveHorizontal.round()}';
    }
    if (oldParams.perspectiveVertical != newParams.perspectiveVertical) {
      return 'Perspektif Vertikal ${newParams.perspectiveVertical >= 0 ? '+' : ''}${newParams.perspectiveVertical.round()}';
    }
    if (oldParams.flipHorizontal != newParams.flipHorizontal) {
      return 'Balik Horizontal';
    }
    if (oldParams.flipVertical != newParams.flipVertical) {
      return 'Balik Vertikal';
    }
    if (oldParams.cropLeft != newParams.cropLeft ||
        oldParams.cropTop != newParams.cropTop ||
        oldParams.cropRight != newParams.cropRight ||
        oldParams.cropBottom != newParams.cropBottom ||
        oldParams.aspectRatio != newParams.aspectRatio) {
      return 'Crop: ${newParams.aspectRatio}';
    }

    // 7. Color Grading
    if (oldParams.shadowsHue != newParams.shadowsHue || oldParams.shadowsSat != newParams.shadowsSat) {
      return 'Color Grading: Shadows';
    }
    if (oldParams.midtonesHue != newParams.midtonesHue || oldParams.midtonesSat != newParams.midtonesSat) {
      return 'Color Grading: Midtones';
    }
    if (oldParams.highlightsHue != newParams.highlightsHue || oldParams.highlightsSat != newParams.highlightsSat) {
      return 'Color Grading: Highlights';
    }
    if (oldParams.cgBlending != newParams.cgBlending) {
      return 'Color Grading: Blending ${newParams.cgBlending.round()}';
    }
    if (oldParams.cgBalance != newParams.cgBalance) {
      return 'Color Grading: Balance ${newParams.cgBalance.round()}';
    }

    // 8. HSL
    if (oldParams.hslAdjustments != newParams.hslAdjustments) {
      return 'HSL Color Mixer';
    }

    // 9. Curves
    if (oldParams.curveData != newParams.curveData) {
      return 'Kurva Warna';
    }

    return 'Edit Parameter';
  }
}
