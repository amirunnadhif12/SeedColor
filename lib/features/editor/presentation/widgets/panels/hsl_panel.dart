import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/hsl_adjustments.dart';

/// 🌱 SeedColor — HSL Color Mixer Panel
///
/// Panel kontrol warna HSL dengan pemilih 8 saluran warna horizontal,
/// 3 slider utama (Hue, Saturation, Luminance), dan tombol selesai (Done).
class HslPanel extends StatefulWidget {
  final HslAdjustments adjustments;
  final void Function(String channel, HslColorAdjustment adjustment) onChanged;
  final void Function(String channel, HslColorAdjustment adjustment) onChangeEnd;
  final VoidCallback onDonePressed;

  const HslPanel({
    super.key,
    required this.adjustments,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onDonePressed,
  });

  @override
  State<HslPanel> createState() => _HslPanelState();
}

class _HslPanelState extends State<HslPanel> {
  int _selectedColorIndex = 0;

  // Nama channel HSL yang sesuai dengan use case
  final List<String> _channels = [
    'red',
    'orange',
    'yellow',
    'green',
    'aqua',
    'blue',
    'purple',
    'magenta',
  ];

  // Visual warna lingkaran pemilih
  final List<Color> _indicatorColors = [
    const Color(0xFFFF3B30), // Red
    const Color(0xFFFF9500), // Orange
    const Color(0xFFFFCC00), // Yellow
    const Color(0xFF34C759), // Green
    const Color(0xFF5AC8FA), // Aqua (Cyan)
    const Color(0xFF007AFF), // Blue (Indigo)
    const Color(0xFFAF52DE), // Purple
    const Color(0xFFFF2D55), // Magenta
  ];

  String get _activeChannel => _channels[_selectedColorIndex];
  Color get _activeColor => _indicatorColors[_selectedColorIndex];

  HslColorAdjustment get _activeAdjustment {
    switch (_activeChannel) {
      case 'red':
        return widget.adjustments.red;
      case 'orange':
        return widget.adjustments.orange;
      case 'yellow':
        return widget.adjustments.yellow;
      case 'green':
        return widget.adjustments.green;
      case 'aqua':
        return widget.adjustments.aqua;
      case 'blue':
        return widget.adjustments.blue;
      case 'purple':
        return widget.adjustments.purple;
      case 'magenta':
        return widget.adjustments.magenta;
      default:
        return const HslColorAdjustment();
    }
  }

  // Menentukan gradien track khusus slider HUE berdasarkan warna aktif
  LinearGradient _getHueGradient() {
    switch (_activeChannel) {
      case 'red':
        return const LinearGradient(
          colors: [Color(0xFFFF2D55), Color(0xFFFF3B30), Color(0xFFFF9500)],
        );
      case 'orange':
        return const LinearGradient(
          colors: [Color(0xFFFF3B30), Color(0xFFFF9500), Color(0xFFFFCC00)],
        );
      case 'yellow':
        return const LinearGradient(
          colors: [Color(0xFFFF9500), Color(0xFFFFCC00), Color(0xFF34C759)],
        );
      case 'green':
        return const LinearGradient(
          colors: [Color(0xFFFFCC00), Color(0xFF34C759), Color(0xFF5AC8FA)],
        );
      case 'aqua':
        return const LinearGradient(
          colors: [Color(0xFF34C759), Color(0xFF5AC8FA), Color(0xFF007AFF)],
        );
      case 'blue':
        return const LinearGradient(
          colors: [Color(0xFF5AC8FA), Color(0xFF007AFF), Color(0xFFAF52DE)],
        );
      case 'purple':
        return const LinearGradient(
          colors: [Color(0xFF007AFF), Color(0xFFAF52DE), Color(0xFFFF2D55)],
        );
      case 'magenta':
        return const LinearGradient(
          colors: [Color(0xFFAF52DE), Color(0xFFFF2D55), Color(0xFFFF3B30)],
        );
      default:
        return const LinearGradient(colors: [Colors.white, Colors.black]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adj = _activeAdjustment;

    // Gradient warna untuk slider Saturation (Grey ke warna aktif)
    final satGradient = LinearGradient(
      colors: [
        const Color(0xFF8E8E93), // Neutral Grey desaturated
        _activeColor,
      ],
    );

    // Gradient warna untuk slider Luminance (Hitam ke warna aktif ke Putih)
    final lumGradient = LinearGradient(
      colors: [
        Colors.black,
        _activeColor,
        Colors.white,
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          // ─── Header & Pemilih Warna Horizontal ────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                // Horizontal list of colors
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _indicatorColors.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedColorIndex == index;
                        final color = _indicatorColors[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColorIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.5),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Done button
                GestureDetector(
                  onTap: widget.onDonePressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141522),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Sliders (H, S, L) ─────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              physics: const BouncingScrollPhysics(),
              children: [
                SeedSlider(
                  key: ValueKey('${_activeChannel}_hue'),
                  label: 'Hue',
                  value: adj.hue,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) {
                    widget.onChanged(
                      _activeChannel,
                      adj.copyWith(hue: val),
                    );
                  },
                  onChangeEnd: (val) {
                    widget.onChangeEnd(
                      _activeChannel,
                      adj.copyWith(hue: val),
                    );
                  },
                  trackGradient: _getHueGradient(),
                  accentColor: Colors.transparent,
                ),
                SeedSlider(
                  key: ValueKey('${_activeChannel}_saturation'),
                  label: 'Sat',
                  value: adj.saturation,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) {
                    widget.onChanged(
                      _activeChannel,
                      adj.copyWith(saturation: val),
                    );
                  },
                  onChangeEnd: (val) {
                    widget.onChangeEnd(
                      _activeChannel,
                      adj.copyWith(saturation: val),
                    );
                  },
                  trackGradient: satGradient,
                  accentColor: Colors.transparent,
                ),
                SeedSlider(
                  key: ValueKey('${_activeChannel}_luminance'),
                  label: 'Lum',
                  value: adj.lightness,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) {
                    widget.onChanged(
                      _activeChannel,
                      adj.copyWith(lightness: val),
                    );
                  },
                  onChangeEnd: (val) {
                    widget.onChangeEnd(
                      _activeChannel,
                      adj.copyWith(lightness: val),
                    );
                  },
                  trackGradient: lumGradient,
                  accentColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
