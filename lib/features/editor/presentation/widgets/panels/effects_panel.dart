import 'package:flutter/material.dart';
import 'package:seed_color/app/theme/app_colors.dart';
import 'package:seed_color/core/widgets/seed_slider.dart';
import 'package:seed_color/features/editor/domain/entities/edit_parameters.dart';

/// 🌱 SeedColor — Effects Panel
///
/// Panel kontrol efek dengan 5 slider utama (Texture, Clarity, Dehaze,
/// Vignette, Grain) untuk mengatur detail mikro, kabut, vinyet, dan noise film.
class EffectsPanel extends StatelessWidget {
  final EditParameters parameters;
  final void Function(String key, double value) onChanged;
  final void Function(String key, double value) onChangeEnd;

  const EffectsPanel({
    super.key,
    required this.parameters,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Column(
        children: [
          // Spacer atas kecil agar sejajar dengan panel lainnya
          const SizedBox(height: 12),
          // Daftar Sliders
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              physics: const BouncingScrollPhysics(),
              children: [
                SeedSlider(
                  label: 'Tekstur',
                  value: parameters.texture,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Texture', val),
                  onChangeEnd: (val) => onChangeEnd('Texture', val),
                  accentColor: AppColors.toolEffects,
                ),
                SeedSlider(
                  label: 'Kejernihan',
                  value: parameters.clarity,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Clarity', val),
                  onChangeEnd: (val) => onChangeEnd('Clarity', val),
                  accentColor: AppColors.toolEffects,
                ),
                SeedSlider(
                  label: 'Dehaze',
                  value: parameters.dehaze,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Dehaze', val),
                  onChangeEnd: (val) => onChangeEnd('Dehaze', val),
                  accentColor: AppColors.toolEffects,
                ),
                SeedSlider(
                  label: 'Vinyet',
                  value: parameters.vignette,
                  min: -100.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Vignette', val),
                  onChangeEnd: (val) => onChangeEnd('Vignette', val),
                  accentColor: AppColors.toolEffects,
                ),
                SeedSlider(
                  label: 'Grain',
                  value: parameters.grain,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (val) => onChanged('Grain', val),
                  onChangeEnd: (val) => onChangeEnd('Grain', val),
                  accentColor: AppColors.toolEffects,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
