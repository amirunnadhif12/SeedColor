import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/math_utils.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/curve_data.dart';
import '../../domain/entities/edit_parameters.dart';
import '../../domain/entities/hsl_adjustments.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import '../widgets/adjustment_panel.dart';
import '../widgets/image_canvas.dart';
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
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../widgets/crop/crop_overlay.dart';

/// 🌱 SeedColor — Editor Screen Wrapper
///
/// Pembungkus halaman editor untuk menyediakan BLoC secara lokal
/// dan memulai sesi pengeditan baru.
class EditorScreen extends StatelessWidget {
  final String photoId;

  const EditorScreen({super.key, required this.photoId});

  @override
  Widget build(BuildContext context) {
    if (photoId == 'sample' || photoId.isEmpty) {
      return BlocProvider<EditorBloc>(
        create: (context) => sl<EditorBloc>()
          ..add(StartSession(
            photoId: 'sample',
            imagePath: 'assets/images/mountain_lake.png',
          )),
        child: const EditorPage(photoId: 'sample'),
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
          child: EditorPage(photoId: photoId),
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

  const EditorPage({super.key, required this.photoId});

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
  ui.Image? _maskedImage;
  ui.Image? _lutImage;
  ui.FragmentShader? _shader;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _rating = 0;

  final List<ToolItem> _tools = [
    const ToolItem(Icons.wb_sunny_rounded, 'Light', AppColors.toolLight),
    const ToolItem(Icons.palette_rounded, 'Color', AppColors.toolColor),
    const ToolItem(Icons.auto_awesome_rounded, 'Effects', AppColors.toolEffects),
    const ToolItem(Icons.details_rounded, 'Detail', AppColors.toolDetail),
    const ToolItem(Icons.camera_rounded, 'Optics', Color(0xFFBC8CFF)),
    const ToolItem(Icons.crop_rounded, 'Geometry', AppColors.toolGeometry),
    const ToolItem(Icons.layers_rounded, 'Masking', AppColors.toolMasking),
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
    'Sharpening': 40,
    'Radius': 1,
    'Detail': 25,
    'Masking': 0,
    'Luminance NR': 0,
    'Color NR': 25,
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
    switch (_selectedToolIndex) {
      case 0:
        return _lightValues;
      case 1:
        return _colorValues;
      case 2:
        return _effectsValues;
      case 3:
        return _detailValues;
      case 4:
        return {};
      case 5:
        return {};
      case 6:
        return _maskingValues;
      default:
        return _lightValues;
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
          final file = File(dbPhoto.path);
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

      // 2. Load masked mountain lake image
      final ByteData maskedData = await rootBundle.load('assets/images/mountain_lake_masked.png');
      final Uint8List maskedList = maskedData.buffer.asUint8List();
      final ui.Codec maskedCodec = await ui.instantiateImageCodec(maskedList);
      final ui.FrameInfo maskedFi = await maskedCodec.getNextFrame();
      _maskedImage = maskedFi.image;

      // 3. Create LUT from current curve data
      _lutImage = await _generateLutImage(_currentCurveData);

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
          _syncLocalValuesFromParams(state.session!.currentParameters);
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
                        child: _buildImagePreview(),
                      ),
                      if (_selectedToolIndex == 6) _buildMaskingSidebar(),
                    ],
                  ),
                ),

                // ─── Panel Header ─────────────────────────────
                _buildPanelHeader(state),

                // ─── Adjustment Sliders ───────────────────────
                _buildAdjustmentSliders(state),

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
    if (_selectedToolIndex == 6) {
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
                  _selectedToolIndex = 0; // Go back to Light
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
                  _selectedToolIndex = 0; // Confirm & go back
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
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
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
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {
              if (state.session != null) {
                bloc.add(const Export(
                  outputPath: '/storage/emulated/0/Download/SeedColor_export.jpg',
                  quality: 90,
                ));
              }
            },
            tooltip: 'Export',
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
    return Positioned(
      right: 16,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Plus button
          GestureDetector(
            onTap: () {},
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
                  isSelected: true,
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.cloud_queue_rounded,
                  label: 'Sky',
                  isSelected: false,
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.brush_outlined,
                  label: 'Brush',
                  isSelected: false,
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.linear_scale_rounded,
                  label: 'Linear',
                  isSelected: false,
                ),
                const SizedBox(height: 12),
                _buildFloatingToolItem(
                  icon: Icons.adjust_rounded,
                  label: 'Radial',
                  isSelected: false,
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
  }) {
    return Column(
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
    );
  }

  /// Main canvas, feeding current tool selected values to GLSL Shader
  Widget _buildImagePreview() {
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

    // Load masked hiker image if masking is active (Screen 3)
    final imageToRender = (_selectedToolIndex == 6) ? (_maskedImage ?? _testImage!) : _testImage!;

    final canvasWidget = ImageCanvas(
      image: imageToRender,
      lutImage: _lutImage!,
      shader: _shader!,
      // Dynamically select values depending on tool
      exposure: _selectedToolIndex == 6
          ? (_maskingValues['Exposure'] ?? 0.0)
          : (_lightValues['Exposure'] ?? 0.0),
      contrast: _selectedToolIndex == 6
          ? (_maskingValues['Contrast'] ?? 0.0)
          : (_lightValues['Contrast'] ?? 0.0),
      highlights: _selectedToolIndex == 6 ? 0.0 : (_lightValues['Highlights'] ?? 0.0),
      shadows: _selectedToolIndex == 6
          ? (_maskingValues['Shadows'] ?? 0.0)
          : (_lightValues['Shadows'] ?? 0.0),
      whites: _selectedToolIndex == 6 ? 0.0 : (_lightValues['Whites'] ?? 0.0),
      blacks: _selectedToolIndex == 6 ? 0.0 : (_lightValues['Blacks'] ?? 0.0),
      temperature: _colorValues['Temperature'] ?? 0.0,
      tint: _colorValues['Tint'] ?? 0.0,
      vibrance: _colorValues['Vibrance'] ?? 0.0,
      saturation: _selectedToolIndex == 6
          ? (_maskingValues['Saturation'] ?? 0.0)
          : (_colorValues['Saturation'] ?? 0.0),
      hslAdjustments: _hslAdjustments,
      textureAdjust: _effectsValues['Texture'] ?? 0.0,
      clarity: _effectsValues['Clarity'] ?? 0.0,
      dehaze: _effectsValues['Dehaze'] ?? 0.0,
      vignette: _effectsValues['Vignette'] ?? 0.0,
      grain: _effectsValues['Grain'] ?? 0.0,
      sharpeningAmount: _detailValues['Sharpening'] ?? 40.0,
      sharpeningRadius: _detailValues['Radius'] ?? 1.0,
      sharpeningDetail: _detailValues['Detail'] ?? 25.0,
      sharpeningMasking: _detailValues['Masking'] ?? 0.0,
      luminanceNR: _detailValues['Luminance NR'] ?? 0.0,
      colorNR: _detailValues['Color NR'] ?? 25.0,
      removeChromaticAberration: _removeChromaticAberration,
      enableLensCorrection: _enableLensCorrection,
      shadowsColor: _hueSatToRgbVec3(_shadowsHue, _shadowsSat),
      midtonesColor: _hueSatToRgbVec3(_midtonesHue, _midtonesSat),
      highlightsColor: _hueSatToRgbVec3(_highlightsHue, _highlightsSat),
      cgBlending: _cgBlending,
      cgBalance: _cgBalance,
    );

    // Apply 3D Perspective, Flip, and Rotation
    final double tiltX = _perspectiveVertical * 0.005;
    final double tiltY = _perspectiveHorizontal * 0.005;

    Widget transformedCanvas = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective depth
        ..rotateX(tiltX)
        ..rotateY(tiltY)
        ..rotateZ(_rotation * 3.1415926535 / 180.0)
        ..scale(_flipHorizontal ? -1.0 : 1.0, _flipVertical ? -1.0 : 1.0),
      child: canvasWidget,
    );

    if (_selectedToolIndex == 5) {
      // In geometry editing mode, show the full transformed image with CropOverlay on top
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
      // In normal mode, clip the image preview to show only the cropped portion
      return ClipPath(
        clipper: CropClipper(
          cropLeft: _cropLeft,
          cropTop: _cropTop,
          cropRight: _cropRight,
          cropBottom: _cropBottom,
        ),
        child: transformedCanvas,
      );
    }
  }

  /// Panel header: Title & Action Items
  Widget _buildPanelHeader(EditorState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Text(
            _selectedToolIndex == 6
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
          if (_selectedToolIndex == 0) ...[
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
          ] else if (_selectedToolIndex == 6) ...[
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

  /// Penampung slider penyesuaian modular
  Widget _buildAdjustmentSliders(EditorState state) {
    if (state.session == null) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final params = state.session!.currentParameters;

    switch (_selectedToolIndex) {
      case 0:
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
      case 1:
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

      case 2:
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

      case 3:
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

      case 4:
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

      case 5:
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
