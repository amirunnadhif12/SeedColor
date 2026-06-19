import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/edit_parameters.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import '../widgets/adjustment_panel.dart';
import '../widgets/image_canvas.dart';
import '../widgets/tool_selector.dart';
import '../widgets/panels/light_panel.dart';
import '../widgets/panels/color_panel.dart';

/// 🌱 SeedColor — Editor Screen Wrapper
///
/// Pembungkus halaman editor untuk menyediakan BLoC secara lokal
/// dan memulai sesi pengeditan baru.
class EditorScreen extends StatelessWidget {
  final String photoId;

  const EditorScreen({super.key, required this.photoId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditorBloc>(
      create: (context) => sl<EditorBloc>()
        ..add(StartSession(
          photoId: photoId,
          imagePath: 'assets/images/mountain_lake.png',
        )),
      child: EditorPage(photoId: photoId),
    );
  }
}

/// 🌱 SeedColor — Editor Page
///
/// Refactored Editor Screen to support dynamic Light & Color panels with EditorBloc.
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
  ui.Image? _maskedImage;
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

  // ─── Masking Panel Sliders (Preset to Mockup Values) ────
  final Map<String, double> _maskingValues = {
    'Exposure': 0.40,
    'Contrast': 15.0,
    'Shadows': 25.0,
    'Saturation': 10.0,
  };

  // ─── Geometry Panel Placeholder Sliders ──────────────
  final Map<String, double> _geometryValues = {
    'Rotate': 0.0,
    'Horizontal Perspective': 0.0,
    'Vertical Perspective': 0.0,
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
      case 4:
        return _geometryValues;
      case 5:
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
      // 1. Load main mountain lake image
      final ByteData data = await rootBundle.load('assets/images/mountain_lake.png');
      final Uint8List list = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(list);
      final ui.FrameInfo fi = await codec.getNextFrame();
      _testImage = fi.image;

      // 2. Load masked mountain lake image
      final ByteData maskedData = await rootBundle.load('assets/images/mountain_lake_masked.png');
      final Uint8List maskedList = maskedData.buffer.asUint8List();
      final ui.Codec maskedCodec = await ui.instantiateImageCodec(maskedList);
      final ui.FrameInfo maskedFi = await maskedCodec.getNextFrame();
      _maskedImage = maskedFi.image;

      // 3. Create identity LUT
      _lutImage = await _createIdentityLut();

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

    _effectsValues['Texture'] = params.texture;
    _effectsValues['Clarity'] = params.clarity;
    _effectsValues['Dehaze'] = params.dehaze;
    _effectsValues['Vignette'] = params.vignette;
    _effectsValues['Grain'] = params.grain;
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

        // Sinkronisasi local slider values dengan state BLoC
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
                      if (_selectedToolIndex == 5) _buildMaskingSidebar(),
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
    if (_selectedToolIndex == 5) {
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
    final imageToRender = (_selectedToolIndex == 5) ? (_maskedImage ?? _testImage!) : _testImage!;

    return ImageCanvas(
      image: imageToRender,
      lutImage: _lutImage!,
      shader: _shader!,
      // Dynamically select values depending on tool
      exposure: _selectedToolIndex == 5
          ? (_maskingValues['Exposure'] ?? 0.0)
          : (_lightValues['Exposure'] ?? 0.0),
      contrast: _selectedToolIndex == 5
          ? (_maskingValues['Contrast'] ?? 0.0)
          : (_lightValues['Contrast'] ?? 0.0),
      highlights: _selectedToolIndex == 5 ? 0.0 : (_lightValues['Highlights'] ?? 0.0),
      shadows: _selectedToolIndex == 5
          ? (_maskingValues['Shadows'] ?? 0.0)
          : (_lightValues['Shadows'] ?? 0.0),
      whites: _selectedToolIndex == 5 ? 0.0 : (_lightValues['Whites'] ?? 0.0),
      blacks: _selectedToolIndex == 5 ? 0.0 : (_lightValues['Blacks'] ?? 0.0),
      temperature: _colorValues['Temperature'] ?? 0.0,
      tint: _colorValues['Tint'] ?? 0.0,
      vibrance: _colorValues['Vibrance'] ?? 0.0,
      saturation: _selectedToolIndex == 5
          ? (_maskingValues['Saturation'] ?? 0.0)
          : (_colorValues['Saturation'] ?? 0.0),
      textureAdjust: _effectsValues['Texture'] ?? 0.0,
      clarity: _effectsValues['Clarity'] ?? 0.0,
      dehaze: _effectsValues['Dehaze'] ?? 0.0,
      vignette: _effectsValues['Vignette'] ?? 0.0,
      grain: _effectsValues['Grain'] ?? 0.0,
    );
  }

  /// Panel header: Title & Action Items
  Widget _buildPanelHeader(EditorState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Text(
            _selectedToolIndex == 5 ? 'Subject' : _currentToolLabel.toUpperCase(),
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
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF141522),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_graph_rounded,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Curve',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_selectedToolIndex == 5) ...[
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
        // Light Panel
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
        // Color Panel
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
        });
      },
    );
  }
}
