import 'package:flutter_test/flutter_test.dart';
import 'package:seed_color/features/presets/domain/entities/preset.dart';
import 'package:seed_color/features/presets/domain/repositories/preset_repository.dart';
import 'package:seed_color/features/presets/presentation/bloc/presets_bloc.dart';
import 'package:seed_color/features/presets/presentation/bloc/presets_event.dart';
import 'package:seed_color/features/presets/presentation/bloc/presets_state.dart';
import 'package:seed_color/features/presets/data/utils/xmp_serializer.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

class MockPresetRepository implements PresetRepository {
  final List<Preset> presets = [
    Preset(
      id: 'p1',
      name: 'Cinema Gold',
      category: 'recommended',
      parameters: EditParameters.identity().copyWith(exposure: 0.5),
      isBookmarked: false,
      createdAt: DateTime(2026, 6, 19),
    ),
    Preset(
      id: 'p2',
      name: 'Velvia 50',
      category: 'premium',
      parameters: EditParameters.identity().copyWith(saturation: 15.0),
      isBookmarked: false,
      createdAt: DateTime(2026, 6, 19),
    ),
    Preset(
      id: 'p3',
      name: 'My Cool Preset',
      category: 'yours',
      parameters: EditParameters.identity().copyWith(contrast: 10.0),
      isBookmarked: false,
      createdAt: DateTime(2026, 6, 19),
    ),
  ];

  bool getPresetsCalled = false;
  bool savePresetCalled = false;
  bool toggleBookmarkCalled = false;
  bool importCalled = false;
  bool exportCalled = false;
  bool deleteCalled = false;

  @override
  Future<List<Preset>> getPresets() async {
    getPresetsCalled = true;
    // Return a copy to avoid mutation side-effects between test runs
    return List.from(presets);
  }

  @override
  Future<Preset> savePreset(String name, String category, EditParameters parameters) async {
    savePresetCalled = true;
    final preset = Preset(
      id: 'new_p',
      name: name,
      category: category,
      parameters: parameters,
      isBookmarked: false,
      createdAt: DateTime.now(),
    );
    presets.add(preset);
    return preset;
  }

  @override
  Future<void> togglePresetBookmark(String id, bool isBookmarked) async {
    toggleBookmarkCalled = true;
    final idx = presets.indexWhere((p) => p.id == id);
    if (idx != -1) {
      presets[idx] = presets[idx].copyWith(isBookmarked: isBookmarked);
    }
  }

  @override
  Future<Preset> importPresetFromXmp(String filePath) async {
    importCalled = true;
    final preset = Preset(
      id: 'imported_p',
      name: 'Imported XMP',
      category: 'yours',
      parameters: EditParameters.identity().copyWith(exposure: -0.5),
      isBookmarked: false,
      createdAt: DateTime.now(),
    );
    presets.add(preset);
    return preset;
  }

  @override
  Future<String> exportPresetToXmp(String presetId, String outputDirectoryPath) async {
    exportCalled = true;
    return '$outputDirectoryPath/preset.xmp';
  }

  @override
  Future<void> deletePreset(String id) async {
    deleteCalled = true;
    presets.removeWhere((p) => p.id == id);
  }
}

void main() {
  group('XmpSerializer Tests', () {
    test('should serialize and deserialize EditParameters correctly', () {
      final originalParams = EditParameters.identity().copyWith(
        exposure: 0.85,
        contrast: 15.0,
        highlights: -20.0,
        shadows: 25.0,
        whites: 5.0,
        blacks: -5.0,
        temperature: 12.0,
        tint: -8.0,
        vibrance: 10.0,
        saturation: 5.0,
        texture: 20.0,
        clarity: 15.0,
        dehaze: 5.0,
        vignette: -10.0,
        grain: 12.0,
        sharpeningAmount: 45.0,
        sharpeningRadius: 1.2,
        sharpeningDetail: 30.0,
        sharpeningMasking: 10.0,
        luminanceNR: 15.0,
        colorNR: 30.0,
        removeChromaticAberration: true,
        enableLensCorrection: true,
      );

      final xml = XmpSerializer.serialize(originalParams, 'Teal Glow');
      expect(xml, contains('crs:Name="Teal Glow"'));
      expect(xml, contains('crs:Exposure2012="0.85"'));
      expect(xml, contains('crs:Contrast2012="15"'));
      expect(xml, contains('crs:LensProfileEnable="True"'));

      final deserialized = XmpSerializer.deserialize(xml);
      expect(deserialized.key, equals('Teal Glow'));
      
      final parsedParams = deserialized.value;
      expect(parsedParams.exposure, closeTo(0.85, 0.001));
      expect(parsedParams.contrast, closeTo(15.0, 0.001));
      expect(parsedParams.highlights, closeTo(-20.0, 0.001));
      expect(parsedParams.shadows, closeTo(25.0, 0.001));
      expect(parsedParams.whites, closeTo(5.0, 0.001));
      expect(parsedParams.blacks, closeTo(-5.0, 0.001));
      expect(parsedParams.temperature, closeTo(12.0, 0.001));
      expect(parsedParams.tint, closeTo(-8.0, 0.001));
      expect(parsedParams.vibrance, closeTo(10.0, 0.001));
      expect(parsedParams.saturation, closeTo(5.0, 0.001));
      expect(parsedParams.texture, closeTo(20.0, 0.001));
      expect(parsedParams.clarity, closeTo(15.0, 0.001));
      expect(parsedParams.dehaze, closeTo(5.0, 0.001));
      expect(parsedParams.vignette, closeTo(-10.0, 0.001));
      expect(parsedParams.grain, closeTo(12.0, 0.001));
      expect(parsedParams.sharpeningAmount, closeTo(45.0, 0.001));
      expect(parsedParams.sharpeningRadius, closeTo(1.2, 0.001));
      expect(parsedParams.sharpeningDetail, closeTo(30.0, 0.001));
      expect(parsedParams.sharpeningMasking, closeTo(10.0, 0.001));
      expect(parsedParams.luminanceNR, closeTo(15.0, 0.001));
      expect(parsedParams.colorNR, closeTo(30.0, 0.001));
      expect(parsedParams.removeChromaticAberration, isTrue);
      expect(parsedParams.enableLensCorrection, isTrue);
    });
  });

  group('PresetsBloc Tests', () {
    late MockPresetRepository mockRepository;
    late PresetsBloc bloc;

    setUp(() {
      mockRepository = MockPresetRepository();
      bloc = PresetsBloc(repository: mockRepository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state should be PresetsInitial', () {
      expect(bloc.state, equals(PresetsInitial()));
    });

    test('LoadPresets event should emit PresetsLoading and PresetsLoaded states', () async {
      final states = <PresetsState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(LoadPresets());
      await Future.delayed(Duration.zero);

      expect(states.length, equals(2));
      expect(states[0], equals(PresetsLoading()));
      
      final loadedState = states[1] as PresetsLoaded;
      expect(loadedState.recommended.length, equals(1));
      expect(loadedState.recommended[0].name, equals('Cinema Gold'));
      expect(loadedState.premium.length, equals(1));
      expect(loadedState.premium[0].name, equals('Velvia 50'));
      expect(loadedState.yours.length, equals(1));
      expect(loadedState.yours[0].name, equals('My Cool Preset'));

      expect(mockRepository.getPresetsCalled, isTrue);
      subscription.cancel();
    });

    test('ToggleBookmark event should update database and reload list', () async {
      final states = <PresetsState>[];
      
      bloc.add(LoadPresets());
      await Future.delayed(Duration.zero);

      final subscription = bloc.stream.listen(states.add);
      bloc.add(const ToggleBookmark(presetId: 'p1', isBookmarked: true));
      await Future.delayed(Duration.zero);

      expect(states.length, equals(1));
      final loadedState = states[0] as PresetsLoaded;
      expect(loadedState.recommended.first.isBookmarked, isTrue);
      expect(mockRepository.toggleBookmarkCalled, isTrue);
      
      subscription.cancel();
    });

    test('SaveCurrentPreset event should save and reload list', () async {
      final states = <PresetsState>[];
      
      bloc.add(LoadPresets());
      await Future.delayed(Duration.zero);

      final subscription = bloc.stream.listen(states.add);
      bloc.add(SaveCurrentPreset(
        name: 'New Custom Preset',
        parameters: EditParameters.identity().copyWith(vignette: -20.0),
      ));
      await Future.delayed(Duration.zero);

      expect(states.length, equals(1));
      final loadedState = states[0] as PresetsLoaded;
      expect(loadedState.yours.length, equals(2));
      expect(loadedState.yours.any((p) => p.name == 'New Custom Preset'), isTrue);
      expect(mockRepository.savePresetCalled, isTrue);

      subscription.cancel();
    });

    test('ImportXmp event should trigger import and reload list', () async {
      final states = <PresetsState>[];
      
      bloc.add(LoadPresets());
      await Future.delayed(Duration.zero);

      final subscription = bloc.stream.listen(states.add);
      bloc.add(const ImportXmp(filePath: 'path/to/preset.xmp'));
      await Future.delayed(Duration.zero);

      expect(states.length, equals(1));
      final loadedState = states[0] as PresetsLoaded;
      expect(loadedState.yours.length, equals(2));
      expect(loadedState.yours.any((p) => p.name == 'Imported XMP'), isTrue);
      expect(mockRepository.importCalled, isTrue);

      subscription.cancel();
    });

    test('ExportXmp event should trigger export', () async {
      final states = <PresetsState>[];
      
      bloc.add(LoadPresets());
      await Future.delayed(Duration.zero);

      final subscription = bloc.stream.listen(states.add);
      bloc.add(const ExportXmp(presetId: 'p1', outputPath: 'downloads'));
      await Future.delayed(Duration.zero);

      expect(states.length, equals(1));
      final loadedState = states[0] as PresetsLoaded;
      expect(loadedState.message, contains('downloads/preset.xmp'));
      expect(mockRepository.exportCalled, isTrue);

      subscription.cancel();
    });

    test('DeletePresetEvent event should remove custom preset and reload list', () async {
      final states = <PresetsState>[];
      
      bloc.add(LoadPresets());
      await Future.delayed(Duration.zero);

      final subscription = bloc.stream.listen(states.add);
      bloc.add(const DeletePresetEvent(presetId: 'p3'));
      await Future.delayed(Duration.zero);

      expect(states.length, equals(1));
      final loadedState = states[0] as PresetsLoaded;
      expect(loadedState.yours.isEmpty, isTrue);
      expect(mockRepository.deleteCalled, isTrue);

      subscription.cancel();
    });
  });
}
