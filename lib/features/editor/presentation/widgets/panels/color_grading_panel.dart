import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';
import 'package:seed_color/features/editor/presentation/widgets/panels/color_wheel.dart';

/// 🌱 SeedColor — Color Grading Panel
///
/// Panel kontrol Color Grading (Lightroom-style) yang mendukung pemisahan
/// warna bayangan (Shadows), nada tengah (Midtones), dan sorotan (Highlights)
/// menggunakan roda warna interaktif + slider Blending & Balance.
class ColorGradingPanel extends StatefulWidget {
  final EditParameters parameters;
  final void Function(EditParameters parameters) onChanged;
  final void Function(EditParameters parameters) onChangeEnd;
  final VoidCallback onDonePressed;

  const ColorGradingPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
    required this.onDonePressed,
  });

  @override
  State<ColorGradingPanel> createState() => _ColorGradingPanelState();
}

class _ColorGradingPanelState extends State<ColorGradingPanel> {
  String _activeChannel = 'shadows'; // 'shadows', 'midtones', 'highlights'

  @override
  Widget build(BuildContext context) {
    // Ambil data Hue dan Saturation untuk saluran terpilih
    double currentHue = 0.0;
    double currentSat = 0.0;
    Color channelActiveColor = Colors.white;

    if (_activeChannel == 'shadows') {
      currentHue = widget.parameters.shadowsHue;
      currentSat = widget.parameters.shadowsSat;
      channelActiveColor = const Color(0xFF3A86FF); // Blue tint for shadows representation
    } else if (_activeChannel == 'midtones') {
      currentHue = widget.parameters.midtonesHue;
      currentSat = widget.parameters.midtonesSat;
      channelActiveColor = const Color(0xFFFFB703); // Orange tint for midtones representation
    } else {
      currentHue = widget.parameters.highlightsHue;
      currentSat = widget.parameters.highlightsSat;
      channelActiveColor = const Color(0xFF06D6A0); // Teal tint for highlights representation
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          // ─── Header & Channel Selector ────────────────────
          Row(
            children: [
              // Selector Shadows, Midtones, Highlights
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleTab('shadows', 'Shadows', const Color(0xFF2C2C2E)),
                  const SizedBox(width: 10),
                  _buildCircleTab('midtones', 'Midtones', const Color(0xFF8E8E93)),
                  const SizedBox(width: 10),
                  _buildCircleTab('highlights', 'Highlights', const Color(0xFFE5E5EA)),
                ],
              ),
              const Spacer(),
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
          const SizedBox(height: 8),

          // ─── Main Content Area (Wheel on Left, Sliders on Right) ───
          Expanded(
            child: Row(
              children: [
                // 1. Roda Warna (Left Side)
                Expanded(
                  flex: 5,
                  child: Center(
                    child: ColorWheel(
                      hue: currentHue,
                      saturation: currentSat,
                      activeColor: channelActiveColor,
                      onChanged: (point) {
                        final updated = _updateParametersForChannel(point.x, point.y);
                        widget.onChanged(updated);
                      },
                      onChangeEnd: (point) {
                        final updated = _updateParametersForChannel(point.x, point.y);
                        widget.onChangeEnd(updated);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 2. Slider Blending & Balance (Right Side)
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SeedSlider(
                        label: 'Blending',
                        value: widget.parameters.cgBlending,
                        min: 0.0,
                        max: 100.0,
                        onChanged: (val) {
                          widget.onChanged(widget.parameters.copyWith(cgBlending: val));
                        },
                        onChangeEnd: (val) {
                          widget.onChangeEnd(widget.parameters.copyWith(cgBlending: val));
                        },
                        accentColor: AppColors.toolColor,
                      ),
                      const SizedBox(height: 4),
                      SeedSlider(
                        label: 'Balance',
                        value: widget.parameters.cgBalance,
                        min: -100.0,
                        max: 100.0,
                        onChanged: (val) {
                          widget.onChanged(widget.parameters.copyWith(cgBalance: val));
                        },
                        onChangeEnd: (val) {
                          widget.onChangeEnd(widget.parameters.copyWith(cgBalance: val));
                        },
                        accentColor: AppColors.toolColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Membuat tombol selector lingkaran berwarna mewakili setiap saluran
  Widget _buildCircleTab(String channel, String label, Color innerColor) {
    final isSelected = _activeChannel == channel;

    Color borderActiveColor;
    if (channel == 'shadows') {
      borderActiveColor = const Color(0xFF3A86FF);
    } else if (channel == 'midtones') {
      borderActiveColor = const Color(0xFFFFB703);
    } else {
      borderActiveColor = const Color(0xFF06D6A0);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeChannel = channel;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lingkaran visual
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? borderActiveColor : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: innerColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Label teks
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Memperbarui EditParameters berdasarkan saluran aktif saat roda warna diputar
  EditParameters _updateParametersForChannel(double hue, double sat) {
    if (_activeChannel == 'shadows') {
      return widget.parameters.copyWith(
        shadowsHue: hue,
        shadowsSat: sat,
      );
    } else if (_activeChannel == 'midtones') {
      return widget.parameters.copyWith(
        midtonesHue: hue,
        midtonesSat: sat,
      );
    } else {
      return widget.parameters.copyWith(
        highlightsHue: hue,
        highlightsSat: sat,
      );
    }
  }
}
