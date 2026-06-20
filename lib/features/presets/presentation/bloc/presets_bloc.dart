import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/preset_repository.dart';
import 'presets_event.dart';
import 'presets_state.dart';

class PresetsBloc extends Bloc<PresetsEvent, PresetsState> {
  final PresetRepository repository;

  PresetsBloc({required this.repository}) : super(PresetsInitial()) {
    on<LoadPresets>(_onLoadPresets);
    on<ToggleBookmark>(_onToggleBookmark);
    on<SaveCurrentPreset>(_onSaveCurrentPreset);
    on<ImportXmp>(_onImportXmp);
    on<ExportXmp>(_onExportXmp);
    on<DeletePresetEvent>(_onDeletePreset);
  }

  Future<void> _onLoadPresets(LoadPresets event, Emitter<PresetsState> emit) async {
    emit(PresetsLoading());
    try {
      final list = await repository.getPresets();
      final rec = list.where((p) => p.category == 'recommended').toList();
      final prem = list.where((p) => p.category == 'premium').toList();
      final yours = list.where((p) => p.category == 'yours').toList();

      emit(PresetsLoaded(recommended: rec, premium: prem, yours: yours));
    } catch (e) {
      emit(PresetsError(errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleBookmark(ToggleBookmark event, Emitter<PresetsState> emit) async {
    if (state is PresetsLoaded) {
      try {
        await repository.togglePresetBookmark(event.presetId, event.isBookmarked);
        await _reloadPresetsQuietly(emit);
      } catch (e) {
        emit(PresetsError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onSaveCurrentPreset(SaveCurrentPreset event, Emitter<PresetsState> emit) async {
    if (state is PresetsLoaded) {
      try {
        await repository.savePreset(event.name, 'yours', event.parameters);
        await _reloadPresetsQuietly(emit, message: 'Preset "${event.name}" saved successfully');
      } catch (e) {
        emit(PresetsError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onImportXmp(ImportXmp event, Emitter<PresetsState> emit) async {
    if (state is PresetsLoaded) {
      try {
        final preset = await repository.importPresetFromXmp(event.filePath);
        await _reloadPresetsQuietly(emit, message: 'Preset "${preset.name}" imported successfully');
      } catch (e) {
        emit(PresetsError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onExportXmp(ExportXmp event, Emitter<PresetsState> emit) async {
    if (state is PresetsLoaded) {
      try {
        final path = await repository.exportPresetToXmp(event.presetId, event.outputPath);
        await _reloadPresetsQuietly(emit, message: 'Preset exported to $path');
      } catch (e) {
        emit(PresetsError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _onDeletePreset(DeletePresetEvent event, Emitter<PresetsState> emit) async {
    if (state is PresetsLoaded) {
      try {
        await repository.deletePreset(event.presetId);
        await _reloadPresetsQuietly(emit, message: 'Preset deleted');
      } catch (e) {
        emit(PresetsError(errorMessage: e.toString()));
      }
    }
  }

  Future<void> _reloadPresetsQuietly(Emitter<PresetsState> emit, {String? message}) async {
    final list = await repository.getPresets();
    final rec = list.where((p) => p.category == 'recommended').toList();
    final prem = list.where((p) => p.category == 'premium').toList();
    final yours = list.where((p) => p.category == 'yours').toList();

    emit(PresetsLoaded(recommended: rec, premium: prem, yours: yours, message: message));
  }
}
