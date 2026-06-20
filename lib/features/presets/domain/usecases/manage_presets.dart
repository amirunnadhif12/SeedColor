import '../../../editor/domain/entities/edit_parameters.dart';
import '../entities/preset.dart';
import '../repositories/preset_repository.dart';

class GetPresets {
  final PresetRepository repository;
  GetPresets(this.repository);

  Future<List<Preset>> call() => repository.getPresets();
}

class SaveCustomPreset {
  final PresetRepository repository;
  SaveCustomPreset(this.repository);

  Future<Preset> call(String name, EditParameters parameters) {
    return repository.savePreset(name, 'yours', parameters);
  }
}

class ImportPresetFromXmp {
  final PresetRepository repository;
  ImportPresetFromXmp(this.repository);

  Future<Preset> call(String filePath) => repository.importPresetFromXmp(filePath);
}

class ExportPresetToXmp {
  final PresetRepository repository;
  ExportPresetToXmp(this.repository);

  Future<String> call(String presetId, String outputDirectoryPath) {
    return repository.exportPresetToXmp(presetId, outputDirectoryPath);
  }
}

class TogglePresetBookmark {
  final PresetRepository repository;
  TogglePresetBookmark(this.repository);

  Future<void> call(String id, bool isBookmarked) {
    return repository.togglePresetBookmark(id, isBookmarked);
  }
}

class DeletePreset {
  final PresetRepository repository;
  DeletePreset(this.repository);

  Future<void> call(String id) => repository.deletePreset(id);
}
