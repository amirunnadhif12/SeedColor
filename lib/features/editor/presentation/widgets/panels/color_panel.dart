import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/app/theme/app_typography.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Color Panel
///
/// Panel kontrol warna dengan 4 slider utama (Temperature, Tint, Vibrance,
/// Saturation). Dilengkapi dengan gradient track bertema suhu/warna.
class ColorPanel extends StatelessWidget {
  final EditParameters parameters;
  final void Function(String key, double value) onChanged;
  final void Function(String key, double value) onChangeEnd;
  final VoidCallback? onMixerPressed;
  final VoidCallback? onGradingPressed;

  const ColorPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
    this.onMixerPressed,
    this.onGradingPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Gradient warna untuk slider Temperature (Biru ke Oranye)
    const tempGradient = LinearGradient(
      colors: [
        Color(0xFF3A86FF), // Biru (Cool)
        Color(0xFFE5E5E5), // Abu netral
        Color(0xFFFFB703), // Oranye (Warm)
      ],
      stops: [0.0, 0.5, 1.0],
    );

    // Gradient warna untuk slider Tint (Hijau ke Magenta)
    const tintGradient = LinearGradient(
      colors: [
        Color(0xFF06D6A0), // Hijau (Greenish)
        Color(0xFFE5E5E5), // Abu netral
        Color(0xFFFF006E), // Magenta (Pinkish)
      ],
      stops: [0.0, 0.5, 1.0],
    );

    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          // ─── Header Panel ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Visual Color Mixer Chip placeholder atau tombol HSL shortcut
                GestureDetector(
                  onTap: onMixerPressed,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.gradient_rounded,
                          size: 14,
                          color: AppColors.toolColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Mixer',
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
                const SizedBox(width: 8),
                // Tombol Color Grading shortcut
                GestureDetector(
                  onTap: onGradingPressed,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lens_blur_rounded,
                          size: 14,
                          color: AppColors.toolColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Grading',
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
              ],
            ),
          ),

          // ─── Daftar Sliders ───────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              physics: const BouncingScrollPhysics(),
              children: [
                SeedSlider(
                  label: 'Temp',
                  value: parameters.temperature,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Temperature', val),
                  onChangeEnd: (val) => onChangeEnd('Temperature', val),
                  trackGradient: tempGradient,
                  accentColor: Colors.transparent, // Agar background gradient terlihat utuh
                ),
                SeedSlider(
                  label: 'Tint',
                  value: parameters.tint,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Tint', val),
                  onChangeEnd: (val) => onChangeEnd('Tint', val),
                  trackGradient: tintGradient,
                  accentColor: Colors.transparent,
                ),
                SeedSlider(
                  label: 'Vibrance',
                  value: parameters.vibrance,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Vibrance', val),
                  onChangeEnd: (val) => onChangeEnd('Vibrance', val),
                  accentColor: AppColors.toolColor,
                ),
                SeedSlider(
                  label: 'Saturation',
                  value: parameters.saturation,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Saturation', val),
                  onChangeEnd: (val) => onChangeEnd('Saturation', val),
                  accentColor: AppColors.toolColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
