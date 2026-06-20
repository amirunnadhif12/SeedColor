import 'package:equatable/equatable.dart';
import '../../../../features/editor/domain/entities/edit_parameters.dart';

abstract class PresetsEvent extends Equatable {
  const PresetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPresets extends PresetsEvent {}

class ToggleBookmark extends PresetsEvent {
  final String presetId;
  final bool isBookmarked;

  const ToggleBookmark({required this.presetId, required this.isBookmarked});

  @override
  List<Object?> get props => [presetId, isBookmarked];
}

class SaveCurrentPreset extends PresetsEvent {
  final String name;
  final EditParameters parameters;

  const SaveCurrentPreset({required this.name, required this.parameters});

  @override
  List<Object?> get props => [name, parameters];
}

class ImportXmp extends PresetsEvent {
  final String filePath;

  const ImportXmp({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class ExportXmp extends PresetsEvent {
  final String presetId;
  final String outputPath;

  const ExportXmp({required this.presetId, required this.outputPath});

  @override
  List<Object?> get props => [presetId, outputPath];
}

class DeletePresetEvent extends PresetsEvent {
  final String presetId;

  const DeletePresetEvent({required this.presetId});

  @override
  List<Object?> get props => [presetId];
}
