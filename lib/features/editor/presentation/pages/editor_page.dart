import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/math_utils.dart';
import '../../../../core/utils/copied_settings_helper.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/curve_data.dart';
import '../../domain/entities/edit_parameters.dart';
import '../../domain/entities/hsl_adjustments.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import '../widgets/adjustment_panel.dart';
import '../widgets/image_canvas.dart';
import '../widgets/compare_canvas.dart';
import '../widgets/tool_selector.dart';
import '../widgets/panels/light_panel.dart';
import '../widgets/panels/color_panel.dart';
import '../widgets/panels/hsl_panel.dart';
import '../widgets/panels/curves_panel.dart';
import '../widgets/panels/effects_panel.dart';
import '../widgets/panels/color_grading_panel.dart';
import '../widgets/panels/detail_panel.dart';
import '../widgets/panels/optics_panel.dart';
import '../widgets/panels/geometry_panel.dart';
import '../widgets/panels/presets_panel.dart';
import '../widgets/panels/history_panel.dart';
import '../widgets/panels/lut_panel.dart';
import '../widgets/panels/masking_panel.dart';
import '../../domain/entities/mask_model.dart';
import '../../data/datasources/mask_texture_generator.dart';
import '../../data/datasources/lut_parser.dart';
import '../../../export/presentation/widgets/export_dialog.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../widgets/crop/crop_overlay.dart';

/// 🌱 SeedColor — Editor Screen Wrapper
///
/// Pembungkus halaman editor untuk menyediakan BLoC secara lokal
/// dan memulai sesi pengeditan baru.
class EditorScreen extends StatelessWidget {
  final String photoId;
  final bool isStandalone;

  const EditorScreen({
    super.key,
    required this.photoId,
    this.isStandalone = false,
  });

  @override
  Widget build(BuildContext context) {
    if (photoId == 'sample' || photoId.isEmpty) {
      return BlocProvider<EditorBloc>(
        create: (context) => sl<EditorBloc>()
          ..add(StartSession(
            photoId: 'sample',
            imagePath: 'assets/images/mountain_lake.png',
          )),
        child: EditorPage(photoId: 'sample', isStandalone: isStandalone),
      );
    }

    return FutureBuilder<PhotoData?>(
      future: (sl<AppDatabase>().select(sl<AppDatabase>().photosTable)
            ..where((t) => t.id.equals(photoId)))
          .getSingleOrNull(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: Text(
                'Failed to load photo',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        final photoPath = snapshot.data!.path;

        return BlocProvider<EditorBloc>(
          create: (context) => sl<EditorBloc>()
            ..add(StartSession(
              photoId: photoId,
              imagePath: photoPath,
            )),
          child: EditorPage(photoId: photoId, isStandalone: isStandalone),
        );
      },
    );
  }
}

/// 🌱 SeedColor — Editor Page
///
/// Refactored Editor Screen to support dynamic Light, Color, HSL & Curves panels with EditorBloc.
class EditorPage extends StatefulWidget {
  final String photoId;
  final bool isStandalone;

  const EditorPage({
    super.key,
    required this.photoId,
    this.isStandalone = false,
  });

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage>
    with SingleTickerProviderStateMixin {
  int _selectedToolIndex = 0;
  bool _showHslMixer = false;
  bool _showCurves = false;
  bool _showColorGrading = false;

  // Resources for shader preview
  ui.Image? _testImage;
  ui.Image? _lutImage;
  ui.Image? _identityLutImage;
  ui.FragmentShader? _shader;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _rating = 0;

  bool _showCompare = false;
  double _compareDragRatio = 0.5;

  // 3D LUT Support
  String? _loadedLutPath;
  ui.Image? _custom3dLutImage;
  bool _isLutLoading = false;

  // Masking Support
  bool _showMaskOverlay = true;
  ui.Image? _customMaskTexture;
  bool _isMaskGenerating = false;
  Offset? _currentBrushPoint;
  final double _currentBrushRadius = 0.04;
  String? _draggedHandle;
  Offset? _linearStartTemp;
  Offset? _radialCenterTemp;
  EditParameters? _tempParameters;

  final List<ToolItem> _tools = [
    const ToolItem(Icons.style_rounded, 'Presets', Color(0xFF00E6FF)),
    const ToolItem(Icons.wb_sunny_rounded, 'Light', AppColors.toolLight),
    const ToolItem(Icons.palette_rounded, 'Color', AppColors.toolColor),
    const ToolItem(Icons.auto_awesome_rounded, 'Effects', AppColors.toolEffects),
    const ToolItem(Icons.details_rounded, 'Detail', AppColors.toolDetail),
    const ToolItem(Icons.camera_rounded, 'Optics', Color(0xFFBC8CFF)),
    const ToolItem(Icons.table_chart_rounded, 'LUT', AppColors.primary),
    const ToolItem(Icons.crop_rounded, 'Geometry', AppColors.toolGeometry),
    const ToolItem(Icons.layers_rounded, 'Masking', AppColors.toolMasking),
    const ToolItem(Icons.history_rounded, 'Riwayat', Color(0xFFFF9500)),
  ];

  // ─── Light Panel Sliders (Preset to Mockup Values) ──────
  final Map<String, double> _lightValues = {
    'Exposure': 0.35,
    'Contrast': 20.0,
    'Highlights': -40.0,
    'Shadows': 35.0,
    'Whites': 10.0,
    'Blacks': -15.0,
  };

  // ─── Color Panel Sliders ─────────────────────────────
  final Map<String, double> _colorValues = {
    'Temperature': 0.0,
    'Tint': 0.0,
    'Vibrance': 0.0,
    'Saturation': 0.0,
  };

  // ─── HSL Mixer Adjustments ───────────────────────────
  HslAdjustments _hslAdjustments = const HslAdjustments();

  // ─── Curves Adjustments ──────────────────────────────
  CurveData _currentCurveData = CurveData.identity();
  bool _isGeneratingLut = false;
  CurveData? _lastGeneratedCurve;

  // ─── Effects Panel Sliders ───────────────────────────
  final Map<String, double> _effectsValues = {
    'Texture': 0.0,
    'Clarity': 0.0,
    'Dehaze': 0.0,
    'Vignette': 0.0,
    'Grain': 0.0,
  };

  // ─── Color Grading Panel Parameters ──────────────────
  double _shadowsHue = 0.0;
  double _shadowsSat = 0.0;
  double _midtonesHue = 0.0;
  double _midtonesSat = 0.0;
  double _highlightsHue = 0.0;
  double _highlightsSat = 0.0;
  double _cgBlending = 50.0;
  double _cgBalance = 0.0;

  // ─── Detail Panel Sliders ────────────────────────────
  final Map<String, double> _detailValues = {
    'Sharpening': 0,
    'Radius': 0,
    'Detail': 0,
    'Masking': 0,
    'Luminance NR': 0,
    'Color NR': 0,
  };

  // ─── Optics Panel Toggles ────────────────────────────
  bool _removeChromaticAberration = false;
  bool _enableLensCorrection = false;

  // ─── Masking Panel Sliders (Preset to Mockup Values) ────
  final Map<String, double> _maskingValues = {
    'Exposure': 0.40,
    'Contrast': 15.0,
    'Shadows': 25.0,
    'Saturation': 10.0,
  };

  // ─── Geometry Panel State Variables ──────────────────
  double _cropLeft = 0.0;
  double _cropTop = 0.0;
  double _cropRight = 1.0;
  double _cropBottom = 1.0;
  double _rotation = 0.0;
  double _perspectiveHorizontal = 0.0;
  double _perspectiveVertical = 0.0;
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  String _aspectRatio = 'Bebas';

  Map<String, double> get _currentValues {
    switch (_currentToolLabel) {
      case 'Light':
        return _lightValues;
      case 'Color':
        return _colorValues;
      case 'Effects':
        return _effectsValues;
      case 'Detail':
        return _detailValues;
      case 'Masking':
        return _maskingValues;
      default:
        return {};
    }
  }

  String get _currentToolLabel => _tools[_selectedToolIndex].label;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      // 1. Load main mountain lake image dynamically
      final Uint8List list;
      if (widget.photoId == 'sample' || widget.photoId.isEmpty) {
        final ByteData data = await rootBundle.load('assets/images/mountain_lake.png');
        list = data.buffer.asUint8List();
      } else {
        final dbPhoto = await (sl<AppDatabase>().select(sl<AppDatabase>().photosTable)
              ..where((t) => t.id.equals(widget.photoId)))
            .getSingleOrNull();
        if (dbPhoto != null) {
          final pathLower = dbPhoto.path.toLowerCase();
          final isRaw = pathLower.endsWith('.dng') ||
              pathLower.endsWith('.cr2') ||
              pathLower.endsWith('.nef') ||
              pathLower.endsWith('.arw');
          final pathToLoad = (isRaw && dbPhoto.thumbnailPath != null)
              ? dbPhoto.thumbnailPath!
              : dbPhoto.path;
          final file = File(pathToLoad);
          list = await file.readAsBytes();
          _isFavorite = dbPhoto.isFavorite;
          _rating = dbPhoto.rating;
        } else {
          final ByteData data = await rootBundle.load('assets/images/mountain_lake.png');
          list = data.buffer.asUint8List();
        }
      }

      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo fi = await codec.getNextFrame();
      _testImage = fi.image;

      // 2. Create LUT from current curve data
      _lutImage = await _generateLutImage(_currentCurveData);
      _identityLutImage = await _generateLutImage(CurveData.identity());

      // 4. Load shader (composite.frag)
      final ui.FragmentProgram program = await ui.FragmentProgram.fromAsset(
        'lib/shaders/composite.frag',
      );
      _shader = program.fragmentShader();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading resources: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ui.Image> _generateLutImage(CurveData curve) async {
    final redLut = MathUtils.catmullRomSplineLut(curve.red);
    final greenLut = MathUtils.catmullRomSplineLut(curve.green);
    final blueLut = MathUtils.catmullRomSplineLut(curve.blue);
    final rgbLut = MathUtils.catmullRomSplineLut(curve.rgb);

    final bytes = Uint8List(256 * 4);
    for (int i = 0; i < 256; i++) {
      bytes[i * 4 + 0] = (redLut[i] * 255).clamp(0, 255).round();
      bytes[i * 4 + 1] = (greenLut[i] * 255).clamp(0, 255).round();
      bytes[i * 4 + 2] = (blueLut[i] * 255).clamp(0, 255).round();
      bytes[i * 4 + 3] = (rgbLut[i] * 255).clamp(0, 255).round();
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      256,
      1,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }

  Future<void> _updateLutImage(CurveData curve) async {
    if (_lastGeneratedCurve == curve || _isGeneratingLut) return;
    _isGeneratingLut = true;
    _lastGeneratedCurve = curve;

    final newLut = await _generateLutImage(curve);
    if (mounted) {
      setState(() {
        _lutImage = newLut;
        _isGeneratingLut = false;
      });
    }

    // Jika ada pembaruan kurva baru saat proses generate sedang berjalan, panggil ulang
    if (_lastGeneratedCurve != _currentCurveData) {
      _isGeneratingLut = false;
      _updateLutImage(_currentCurveData);
    }
  }

  Future<void> _syncLutImage(String? path, double size) async {
    if (path == null || size == 0.0) {
      if (_custom3dLutImage != null || _loadedLutPath != null) {
        setState(() {
          _custom3dLutImage = null;
          _loadedLutPath = null;
        });
      }
      return;
    }

    if (_loadedLutPath == path || _isLutLoading) return;
    _isLutLoading = true;
    _loadedLutPath = path;

    try {
      final lutData = await LutParser.parse(path);
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        lutData.rgbaBytes,
        lutData.size * lutData.size,
        lutData.size,
        ui.PixelFormat.rgba8888,
        (img) => completer.complete(img),
      );
      final newLutImage = await completer.future;
      if (mounted) {
        setState(() {
          _custom3dLutImage = newLutImage;
          _isLutLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading 3D LUT preview: $e');
      if (mounted) {
        setState(() {
          _custom3dLutImage = null;
          _isLutLoading = false;
        });
      }
    }
  }

  List<double> _hueToRgb(double hue) {
    final h = hue / 60.0;
    final x = 1.0 - (h % 2.0 - 1.0).abs();
    if (h < 1) return [1.0, x, 0.0];
    if (h < 2) return [x, 1.0, 0.0];
    if (h < 3) return [0.0, 1.0, x];
    if (h < 4) return [0.0, x, 1.0];
    if (h < 5) return [x, 0.0, 1.0];
    return [1.0, 0.0, x];
  }

  List<double> _hueSatToRgbVec3(double hue, double sat) {
    final rgb = _hueToRgb(hue);
    final s = sat / 100.0;
    return [rgb[0] * s, rgb[1] * s, rgb[2] * s];
  }

  Future<void> _regenerateMaskTexture(MaskModel mask) async {
    if (_isMaskGenerating) return;
    _isMaskGenerating = true;
    try {
      final img = await MaskTextureGenerator.generate(
        mask: mask,
        size: const Size(512, 512),
        baseImage: _testImage,
      );
      if (mounted) {
        setState(() {
          _customMaskTexture = img;
        });
      }
    } catch (e) {
      debugPrint('Gagal generate mask texture: $e');
    } finally {
      _isMaskGenerating = false;
    }
  }

  void _addMaskDirectly(MaskType type) {
    final params = _tempParameters ?? context.read<EditorBloc>().state.session?.currentParameters;
    if (params == null) return;
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final name = _getDefaultMaskName(type, params.masks.length + 1);

    final newMask = MaskModel(
      id: id,
      name: name,
      type: type,
      linearStart: type == MaskType.linear ? const Offset(0.5, 0.25) : null,
      linearEnd: type == MaskType.linear ? const Offset(0.5, 0.75) : null,
      radialCenter: type == MaskType.radial ? const Offset(0.5, 0.5) : null,
      radialRadiusX: type == MaskType.radial ? 0.18 : 0.15,
      radialRadiusY: type == MaskType.radial ? 0.18 : 0.15,
    );

    final updatedMasks = List<MaskModel>.from(params.masks)..add(newMask);
    final updated = params.copyWith(masks: updatedMasks, activeMaskId: id);
    
    setState(() {
      _tempParameters = updated;
    });
    
    _regenerateMaskTexture(newMask);
    context.read<EditorBloc>().add(UpdateMasks(updated));
  }

  String _getDefaultMaskName(MaskType type, int count) {
    switch (type) {
      case MaskType.brush: return 'Kuas $count';
      case MaskType.linear: return 'Gradien Linier $count';
      case MaskType.radial: return 'Gradien Radial $count';
      case MaskType.subject: return 'AI Subjek $count';
      case MaskType.sky: return 'AI Langit $count';
    }
  }

  void _handleMaskPanStart(DragStartDetails details, Size canvasSize, Offset leftTopOffset) {
    final params = _tempParameters ?? context.read<EditorBloc>().state.session?.currentParameters;
    if (params == null) return;
    
    final activeId = params.activeMaskId;
    if (activeId == null) return;

    final activeMask = params.masks.firstWhere((m) => m.id == activeId, orElse: () => const MaskModel(id: '', name: '', type: MaskType.brush));
    if (activeMask.id.isEmpty) return;

    final localPos = details.localPosition - leftTopOffset;
    final normPos = Offset(
      localPos.dx.clamp(0.0, canvasSize.width) / canvasSize.width,
      localPos.dy.clamp(0.0, canvasSize.height) / canvasSize.height,
    );

    if (activeMask.type == MaskType.brush) {
      final newStroke = BrushStroke(
        points: [normPos],
        radius: _currentBrushRadius,
        hardness: 0.5,
        opacity: 1.0,
      );
      final updatedStrokes = List<BrushStroke>.from(activeMask.strokes)..add(newStroke);
      final updatedMask = activeMask.copyWith(strokes: updatedStrokes);
      _updateActiveMaskLocally(params, updatedMask);
    } else if (activeMask.type == MaskType.linear) {
      final startDist = (activeMask.linearStart! - normPos).distance;
      final endDist = (activeMask.linearEnd! - normPos).distance;
      final midPoint = (activeMask.linearStart! + activeMask.linearEnd!) / 2;
      final midDist = (midPoint - normPos).distance;

      if (startDist < 0.08) {
        _draggedHandle = 'start';
      } else if (endDist < 0.08) {
        _draggedHandle = 'end';
      } else if (midDist < 0.08) {
        _draggedHandle = 'center';
      } else {
        _draggedHandle = 'new';
        _linearStartTemp = normPos;
        final updatedMask = activeMask.copyWith(linearStart: normPos, linearEnd: normPos);
        _updateActiveMaskLocally(params, updatedMask);
      }
    } else if (activeMask.type == MaskType.radial) {
      final center = activeMask.radialCenter!;
      final centerDist = (center - normPos).distance;
      
      final edgeX = center + Offset(activeMask.radialRadiusX, 0);
      final edgeY = center + Offset(0, activeMask.radialRadiusY);
      final distEdgeX = (edgeX - normPos).distance;
      final distEdgeY = (edgeY - normPos).distance;

      if (centerDist < 0.08) {
        _draggedHandle = 'center';
      } else if (distEdgeX < 0.08) {
        _draggedHandle = 'radiusX';
      } else if (distEdgeY < 0.08) {
        _draggedHandle = 'radiusY';
      } else {
        _draggedHandle = 'new';
        _radialCenterTemp = normPos;
        final updatedMask = activeMask.copyWith(
          radialCenter: normPos,
          radialRadiusX: 0.01,
          radialRadiusY: 0.01,
        );
        _updateActiveMaskLocally(params, updatedMask);
      }
    }
  }

  void _handleMaskPanUpdate(DragUpdateDetails details, Size canvasSize, Offset leftTopOffset) {
    final params = _tempParameters ?? context.read<EditorBloc>().state.session?.currentParameters;
    if (params == null) return;
    
    final activeId = params.activeMaskId;
    if (activeId == null) return;

    final activeMask = params.masks.firstWhere((m) => m.id == activeId, orElse: () => const MaskModel(id: '', name: '', type: MaskType.brush));
    if (activeMask.id.isEmpty) return;

    final localPos = details.localPosition - leftTopOffset;
    final normPos = Offset(
      localPos.dx.clamp(0.0, canvasSize.width) / canvasSize.width,
      localPos.dy.clamp(0.0, canvasSize.height) / canvasSize.height,
    );

    if (activeMask.type == MaskType.brush) {
      if (activeMask.strokes.isNotEmpty) {
        setState(() {
          _currentBrushPoint = normPos;
        });
        final lastStroke = activeMask.strokes.last;
        final updatedPoints = List<Offset>.from(lastStroke.points)..add(normPos);
        final updatedStroke = BrushStroke(
          points: updatedPoints,
          radius: lastStroke.radius,
          hardness: lastStroke.hardness,
          opacity: lastStroke.opacity,
        );
        final updatedStrokes = List<BrushStroke>.from(activeMask.strokes)
          ..[activeMask.strokes.length - 1] = updatedStroke;
        final updatedMask = activeMask.copyWith(strokes: updatedStrokes);
        _updateActiveMaskLocally(params, updatedMask);
      }
    } else if (activeMask.type == MaskType.linear) {
      if (_draggedHandle == 'start') {
        final updatedMask = activeMask.copyWith(linearStart: normPos);
        _updateActiveMaskLocally(params, updatedMask);
      } else if (_draggedHandle == 'end') {
        final updatedMask = activeMask.copyWith(linearEnd: normPos);
        _updateActiveMaskLocally(params, updatedMask);
      } else if (_draggedHandle == 'center') {
        final currentMid = (activeMask.linearStart! + activeMask.linearEnd!) / 2;
        final delta = normPos - currentMid;
        final updatedMask = activeMask.copyWith(
          linearStart: activeMask.linearStart! + delta,
          linearEnd: activeMask.linearEnd! + delta,
        );
        _updateActiveMaskLocally(params, updatedMask);
      } else if (_draggedHandle == 'new' && _linearStartTemp != null) {
        final updatedMask = activeMask.copyWith(linearStart: _linearStartTemp, linearEnd: normPos);
        _updateActiveMaskLocally(params, updatedMask);
      }
    } else if (activeMask.type == MaskType.radial) {
      if (_draggedHandle == 'center') {
        final updatedMask = activeMask.copyWith(radialCenter: normPos);
        _updateActiveMaskLocally(params, updatedMask);
      } else if (_draggedHandle == 'radiusX') {
        final dist = (normPos - activeMask.radialCenter!).distance;
        final updatedMask = activeMask.copyWith(radialRadiusX: dist.clamp(0.01, 1.0));
        _updateActiveMaskLocally(params, updatedMask);
      } else if (_draggedHandle == 'radiusY') {
        final dist = (normPos - activeMask.radialCenter!).distance;
        final updatedMask = activeMask.copyWith(radialRadiusY: dist.clamp(0.01, 1.0));
        _updateActiveMaskLocally(params, updatedMask);
      } else if (_draggedHandle == 'new' && _radialCenterTemp != null) {
        final dist = (normPos - _radialCenterTemp!).distance;
        final updatedMask = activeMask.copyWith(
          radialCenter: _radialCenterTemp,
          radialRadiusX: dist.clamp(0.01, 1.0),
          radialRadiusY: dist.clamp(0.01, 1.0),
        );
        _updateActiveMaskLocally(params, updatedMask);
      }
    }
  }

  void _handleMaskPanEnd(DragEndDetails details) {
    setState(() {
      _currentBrushPoint = null;
    });
    _draggedHandle = null;
    _linearStartTemp = null;
    _radialCenterTemp = null;

    if (_tempParameters != null) {
      context.read<EditorBloc>().add(UpdateMasks(_tempParameters!));
    }
  }

  void _updateActiveMaskLocally(EditParameters params, MaskModel updatedMask) {
    final updatedMasks = params.masks.map((m) {
      return m.id == updatedMask.id ? updatedMask : m;
    }).toList();
    
    final updatedParams = params.copyWith(masks: updatedMasks);
    setState(() {
      _tempParameters = updatedParams;
    });
    
    _regenerateMaskTexture(updatedMask);
  }

  void _syncLocalValuesFromParams(EditParameters params) {
    _lightValues['Exposure'] = params.exposure;
    _lightValues['Contrast'] = params.contrast;
    _lightValues['Highlights'] = params.highlights;
    _lightValues['Shadows'] = params.shadows;
    _lightValues['Whites'] = params.whites;
    _lightValues['Blacks'] = params.blacks;

    _colorValues['Temperature'] = params.temperature;
    _colorValues['Tint'] = params.tint;
    _colorValues['Vibrance'] = params.vibrance;
    _colorValues['Saturation'] = params.saturation;

    _hslAdjustments = params.hslAdjustments;

    _currentCurveData = params.curveData;
    _updateLutImage(_currentCurveData);

    _effectsValues['Texture'] = params.texture;
    _effectsValues['Clarity'] = params.clarity;
    _effectsValues['Dehaze'] = params.dehaze;
    _effectsValues['Vignette'] = params.vignette;
    _effectsValues['Grain'] = params.grain;

    _detailValues['Sharpening'] = params.sharpeningAmount;
    _detailValues['Radius'] = params.sharpeningRadius;
    _detailValues['Detail'] = params.sharpeningDetail;
    _detailValues['Masking'] = params.sharpeningMasking;
    _detailValues['Luminance NR'] = params.luminanceNR;
    _detailValues['Color NR'] = params.colorNR;

    _removeChromaticAberration = params.removeChromaticAberration;
    _enableLensCorrection = params.enableLensCorrection;

    _cropLeft = params.cropLeft;
    _cropTop = params.cropTop;
    _cropRight = params.cropRight;
    _cropBottom = params.cropBottom;
    _rotation = params.rotation;
    _perspectiveHorizontal = params.perspectiveHorizontal;
    _perspectiveVertical = params.perspectiveVertical;
    _flipHorizontal = params.flipHorizontal;
    _flipVertical = params.flipVertical;
    _aspectRatio = params.aspectRatio;

    _shadowsHue = params.shadowsHue;
    _shadowsSat = params.shadowsSat;
    _midtonesHue = params.midtonesHue;
    _midtonesSat = params.midtonesSat;
    _highlightsHue = params.highlightsHue;
    _highlightsSat = params.highlightsSat;
    _cgBlending = params.cgBlending;
    _cgBalance = params.cgBalance;
    _syncLutImage(params.lutPath, params.lutSize);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditorBloc, EditorState>(
      listener: (context, state) {
        // Tampilkan/sembunyikan loading overlay saat proses ekspor/inisialisasi
        if (state.isProcessing) {
          LoadingOverlay.show(context, message: 'Memproses...');
        } else {
          LoadingOverlay.hide(context);
        }

        // Tampilkan feedback saat berhasil ekspor
        if (state.exportedImagePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gambar berhasil diekspor ke ${state.exportedImagePath}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }

        // Tampilkan feedback saat error
        if (state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.failure}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }

        // Sinkronisasi local values dengan state BLoC
        if (state.session != null) {
          final params = state.session!.currentParameters;
          _syncLocalValuesFromParams(params);
          setState(() {
            _tempParameters = params;
          });

          final activeId = params.activeMaskId;
          final activeMask = activeId != null
              ? params.masks.firstWhere(
                  (m) => m.id == activeId,
                  orElse: () => const MaskModel(id: '', name: '', type: MaskType.brush),
                )
              : null;

          if (activeMask != null && activeMask.id.isNotEmpty) {
            _regenerateMaskTexture(activeMask);
          } else {
            setState(() {
              _customMaskTexture = null;
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: Column(
              children: [
                // ─── Top Bar ──────────────────────────────────
                _buildTopBar(state),

                // ─── Image Preview & Masking Overlay ──────────
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _buildImagePreview(state),
                      ),
                      if (_currentToolLabel == 'Masking') _buildMaskingSidebar(),
                    ],
                  ),
                ),

                // ─── Panel Header ─────────────────────────────
                _buildPanelHeader(state),

                // ─── Adjustment Sliders ───────────────────────
                Flexible(
                  child: _buildAdjustmentSliders(state),
                ),

                // ─── Tool Selector Bar ────────────────────────
                _buildToolSelector(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Conditional top bar matching Light vs Masking layout
  Widget _buildTopBar(EditorState state) {
    if (_currentToolLabel == 'Masking') {
      // Masking Top Bar (Mockup Screen 3)
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimary,
              onPressed: () {
                setState(() {
                  _selectedToolIndex = _tools.indexWhere((t) => t.label == 'Light'); // Go back to Light
                });
              },
              tooltip: 'Cancel',
            ),
            const Spacer(),
            Text(
              'Masking',
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.check_rounded, size: 24),
              color: AppColors.textPrimary,
              onPressed: () {
                setState(() {
                  _selectedToolIndex = _tools.indexWhere((t) => t.label == 'Light'); // Confirm & go back
                });
              },
              tooltip: 'Apply',
            ),
          ],
        ),
      );
    }

    final bloc = context.read<EditorBloc>();

    // Standard Editor Top Bar (Mockup Screen 2)
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (widget.isStandalone)
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              color: AppColors.textPrimary,
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Back',
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              color: AppColors.textPrimary,
              onPressed: () => context.go('/library'),
              tooltip: 'Back',
            ),
          const Spacer(),
          // Favorite button (only for real photos, not sample)
          if (widget.photoId != 'sample' && widget.photoId.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFavorite ? const Color(0xFFFF4081) : AppColors.textPrimary,
              ),
              onPressed: () async {
                final newValue = !_isFavorite;
                await (sl<AppDatabase>().update(sl<AppDatabase>().photosTable)
                      ..where((t) => t.id.equals(widget.photoId)))
                    .write(PhotosTableCompanion(isFavorite: drift.Value(newValue)));
                setState(() {
                  _isFavorite = newValue;
                });
              },
              tooltip: 'Favorite',
            ),
            IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _rating > 0 ? Icons.star_rounded : Icons.star_border_rounded,
                    color: _rating > 0 ? const Color(0xFFFFB300) : AppColors.textPrimary,
                    size: 20,
                  ),
                  if (_rating > 0) ...[
                    const SizedBox(width: 2),
                    Text(
                      '$_rating',
                      style: TextStyle(
                        color: _rating > 0 ? const Color(0xFFFFB300) : AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              onPressed: () => _showRatingPicker(context),
              tooltip: 'Set Rating',
            ),
            const Spacer(),
          ],
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: bloc.canUndo ? AppColors.textPrimary : AppColors.textTertiary,
            onPressed: bloc.canUndo ? () => bloc.undo() : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            color: bloc.canRedo ? AppColors.textPrimary : AppColors.textTertiary,
            onPressed: bloc.canRedo ? () => bloc.redo() : null,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: Icon(
              _showCompare ? Icons.compare_rounded : Icons.difference_rounded,
              size: 20,
              color: _showCompare ? AppColors.primary : AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _showCompare = !_showCompare;
              });
            },
            tooltip: 'Bandingkan Sebelum/Sesudah',
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {
              if (state.session != null) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => BlocProvider.value(
                    value: context.read<EditorBloc>(),
                    child: ExportDialog(session: state.session!),
                  ),
                );
              }
            },
            tooltip: 'Export',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            color: AppColors.backgroundPanel,
            onSelected: (value) {
              if (value == 'copy') {
                if (state.session != null) {
                  CopiedSettingsHelper.copy(state.session!.currentParameters);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan edit berhasil disalin'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } else if (value == 'paste') {
                if (CopiedSettingsHelper.hasCopiedParameters) {
                  bloc.add(ApplyPreset(CopiedSettingsHelper.copiedParameters!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengaturan edit berhasil ditempel'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              } else if (value == 'reset') {
                bloc.add(ResetAll());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                    SizedBox(width: 8),
                    Text('Salin Pengaturan', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'paste',
                enabled: CopiedSettingsHelper.hasCopiedParameters,
                child: Row(
                  children: [
                    Icon(Icons.paste_rounded,
                         color: CopiedSettingsHelper.hasCopiedParameters ? Colors.white70 : Colors.white24,
                         size: 18),
                    SizedBox(width: 8),
                    Text('Tempel Pengaturan',
                         style: TextStyle(
                           color: CopiedSettingsHelper.hasCopiedParameters ? Colors.white : Colors.white30,
                         )),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Reset Semua', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRatingPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: const Text('Set Rating', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return GestureDetector(
                onTap: () async {
                  await (sl<AppDatabase>().update(sl<AppDatabase>().photosTable)
                        ..where((t) => t.id.equals(widget.photoId)))
                      .write(PhotosTableCompanion(rating: drift.Value(index)));
                  setState(() {
                    _rating = index;
                  });
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _rating == index ? const Color(0xFF0A84FF) : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: _rating == index ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// Floating vertical masking bar overlay on the right of the image
  Widget _buildMaskingSidebar() {
    final params = _tempParameters ?? context.read<EditorBloc>().state.session?.currentParameters;
    final activeId = params?.activeMaskId;
    final activeMask = activeId != null
        ? params?.masks.firstWhere((m) => m.id == activeId, orElse: () => const MaskModel(id: '', name: '', type: MaskType.brush))
        : null;
    final realActiveMask = (activeMask != null && activeMask.id.isNotEmpty) ? activeMask : null;

    return Positioned(
      right: 16,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Plus button
          GestureDetector(
            onTap: () => _addMaskDirectly(MaskType.brush),
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF0A84FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          // Vertical capsule container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF11121A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
            child: Column(
              children: [
                _buildFloatingToolItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Subject',
                  isSelected: realActiveMask?.type == MaskType.subject,
                  onTap: () => _addMaskDirectly(MaskType.subject),
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.cloud_queue_rounded,
                  label: 'Sky',
                  isSelected: realActiveMask?.type == MaskType.sky,
                  onTap: () => _addMaskDirectly(MaskType.sky),
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.brush_outlined,
                  label: 'Brush',
                  isSelected: realActiveMask?.type == MaskType.brush,
                  onTap: () => _addMaskDirectly(MaskType.brush),
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.linear_scale_rounded,
                  label: 'Linear',
                  isSelected: realActiveMask?.type == MaskType.linear,
                  onTap: () => _addMaskDirectly(MaskType.linear),
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.adjust_rounded,
                  label: 'Radial',
                  isSelected: realActiveMask?.type == MaskType.radial,
                  onTap: () => _addMaskDirectly(MaskType.radial),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingToolItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0A84FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF0A84FF) : Colors.white24,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF0A84FF) : Colors.white38,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Main canvas, feeding current tool selected values to GLSL Shader
  Widget _buildImagePreview(EditorState state) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_shader == null || _testImage == null || _lutImage == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load shader engine or assets',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final imageToRender = _testImage!;

    final activeParams = _tempParameters ?? state.session!.currentParameters;
    final activeId = activeParams.activeMaskId;
    final activeMask = activeId != null
        ? activeParams.masks.firstWhere(
            (m) => m.id == activeId,
            orElse: () => const MaskModel(id: '', name: '', type: MaskType.brush),
          )
        : null;
    final realActiveMask = (activeMask != null && activeMask.id.isNotEmpty) ? activeMask : null;

    final canvasWidget = _showCompare
        ? CompareCanvas(
            image: imageToRender,
            lutImage: _lutImage!,
            identityLutImage: _identityLutImage ?? _lutImage!,
            shader: _shader!,
            dragRatio: _compareDragRatio,
            onDragUpdate: (ratio) {
              setState(() {
                _compareDragRatio = ratio;
              });
            },
            exposure: _lightValues['Exposure'] ?? 0.0,
            contrast: _lightValues['Contrast'] ?? 0.0,
            highlights: _lightValues['Highlights'] ?? 0.0,
            shadows: _lightValues['Shadows'] ?? 0.0,
            whites: _lightValues['Whites'] ?? 0.0,
            blacks: _lightValues['Blacks'] ?? 0.0,
            temperature: _colorValues['Temperature'] ?? 0.0,
            tint: _colorValues['Tint'] ?? 0.0,
            vibrance: _colorValues['Vibrance'] ?? 0.0,
            saturation: _colorValues['Saturation'] ?? 0.0,
            hslAdjustments: _hslAdjustments,
            textureAdjust: _effectsValues['Texture'] ?? 0.0,
            clarity: _effectsValues['Clarity'] ?? 0.0,
            dehaze: _effectsValues['Dehaze'] ?? 0.0,
            vignette: _effectsValues['Vignette'] ?? 0.0,
            grain: _effectsValues['Grain'] ?? 0.0,
            sharpeningAmount: _detailValues['Sharpening'] ?? 0.0,
            sharpeningRadius: _detailValues['Radius'] ?? 0.0,
            sharpeningDetail: _detailValues['Detail'] ?? 0.0,
            sharpeningMasking: _detailValues['Masking'] ?? 0.0,
            luminanceNR: _detailValues['Luminance NR'] ?? 0.0,
            colorNR: _detailValues['Color NR'] ?? 0.0,
            removeChromaticAberration: _removeChromaticAberration,
            enableLensCorrection: _enableLensCorrection,
            shadowsColor: _hueSatToRgbVec3(_shadowsHue, _shadowsSat),
            midtonesColor: _hueSatToRgbVec3(_midtonesHue, _midtonesSat),
            highlightsColor: _hueSatToRgbVec3(_highlightsHue, _highlightsSat),
            cgBlending: _cgBlending,
            cgBalance: _cgBalance,
            custom3dLutImage: _custom3dLutImage,
            lutSize: state.session?.currentParameters.lutSize ?? 0.0,
            lutIntensity: state.session?.currentParameters.lutIntensity ?? 1.0,
            maskImage: _customMaskTexture,
            hasMask: realActiveMask != null && realActiveMask.isVisible,
            maskExposure: realActiveMask?.exposure ?? 0.0,
            maskContrast: realActiveMask?.contrast ?? 0.0,
            maskShadows: realActiveMask?.shadows ?? 0.0,
            maskSaturation: realActiveMask?.saturation ?? 0.0,
            maskTemperature: realActiveMask?.temperature ?? 0.0,
            maskTint: realActiveMask?.tint ?? 0.0,
            showMaskOverlay: _showMaskOverlay,
          )
        : ImageCanvas(
            image: imageToRender,
            lutImage: _lutImage!,
            shader: _shader!,
            exposure: _lightValues['Exposure'] ?? 0.0,
            contrast: _lightValues['Contrast'] ?? 0.0,
            highlights: _lightValues['Highlights'] ?? 0.0,
            shadows: _lightValues['Shadows'] ?? 0.0,
            whites: _lightValues['Whites'] ?? 0.0,
            blacks: _lightValues['Blacks'] ?? 0.0,
            temperature: _colorValues['Temperature'] ?? 0.0,
            tint: _colorValues['Tint'] ?? 0.0,
            vibrance: _colorValues['Vibrance'] ?? 0.0,
            saturation: _colorValues['Saturation'] ?? 0.0,
            hslAdjustments: _hslAdjustments,
            textureAdjust: _effectsValues['Texture'] ?? 0.0,
            clarity: _effectsValues['Clarity'] ?? 0.0,
            dehaze: _effectsValues['Dehaze'] ?? 0.0,
            vignette: _effectsValues['Vignette'] ?? 0.0,
            grain: _effectsValues['Grain'] ?? 0.0,
            sharpeningAmount: _detailValues['Sharpening'] ?? 0.0,
            sharpeningRadius: _detailValues['Radius'] ?? 0.0,
            sharpeningDetail: _detailValues['Detail'] ?? 0.0,
            sharpeningMasking: _detailValues['Masking'] ?? 0.0,
            luminanceNR: _detailValues['Luminance NR'] ?? 0.0,
            colorNR: _detailValues['Color NR'] ?? 0.0,
            removeChromaticAberration: _removeChromaticAberration,
            enableLensCorrection: _enableLensCorrection,
            shadowsColor: _hueSatToRgbVec3(_shadowsHue, _shadowsSat),
            midtonesColor: _hueSatToRgbVec3(_midtonesHue, _midtonesSat),
            highlightsColor: _hueSatToRgbVec3(_highlightsHue, _highlightsSat),
            cgBlending: _cgBlending,
            cgBalance: _cgBalance,
            custom3dLutImage: _custom3dLutImage,
            lutSize: state.session?.currentParameters.lutSize ?? 0.0,
            lutIntensity: state.session?.currentParameters.lutIntensity ?? 1.0,
            maskImage: _customMaskTexture,
            hasMask: realActiveMask != null && realActiveMask.isVisible,
            maskExposure: realActiveMask?.exposure ?? 0.0,
            maskContrast: realActiveMask?.contrast ?? 0.0,
            maskShadows: realActiveMask?.shadows ?? 0.0,
            maskSaturation: realActiveMask?.saturation ?? 0.0,
            maskTemperature: realActiveMask?.temperature ?? 0.0,
            maskTint: realActiveMask?.tint ?? 0.0,
            showMaskOverlay: _showMaskOverlay,
            activeMask: realActiveMask,
            currentBrushPoint: _currentBrushPoint,
            currentBrushRadius: _currentBrushRadius,
          );

    final double tiltX = _perspectiveVertical * 0.005;
    final double tiltY = _perspectiveHorizontal * 0.005;

    Widget transformedCanvas = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(tiltX)
        ..rotateY(tiltY)
        ..rotateZ(_rotation * 3.1415926535 / 180.0)
        ..scale(_flipHorizontal ? -1.0 : 1.0, _flipVertical ? -1.0 : 1.0),
      child: canvasWidget,
    );

    Widget croppedCanvas = ClipPath(
      clipper: CropClipper(
        cropLeft: _cropLeft,
        cropTop: _cropTop,
        cropRight: _cropRight,
        cropBottom: _cropBottom,
      ),
      child: transformedCanvas,
    );

    if (_currentToolLabel == 'Geometry') {
      return Stack(
        children: [
          Positioned.fill(child: transformedCanvas),
          Positioned.fill(
            child: CropOverlay(
              cropLeft: _cropLeft,
              cropTop: _cropTop,
              cropRight: _cropRight,
              cropBottom: _cropBottom,
              aspectRatio: _aspectRatio,
              onCropChanged: (l, t, r, b) {
                final session = context.read<EditorBloc>().state.session;
                if (session == null) return;
                final updated = session.currentParameters.copyWith(
                  cropLeft: l,
                  cropTop: t,
                  cropRight: r,
                  cropBottom: b,
                );
                context.read<EditorBloc>().add(UpdateGeometry(updated));
              },
            ),
          ),
        ],
      );
    } else {
      if (_currentToolLabel == 'Masking') {
        return LayoutBuilder(
          builder: (context, constraints) {
            final imageAspect = imageToRender.width / imageToRender.height;
            final parentAspect = constraints.maxWidth / constraints.maxHeight;

            double canvasWidth;
            double canvasHeight;
            if (imageAspect > parentAspect) {
              canvasWidth = constraints.maxWidth;
              canvasHeight = canvasWidth / imageAspect;
            } else {
              canvasHeight = constraints.maxHeight;
              canvasWidth = canvasHeight * imageAspect;
            }
            final Size canvasSize = Size(canvasWidth, canvasHeight);
            final leftOffset = (constraints.maxWidth - canvasWidth) / 2;
            final topOffset = (constraints.maxHeight - canvasHeight) / 2;
            final Offset leftTopOffset = Offset(leftOffset, topOffset);

            return GestureDetector(
              onPanStart: (details) => _handleMaskPanStart(details, canvasSize, leftTopOffset),
              onPanUpdate: (details) => _handleMaskPanUpdate(details, canvasSize, leftTopOffset),
              onPanEnd: (details) => _handleMaskPanEnd(details),
              behavior: HitTestBehavior.opaque,
              child: croppedCanvas,
            );
          },
        );
      }
      return croppedCanvas;
    }
  }

  /// Panel header: Title & Action Items
  Widget _buildPanelHeader(EditorState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Text(
            _currentToolLabel == 'Masking'
                ? 'Subject'
                : _showCurves
                    ? 'Curves'
                    : _showHslMixer
                        ? 'Color Mixer'
                        : _currentToolLabel.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (_currentToolLabel == 'Light') ...[
            // Curve Chip Button (Mockup Screen 2)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCurves = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _showCurves ? const Color(0xFF1F2133) : const Color(0xFF141522),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _showCurves
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      size: 14,
                      color: _showCurves ? AppColors.primary : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Curve',
                      style: AppTypography.labelMedium.copyWith(
                        color: _showCurves ? AppColors.primary : AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_currentToolLabel == 'Masking') ...[
            // Masking options icons (Mockup Screen 3)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _maskingValues['Exposure'] = 0.0;
                  _maskingValues['Contrast'] = 0.0;
                  _maskingValues['Shadows'] = 0.0;
                  _maskingValues['Saturation'] = 0.0;
                });
              },
            ),
            const SizedBox(width: 14),
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded, size: 20),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
            ),
          ],
        ],
      ),
    );
  }

  /// Penampung slider penyesuaian modular dengan animasi transisi
  Widget _buildAdjustmentSliders(EditorState state) {
    if (state.session == null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final params = state.session!.currentParameters;
    final panelContent = _buildPanelContent(state, params);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(_currentToolLabel + (_showCurves ? '_curves' : _showHslMixer ? '_hsl' : _showColorGrading ? '_cg' : '')),
        child: panelContent,
      ),
    );
  }

  Widget _buildPanelContent(EditorState state, EditParameters params) {
    switch (_currentToolLabel) {
      case 'Presets':
        return PresetsPanel(currentParameters: params);
      case 'Riwayat':
        return HistoryPanel(
          history: state.history,
          currentHistoryIndex: state.currentHistoryIndex,
          snapshots: state.snapshots,
          onStepSelected: (index) {
            context.read<EditorBloc>().add(NavigateHistory(index));
          },
          onCreateSnapshot: (name) {
            context.read<EditorBloc>().add(CreateSnapshot(name));
          },
          onApplySnapshot: (snapshot) {
            context.read<EditorBloc>().add(ApplySnapshot(snapshot));
          },
          onDeleteSnapshot: (snapshotId) {
            context.read<EditorBloc>().add(DeleteSnapshot(snapshotId));
          },
        );
      case 'Light':
        // Curves Panel atau Light Panel utama
        if (_showCurves) {
          return CurvesPanel(
            curveData: _currentCurveData,
            onChanged: (newCurve) {
              setState(() {
                _currentCurveData = newCurve;
              });
              _updateLutImage(newCurve);
            },
            onChangeEnd: (channel, points) {
              context.read<EditorBloc>().add(UpdateCurves(
                    channel: channel,
                    points: points,
                  ));
            },
            onDonePressed: () {
              setState(() {
                _showCurves = false;
              });
            },
          );
        }

        return LightPanel(
          parameters: params.copyWith(
            exposure: _lightValues['Exposure'] ?? params.exposure,
            contrast: _lightValues['Contrast'] ?? params.contrast,
            highlights: _lightValues['Highlights'] ?? params.highlights,
            shadows: _lightValues['Shadows'] ?? params.shadows,
            whites: _lightValues['Whites'] ?? params.whites,
            blacks: _lightValues['Blacks'] ?? params.blacks,
          ),
          onChanged: (key, val) {
            setState(() {
              _lightValues[key] = val;
            });
          },
          onChangeEnd: (key, val) {
            final updatedParams = params.copyWith(
              exposure: _lightValues['Exposure'],
              contrast: _lightValues['Contrast'],
              highlights: _lightValues['Highlights'],
              shadows: _lightValues['Shadows'],
              whites: _lightValues['Whites'],
              blacks: _lightValues['Blacks'],
            );
            context.read<EditorBloc>().add(UpdateLight(updatedParams));
          },
          onAutoPressed: () {
            final updated = params.copyWith(
              exposure: 0.35,
              contrast: 20.0,
              highlights: -40.0,
              shadows: 35.0,
              whites: 10.0,
              blacks: -15.0,
            );
            setState(() {
              _syncLocalValuesFromParams(updated);
            });
            context.read<EditorBloc>().add(UpdateLight(updated));
          },
        );
      case 'Color':
        // HSL Mixer Panel atau Color Panel utama
        if (_showHslMixer) {
          return HslPanel(
            adjustments: _hslAdjustments,
            onChanged: (channel, adjustment) {
              setState(() {
                _hslAdjustments = _hslAdjustments.copyWith(
                  red: channel == 'red' ? adjustment : null,
                  orange: channel == 'orange' ? adjustment : null,
                  yellow: channel == 'yellow' ? adjustment : null,
                  green: channel == 'green' ? adjustment : null,
                  aqua: channel == 'aqua' ? adjustment : null,
                  blue: channel == 'blue' ? adjustment : null,
                  purple: channel == 'purple' ? adjustment : null,
                  magenta: channel == 'magenta' ? adjustment : null,
                );
              });
            },
            onChangeEnd: (channel, adjustment) {
              context.read<EditorBloc>().add(UpdateHSL(
                    colorChannel: channel,
                    adjustment: adjustment,
                  ));
            },
            onDonePressed: () {
              setState(() {
                _showHslMixer = false;
              });
            },
          );
        }

        if (_showColorGrading) {
          return ColorGradingPanel(
            parameters: params.copyWith(
              shadowsHue: _shadowsHue,
              shadowsSat: _shadowsSat,
              midtonesHue: _midtonesHue,
              midtonesSat: _midtonesSat,
              highlightsHue: _highlightsHue,
              highlightsSat: _highlightsSat,
              cgBlending: _cgBlending,
              cgBalance: _cgBalance,
            ),
            onChanged: (newParams) {
              setState(() {
                _shadowsHue = newParams.shadowsHue;
                _shadowsSat = newParams.shadowsSat;
                _midtonesHue = newParams.midtonesHue;
                _midtonesSat = newParams.midtonesSat;
                _highlightsHue = newParams.highlightsHue;
                _highlightsSat = newParams.highlightsSat;
                _cgBlending = newParams.cgBlending;
                _cgBalance = newParams.cgBalance;
              });
            },
            onChangeEnd: (newParams) {
              context.read<EditorBloc>().add(UpdateColorGrading(newParams));
            },
            onDonePressed: () {
              setState(() {
                _showColorGrading = false;
              });
            },
          );
        }

        return ColorPanel(
          parameters: params.copyWith(
            temperature: _colorValues['Temperature'] ?? params.temperature,
            tint: _colorValues['Tint'] ?? params.tint,
            vibrance: _colorValues['Vibrance'] ?? params.vibrance,
            saturation: _colorValues['Saturation'] ?? params.saturation,
          ),
          onChanged: (key, val) {
            setState(() {
              _colorValues[key] = val;
            });
          },
          onChangeEnd: (key, val) {
            final updatedParams = params.copyWith(
              temperature: _colorValues['Temperature'],
              tint: _colorValues['Tint'],
              vibrance: _colorValues['Vibrance'],
              saturation: _colorValues['Saturation'],
            );
            context.read<EditorBloc>().add(UpdateColor(updatedParams));
          },
          onMixerPressed: () {
            setState(() {
              _showHslMixer = true;
            });
          },
          onGradingPressed: () {
            setState(() {
              _showColorGrading = true;
            });
          },
        );

      case 'Effects':
        return EffectsPanel(
          parameters: params.copyWith(
            texture: _effectsValues['Texture'] ?? params.texture,
            clarity: _effectsValues['Clarity'] ?? params.clarity,
            dehaze: _effectsValues['Dehaze'] ?? params.dehaze,
            vignette: _effectsValues['Vignette'] ?? params.vignette,
            grain: _effectsValues['Grain'] ?? params.grain,
          ),
          onChanged: (key, val) {
            setState(() {
              _effectsValues[key] = val;
            });
          },
          onChangeEnd: (key, val) {
            final updatedParams = params.copyWith(
              texture: _effectsValues['Texture'],
              clarity: _effectsValues['Clarity'],
              dehaze: _effectsValues['Dehaze'],
              vignette: _effectsValues['Vignette'],
              grain: _effectsValues['Grain'],
            );
            context.read<EditorBloc>().add(UpdateEffects(updatedParams));
          },
        );

      case 'Detail':
        return DetailPanel(
          parameters: params.copyWith(
            sharpeningAmount: _detailValues['Sharpening'] ?? params.sharpeningAmount,
            sharpeningRadius: _detailValues['Radius'] ?? params.sharpeningRadius,
            sharpeningDetail: _detailValues['Detail'] ?? params.sharpeningDetail,
            sharpeningMasking: _detailValues['Masking'] ?? params.sharpeningMasking,
            luminanceNR: _detailValues['Luminance NR'] ?? params.luminanceNR,
            colorNR: _detailValues['Color NR'] ?? params.colorNR,
          ),
          onChanged: (key, val) {
            setState(() {
              _detailValues[key] = val;
            });
          },
          onChangeEnd: (key, val) {
            final updatedParams = params.copyWith(
              sharpeningAmount: _detailValues['Sharpening'],
              sharpeningRadius: _detailValues['Radius'],
              sharpeningDetail: _detailValues['Detail'],
              sharpeningMasking: _detailValues['Masking'],
              luminanceNR: _detailValues['Luminance NR'],
              colorNR: _detailValues['Color NR'],
            );
            context.read<EditorBloc>().add(UpdateDetail(updatedParams));
          },
        );

      case 'Optics':
        return OpticsPanel(
          parameters: params.copyWith(
            removeChromaticAberration: _removeChromaticAberration,
            enableLensCorrection: _enableLensCorrection,
          ),
          onChromaticAberrationChanged: (val) {
            setState(() {
              _removeChromaticAberration = val;
            });
            final updatedParams = params.copyWith(removeChromaticAberration: val);
            context.read<EditorBloc>().add(UpdateOptics(updatedParams));
          },
          onLensCorrectionChanged: (val) {
            setState(() {
              _enableLensCorrection = val;
            });
            final updatedParams = params.copyWith(enableLensCorrection: val);
            context.read<EditorBloc>().add(UpdateOptics(updatedParams));
          },
        );

      case 'LUT':
        return LutPanel(
          parameters: params,
          onLutChanged: ({lutPath, required lutIntensity, required lutSize}) {
            context.read<EditorBloc>().add(UpdateLut(
                  lutPath: lutPath,
                  lutSize: lutSize,
                  lutIntensity: lutIntensity,
                ));
          },
        );

      case 'Masking':
        final activeParams = _tempParameters ?? params;
        return MaskingPanel(
          parameters: activeParams,
          showOverlay: _showMaskOverlay,
          onToggleOverlay: (val) {
            setState(() {
              _showMaskOverlay = val;
            });
          },
          onChanged: (updated) {
            setState(() {
              _tempParameters = updated;
            });
            final activeId = updated.activeMaskId;
            final activeMask = activeId != null
                ? updated.masks.firstWhere(
                    (m) => m.id == activeId,
                    orElse: () => const MaskModel(id: '', name: '', type: MaskType.brush),
                  )
                : null;
            if (activeMask != null && activeMask.id.isNotEmpty) {
              _regenerateMaskTexture(activeMask);
            } else {
              setState(() {
                _customMaskTexture = null;
              });
            }
          },
          onChangeEnd: (updated) {
            context.read<EditorBloc>().add(UpdateMasks(updated));
          },
        );

      case 'Geometry':
        return GeometryPanel(
          parameters: params,
          onChanged: (updated) {
            setState(() {
              _syncLocalValuesFromParams(updated);
            });
          },
          onChangeEnd: (updated) {
            context.read<EditorBloc>().add(UpdateGeometry(updated));
          },
        );

      default:
        // Default (menggunakan local state untuk panel lainnya)
        return AdjustmentPanel(
          values: _currentValues,
          onChanged: (key, val) {
            setState(() {
              _currentValues[key] = val;
            });
          },
        );
    }
  }

  /// Penyeleksi alat modular
  Widget _buildToolSelector() {
    return ToolSelector(
      selectedIndex: _selectedToolIndex,
      tools: _tools,
      onToolSelected: (index) {
        setState(() {
          _selectedToolIndex = index;
          _showHslMixer = false;
          _showCurves = false;
          _showColorGrading = false; // Reset sub-panel ketika berganti tool
        });
      },
    );
  }
}

/// Custom clipper untuk memotong pratonton gambar sesuai parameter crop
class CropClipper extends CustomClipper<Path> {
  final double cropLeft;
  final double cropTop;
  final double cropRight;
  final double cropBottom;

  CropClipper({
    required this.cropLeft,
    required this.cropTop,
    required this.cropRight,
    required this.cropBottom,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTRB(
      cropLeft * size.width,
      cropTop * size.height,
      cropRight * size.width,
      cropBottom * size.height,
    ));
    return path;
  }

  @override
  bool shouldReclip(covariant CropClipper oldClipper) {
    return oldClipper.cropLeft != cropLeft ||
        oldClipper.cropTop != cropTop ||
        oldClipper.cropRight != cropRight ||
        oldClipper.cropBottom != cropBottom;
  }
}
