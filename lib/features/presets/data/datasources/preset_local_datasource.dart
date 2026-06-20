import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';

abstract class PresetLocalDataSource {
  Future<List<PresetData>> getAllPresets();
  Future<void> insertPreset(PresetData preset);
  Future<void> togglePresetBookmark(String id, bool isBookmarked);
  Future<void> deletePreset(String id);
  Future<PresetData?> getPresetById(String id);
}

class PresetLocalDataSourceImpl implements PresetLocalDataSource {
  final AppDatabase database;

  PresetLocalDataSourceImpl(this.database);

  @override
  Future<List<PresetData>> getAllPresets() {
    return (database.select(database.presetsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  @override
  Future<void> insertPreset(PresetData preset) {
    return database.into(database.presetsTable).insert(preset, mode: InsertMode.insertOrReplace);
  }

  @override
  Future<void> togglePresetBookmark(String id, bool isBookmarked) {
    return (database.update(database.presetsTable)..where((t) => t.id.equals(id)))
        .write(PresetsTableCompanion(isBookmarked: Value(isBookmarked)));
  }

  @override
  Future<void> deletePreset(String id) {
    return (database.delete(database.presetsTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<PresetData?> getPresetById(String id) {
    return (database.select(database.presetsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }
}
