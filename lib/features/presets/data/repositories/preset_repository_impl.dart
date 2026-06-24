import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../editor/domain/entities/curve_data.dart';
import '../../../editor/domain/entities/edit_parameters.dart';
import '../../../editor/domain/entities/hsl_adjustments.dart';
import '../../domain/entities/preset.dart';
import '../../domain/repositories/preset_repository.dart';
import '../datasources/preset_local_datasource.dart';
import '../utils/xmp_serializer.dart';
import '../../../../core/database/app_database.dart';

class PresetRepositoryImpl implements PresetRepository {
  final PresetLocalDataSource localDataSource;
  final _uuid = const Uuid();

  PresetRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Preset>> getPresets() async {
    var datas = await localDataSource.getAllPresets();

    // Seed built-in presets if database is completely empty
    if (datas.isEmpty) {
      await _seedBuiltInPresets();
      datas = await localDataSource.getAllPresets();
    }

    return datas.map(_mapDataToEntity).toList();
  }

  @override
  Future<Preset> savePreset(String name, String category, EditParameters parameters) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final jsonStr = jsonEncode(_parametersToMap(parameters));

    final presetData = PresetData(
      id: id,
      name: name,
      category: category,
      parametersJson: jsonStr,
      isBookmarked: false,
      createdAt: now,
    );

    await localDataSource.insertPreset(presetData);
    return Preset(
      id: id,
      name: name,
      category: category,
      parameters: parameters,
      isBookmarked: false,
      createdAt: now,
    );
  }

  @override
  Future<void> togglePresetBookmark(String id, bool isBookmarked) {
    return localDataSource.togglePresetBookmark(id, isBookmarked);
  }

  @override
  Future<void> deletePreset(String id) {
    return localDataSource.deletePreset(id);
  }

  @override
  Future<Preset> importPresetFromXmp(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Preset file does not exist at $filePath');
    }

    final xmlContent = await file.readAsString();
    final entry = XmpSerializer.deserialize(xmlContent);

    final id = _uuid.v4();
    final now = DateTime.now();
    final jsonStr = jsonEncode(_parametersToMap(entry.value));

    final presetData = PresetData(
      id: id,
      name: entry.key,
      category: 'yours',
      parametersJson: jsonStr,
      isBookmarked: false,
      createdAt: now,
    );

    await localDataSource.insertPreset(presetData);
    return Preset(
      id: id,
      name: entry.key,
      category: 'yours',
      parameters: entry.value,
      isBookmarked: false,
      createdAt: now,
    );
  }

  @override
  Future<String> exportPresetToXmp(String presetId, String outputDirectoryPath) async {
    final presetData = await localDataSource.getPresetById(presetId);
    if (presetData == null) {
      throw Exception('Preset not found in database');
    }

    final params = _mapToParameters(jsonDecode(presetData.parametersJson));
    final xmlContent = XmpSerializer.serialize(params, presetData.name);

    final dir = Directory(outputDirectoryPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Clean preset name for safe filename
    final safeName = presetData.name.replaceAll(RegExp(r'[^\w\s\-]'), '').trim().replaceAll(' ', '_');
    final targetPath = p.join(dir.path, '$safeName.xmp');

    final file = File(targetPath);
    await file.writeAsString(xmlContent);
    return targetPath;
  }

  Preset _mapDataToEntity(PresetData data) {
    final Map<String, dynamic> map = jsonDecode(data.parametersJson);
    return Preset(
      id: data.id,
      name: data.name,
      category: data.category,
      parameters: _mapToParameters(map),
      isBookmarked: data.isBookmarked,
      createdAt: data.createdAt,
    );
  }

  Future<void> _seedBuiltInPresets() async {
    final List<Map<String, dynamic>> seeds = [
      // Recommended Presets
      {
        'name': 'Cinema Gold',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(cgBlending: 60.0, shadowsHue: 210, shadowsSat: 15, highlightsHue: 40, highlightsSat: 20)
      },
      {
        'name': 'Teal & Orange',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(exposure: 0.1, shadowsHue: 200, shadowsSat: 25, highlightsHue: 35, highlightsSat: 30)
      },
      {
        'name': 'Warm Travel',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(temperature: 10.0, contrast: -5.0, whites: 5.0, saturation: 5.0)
      },
      {
        'name': 'Moody Dark',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(exposure: -0.4, shadows: -5.0, blacks: -10.0)
      },
      {
        'name': 'Film Classic',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(exposure: 0.1, shadows: 15.0, blacks: 10.0, vignette: -15.0, grain: 15.0)
      },
      {
        'name': 'Matte Soft',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(contrast: -15.0, shadows: 20.0, whites: -10.0)
      },
      {
        'name': 'Sunset Glow',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(temperature: 15.0, tint: 5.0, exposure: 0.2)
      },
      {
        'name': 'B&W Classic',
        'category': 'recommended',
        'params': EditParameters.identity().copyWith(saturation: -100.0)
      },
      // Premium Presets
      {
        'name': 'Portra 400',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(temperature: 5.0, grain: 10.0)
      },
      {
        'name': 'Velvia 50',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(saturation: 15.0, contrast: 10.0, clarity: 5.0)
      },
      {
        'name': 'Ektar 100',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(saturation: 20.0, temperature: 4.0)
      },
      {
        'name': 'Monochrome High Contrast',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(saturation: -100.0, contrast: 35.0)
      },
      {
        'name': 'Urban Fade',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(clarity: 10.0, blacks: 15.0, exposure: -0.1)
      },
      {
        'name': 'Cool Forest',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(temperature: -12.0)
      },
      {
        'name': 'Vintage Fade',
        'category': 'premium',
        'params': EditParameters.identity().copyWith(blacks: 15.0, highlights: -15.0, saturation: -10.0)
      },
    ];

    for (final seed in seeds) {
      final id = _uuid.v4();
      final presetData = PresetData(
        id: id,
        name: seed['name'] as String,
        category: seed['category'] as String,
        parametersJson: jsonEncode(_parametersToMap(seed['params'] as EditParameters)),
        isBookmarked: false,
        createdAt: DateTime.now(),
      );
      await localDataSource.insertPreset(presetData);
    }
  }

  Map<String, dynamic> _parametersToMap(EditParameters params) {
    return {
      'exposure': params.exposure,
      'contrast': params.contrast,
      'highlights': params.highlights,
      'shadows': params.shadows,
      'whites': params.whites,
      'blacks': params.blacks,
      'temperature': params.temperature,
      'tint': params.tint,
      'vibrance': params.vibrance,
      'saturation': params.saturation,
      'texture': params.texture,
      'clarity': params.clarity,
      'dehaze': params.dehaze,
      'vignette': params.vignette,
      'grain': params.grain,
      'sharpeningAmount': params.sharpeningAmount,
      'sharpeningRadius': params.sharpeningRadius,
      'sharpeningDetail': params.sharpeningDetail,
      'sharpeningMasking': params.sharpeningMasking,
      'luminanceNR': params.luminanceNR,
      'colorNR': params.colorNR,
      'removeChromaticAberration': params.removeChromaticAberration,
      'enableLensCorrection': params.enableLensCorrection,
      'cropLeft': params.cropLeft,
      'cropTop': params.cropTop,
      'cropRight': params.cropRight,
      'cropBottom': params.cropBottom,
      'rotation': params.rotation,
      'perspectiveHorizontal': params.perspectiveHorizontal,
      'perspectiveVertical': params.perspectiveVertical,
      'flipHorizontal': params.flipHorizontal,
      'flipVertical': params.flipVertical,
      'aspectRatio': params.aspectRatio,
      'shadowsHue': params.shadowsHue,
      'shadowsSat': params.shadowsSat,
      'midtonesHue': params.midtonesHue,
      'midtonesSat': params.midtonesSat,
      'highlightsHue': params.highlightsHue,
      'highlightsSat': params.highlightsSat,
      'cgBlending': params.cgBlending,
      'cgBalance': params.cgBalance,
      'curveData': {
        'rgb': params.curveData.rgb.map((p) => {'x': p.x, 'y': p.y}).toList(),
        'red': params.curveData.red.map((p) => {'x': p.x, 'y': p.y}).toList(),
        'green': params.curveData.green.map((p) => {'x': p.x, 'y': p.y}).toList(),
        'blue': params.curveData.blue.map((p) => {'x': p.x, 'y': p.y}).toList(),
      },
      'hslAdjustments': {
        'red': {'hue': params.hslAdjustments.red.hue, 'saturation': params.hslAdjustments.red.saturation, 'lightness': params.hslAdjustments.red.lightness},
        'orange': {'hue': params.hslAdjustments.orange.hue, 'saturation': params.hslAdjustments.orange.saturation, 'lightness': params.hslAdjustments.orange.lightness},
        'yellow': {'hue': params.hslAdjustments.yellow.hue, 'saturation': params.hslAdjustments.yellow.saturation, 'lightness': params.hslAdjustments.yellow.lightness},
        'green': {'hue': params.hslAdjustments.green.hue, 'saturation': params.hslAdjustments.green.saturation, 'lightness': params.hslAdjustments.green.lightness},
        'aqua': {'hue': params.hslAdjustments.aqua.hue, 'saturation': params.hslAdjustments.aqua.saturation, 'lightness': params.hslAdjustments.aqua.lightness},
        'blue': {'hue': params.hslAdjustments.blue.hue, 'saturation': params.hslAdjustments.blue.saturation, 'lightness': params.hslAdjustments.blue.lightness},
        'purple': {'hue': params.hslAdjustments.purple.hue, 'saturation': params.hslAdjustments.purple.saturation, 'lightness': params.hslAdjustments.purple.lightness},
        'magenta': {'hue': params.hslAdjustments.magenta.hue, 'saturation': params.hslAdjustments.magenta.saturation, 'lightness': params.hslAdjustments.magenta.lightness},
      },
      'lutPath': params.lutPath,
      'lutIntensity': params.lutIntensity,
      'lutSize': params.lutSize,
    };
  }

  EditParameters _mapToParameters(Map<String, dynamic> map) {
    List<math.Point<double>> parsePoints(dynamic list) {
      if (list is List) {
        return list.map((item) {
          return math.Point(
            (item['x'] as num).toDouble(),
            (item['y'] as num).toDouble(),
          );
        }).toList();
      }
      return [const math.Point(0.0, 0.0), const math.Point(1.0, 1.0)];
    }

    HslColorAdjustment parseHsl(dynamic item) {
      if (item is Map) {
        return HslColorAdjustment(
          hue: (item['hue'] as num?)?.toDouble() ?? 0.0,
          saturation: (item['saturation'] as num?)?.toDouble() ?? 0.0,
          lightness: (item['lightness'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return const HslColorAdjustment();
    }

    CurveData curve = CurveData.identity();
    if (map.containsKey('curveData')) {
      final cMap = map['curveData'] as Map;
      curve = CurveData(
        rgb: parsePoints(cMap['rgb']),
        red: parsePoints(cMap['red']),
        green: parsePoints(cMap['green']),
        blue: parsePoints(cMap['blue']),
      );
    }

    HslAdjustments hsl = const HslAdjustments();
    if (map.containsKey('hslAdjustments')) {
      final hMap = map['hslAdjustments'] as Map;
      hsl = HslAdjustments(
        red: parseHsl(hMap['red']),
        orange: parseHsl(hMap['orange']),
        yellow: parseHsl(hMap['yellow']),
        green: parseHsl(hMap['green']),
        aqua: parseHsl(hMap['aqua']),
        blue: parseHsl(hMap['blue']),
        purple: parseHsl(hMap['purple']),
        magenta: parseHsl(hMap['magenta']),
      );
    }

    return EditParameters(
      exposure: (map['exposure'] as num?)?.toDouble() ?? 0.0,
      contrast: (map['contrast'] as num?)?.toDouble() ?? 0.0,
      highlights: (map['highlights'] as num?)?.toDouble() ?? 0.0,
      shadows: (map['shadows'] as num?)?.toDouble() ?? 0.0,
      whites: (map['whites'] as num?)?.toDouble() ?? 0.0,
      blacks: (map['blacks'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      tint: (map['tint'] as num?)?.toDouble() ?? 0.0,
      vibrance: (map['vibrance'] as num?)?.toDouble() ?? 0.0,
      saturation: (map['saturation'] as num?)?.toDouble() ?? 0.0,
      texture: (map['texture'] as num?)?.toDouble() ?? 0.0,
      clarity: (map['clarity'] as num?)?.toDouble() ?? 0.0,
      dehaze: (map['dehaze'] as num?)?.toDouble() ?? 0.0,
      vignette: (map['vignette'] as num?)?.toDouble() ?? 0.0,
      grain: (map['grain'] as num?)?.toDouble() ?? 0.0,
      sharpeningAmount: (map['sharpeningAmount'] as num?)?.toDouble() ?? 0.0,
      sharpeningRadius: (map['sharpeningRadius'] as num?)?.toDouble() ?? 0.0,
      sharpeningDetail: (map['sharpeningDetail'] as num?)?.toDouble() ?? 0.0,
      sharpeningMasking: (map['sharpeningMasking'] as num?)?.toDouble() ?? 0.0,
      luminanceNR: (map['luminanceNR'] as num?)?.toDouble() ?? 0.0,
      colorNR: (map['colorNR'] as num?)?.toDouble() ?? 0.0,
      removeChromaticAberration: map['removeChromaticAberration'] as bool? ?? false,
      enableLensCorrection: map['enableLensCorrection'] as bool? ?? false,
      cropLeft: (map['cropLeft'] as num?)?.toDouble() ?? 0.0,
      cropTop: (map['cropTop'] as num?)?.toDouble() ?? 0.0,
      cropRight: (map['cropRight'] as num?)?.toDouble() ?? 1.0,
      cropBottom: (map['cropBottom'] as num?)?.toDouble() ?? 1.0,
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0.0,
      perspectiveHorizontal: (map['perspectiveHorizontal'] as num?)?.toDouble() ?? 0.0,
      perspectiveVertical: (map['perspectiveVertical'] as num?)?.toDouble() ?? 0.0,
      flipHorizontal: map['flipHorizontal'] as bool? ?? false,
      flipVertical: map['flipVertical'] as bool? ?? false,
      aspectRatio: map['aspectRatio'] as String? ?? 'Bebas',
      shadowsHue: (map['shadowsHue'] as num?)?.toDouble() ?? 0.0,
      shadowsSat: (map['shadowsSat'] as num?)?.toDouble() ?? 0.0,
      midtonesHue: (map['midtonesHue'] as num?)?.toDouble() ?? 0.0,
      midtonesSat: (map['midtonesSat'] as num?)?.toDouble() ?? 0.0,
      highlightsHue: (map['highlightsHue'] as num?)?.toDouble() ?? 0.0,
      highlightsSat: (map['highlightsSat'] as num?)?.toDouble() ?? 0.0,
      cgBlending: (map['cgBlending'] as num?)?.toDouble() ?? 50.0,
      cgBalance: (map['cgBalance'] as num?)?.toDouble() ?? 0.0,
      curveData: curve,
      hslAdjustments: hsl,
      lutPath: map['lutPath'] as String?,
      lutIntensity: (map['lutIntensity'] as num?)?.toDouble() ?? 1.0,
      lutSize: (map['lutSize'] as num?)?.toDouble() ?? 0.0,
      masks: const [],
      activeMaskId: null,
    );
  }
}
