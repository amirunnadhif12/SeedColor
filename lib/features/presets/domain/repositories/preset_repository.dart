import '../../../editor/domain/entities/edit_parameters.dart';
import '../../domain/entities/preset.dart';

abstract class PresetRepository {
  Future<List<Preset>> getPresets();
  Future<Preset> savePreset(String name, String category, EditParameters parameters);
  Future<void> togglePresetBookmark(String id, bool isBookmarked);
  Future<void> deletePreset(String id);
  Future<Preset> importPresetFromXmp(String filePath);
  Future<String> exportPresetToXmp(String presetId, String outputDirectoryPath);
}
