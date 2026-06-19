import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../widgets/adjustment_panel.dart';
import '../widgets/image_canvas.dart';
import '../widgets/tool_selector.dart';

/// 🌱 SeedColor — Halaman Editor
///
/// Halaman utama pengeditan foto dengan tata letak visual Lightroom:
/// Pratinjau atas (70% layar, diakselerasi GPU) + Bilah Slider / Alat bawah (30% layar).
class EditorPage extends StatefulWidget {
  final String photoId;

  const EditorPage({super.key, required this.photoId});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage>
    with SingleTickerProviderStateMixin {
  int _selectedToolIndex = 0;

  // Resources for shader preview
  ui.Image? _testImage;
  ui.Image? _lutImage;
  ui.FragmentShader? _shader;
  bool _isLoading = true;

  final List<ToolItem> _tools = [
    const ToolItem(Icons.wb_sunny_rounded, 'Light', AppColors.toolLight),
    const ToolItem(Icons.palette_rounded, 'Color', AppColors.toolColor),
    const ToolItem(Icons.auto_awesome_rounded, 'Effects', AppColors.toolEffects),
    const ToolItem(Icons.details_rounded, 'Detail', AppColors.toolDetail),
    const ToolItem(Icons.crop_rounded, 'Geometry', AppColors.toolGeometry),
    const ToolItem(Icons.layers_rounded, 'Masking', AppColors.toolMasking),
  ];

  // ─── Light Panel Sliders ─────────────────────────────
  final Map<String, double> _lightValues = {
    'Exposure': 0.0,
    'Contrast': 0.0,
    'Highlights': 0.0,
    'Shadows': 0.0,
    'Whites': 0.0,
    'Blacks': 0.0,
  };

  // ─── Color Panel Sliders ─────────────────────────────
  final Map<String, double> _colorValues = {
    'Temperature': 0.0,
    'Tint': 0.0,
    'Vibrance': 0.0,
    'Saturation': 0.0,
  };

  // ─── Effects Panel Sliders ───────────────────────────
  final Map<String, double> _effectsValues = {
    'Texture': 0.0,
    'Clarity': 0.0,
    'Dehaze': 0.0,
    'Vignette': 0.0,
    'Grain': 0.0,
  };

  // ─── Detail Panel Sliders ────────────────────────────
  final Map<String, double> _detailValues = {
    'Sharpening': 40,
    'Radius': 1,
    'Detail': 25,
    'Masking': 0,
    'Luminance NR': 0,
    'Color NR': 25,
  };

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
      // 1. Load image (img/LOGO.png)
      final ByteData data = await rootBundle.load('img/LOGO.png');
      final Uint8List list = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo fi = await codec.getNextFrame();
      _testImage = fi.image;

      // 2. Create identity LUT
      _lutImage = await _createIdentityLut();

      // 3. Load shader (composite.frag)
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

  Future<ui.Image> _createIdentityLut() async {
    final completer = Completer<ui.Image>();
    final bytes = Uint8List(256 * 4);
    for (int i = 0; i < 256; i++) {
      bytes[i * 4 + 0] = i; // R
      bytes[i * 4 + 1] = i; // G
      bytes[i * 4 + 2] = i; // B
      bytes[i * 4 + 3] = i; // A (RGB Curve)
    }
    ui.decodeImageFromPixels(
      bytes,
      256,
      1,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ──────────────────────────────────
            _buildTopBar(),

            // ─── Image Preview ────────────────────────────
            Expanded(child: _buildImagePreview()),

            // ─── Panel Header ─────────────────────────────
            _buildPanelHeader(),

            // ─── Adjustment Sliders ───────────────────────
            _buildAdjustmentSliders(),

            // ─── Tool Selector Bar ────────────────────────
            _buildToolSelector(),
          ],
        ),
      ),
    );
  }

  /// Top bar dengan back, undo, redo, share
  Widget _buildTopBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Kembali',
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: AppColors.textTertiary,
            onPressed: () {},
            tooltip: 'Urungkan',
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            color: AppColors.textTertiary,
            onPressed: () {},
            tooltip: 'Ulangi',
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Ekspor',
          ),
        ],
      ),
    );
  }

  /// Pratinjau gambar modular yang terhubung ke ImageCanvas (GPU acceleration)
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
              'Gagal memuat mesin shader atau gambar',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ImageCanvas(
      image: _testImage!,
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
      textureAdjust: _effectsValues['Texture'] ?? 0.0,
      clarity: _effectsValues['Clarity'] ?? 0.0,
      dehaze: _effectsValues['Dehaze'] ?? 0.0,
      vignette: _effectsValues['Vignette'] ?? 0.0,
      grain: _effectsValues['Grain'] ?? 0.0,
    );
  }

  /// Panel header: Tool name + Curve toggle
  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Text(
            _currentToolLabel.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          if (_selectedToolIndex == 0) ...[
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Icon(
                    Icons.auto_graph_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Curve',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Penampung slider penyesuaian modular
  Widget _buildAdjustmentSliders() {
    return AdjustmentPanel(
      values: _currentValues,
      onChanged: (key, val) {
        setState(() {
          _currentValues[key] = val;
        });
      },
    );
  }

  /// Penyeleksi alat modular
  Widget _buildToolSelector() {
    return ToolSelector(
      selectedIndex: _selectedToolIndex,
      tools: _tools,
      onToolSelected: (index) {
        setState(() {
          _selectedToolIndex = index;
        });
      },
    );
  }
}
