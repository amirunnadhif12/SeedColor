import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// 🌱 SeedColor — SeedSlider
///
/// Custom slider mirip Adobe Lightroom Mobile:
/// - Layout row: Label | Slider | Value
/// - Centered indicator: garis aktif dari titik center (0) ke thumb
/// - Opsional gradient track (temperature, tint, dll)
/// - Haptic feedback saat melewati titik center
/// - Value label floating tooltip (opsional)
///
/// ```dart
/// SeedSlider(
///   label: 'Exposure',
///   value: _exposure,
///   min: -5.0,
///   max: 5.0,
///   onChanged: (val) => setState(() => _exposure = val),
///   formatValue: (val) => '${val >= 0 ? "+" : ""}${val.toStringAsFixed(2)}',
/// )
/// ```
class SeedSlider extends StatefulWidget {
  /// Label yang ditampilkan di sisi kiri slider.
  final String label;

  /// Nilai slider saat ini.
  final double value;

  /// Nilai minimum slider.
  final double min;

  /// Nilai maksimum slider.
  final double max;

  /// Callback saat nilai berubah.
  final ValueChanged<double> onChanged;

  /// Callback saat user selesai drag (finger up).
  final ValueChanged<double>? onChangeEnd;

  /// Gradient opsional untuk track (misal: temperature → biru ke oranye).
  /// Jika null, track menggunakan warna default solid.
  final LinearGradient? trackGradient;

  /// Warna aksen untuk active track portion (dari center ke thumb).
  /// Default: AppColors.textPrimary dengan opacity.
  final Color? accentColor;

  /// Custom formatter untuk display value di sisi kanan.
  /// Jika null, format default integer (atau 2 desimal untuk range kecil).
  final String Function(double value)? formatValue;

  /// Apakah slider ini "centered" (center = 0)?
  /// Jika false, slider berperilaku seperti slider normal (dari min ke value).
  /// Default: true jika min < 0 dan max > 0.
  final bool? centered;

  /// Apakah menampilkan haptic feedback saat melewati center.
  /// Default: true.
  final bool hapticFeedback;

  /// Lebar label di sisi kiri.
  final double labelWidth;

  /// Lebar value di sisi kanan.
  final double valueWidth;

  const SeedSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.trackGradient,
    this.accentColor,
    this.formatValue,
    this.centered,
    this.hapticFeedback = true,
    this.labelWidth = 80,
    this.valueWidth = 46,
  });

  @override
  State<SeedSlider> createState() => _SeedSliderState();
}

class _SeedSliderState extends State<SeedSlider> {
  /// Track previous value untuk haptic feedback saat melewati center.
  double _previousValue = 0;
  bool _isDragging = false;

  bool get _isCentered {
    return widget.centered ?? (widget.min < 0 && widget.max > 0);
  }

  String get _displayValue {
    if (widget.formatValue != null) {
      return widget.formatValue!(widget.value);
    }

    // Auto-format: jika range kecil (< 20), tampilkan desimal
    final range = widget.max - widget.min;
    if (range <= 20) {
      return '${widget.value >= 0 ? "+" : ""}${widget.value.toStringAsFixed(2).replaceAll(".", ",")}';
    }

    final intVal = widget.value.round();
    return '${intVal >= 0 && _isCentered ? "+" : ""}$intVal';
  }

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  void _handleChanged(double newValue) {
    // Haptic feedback saat melewati center (0)
    if (widget.hapticFeedback && _isCentered) {
      if ((_previousValue < 0 && newValue >= 0) ||
          (_previousValue > 0 && newValue <= 0)) {
        HapticFeedback.selectionClick();
      }
    }
    _previousValue = newValue;
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 14),
      child: Row(
        children: [
          // ─── Label ─────────────────────────────────
          SizedBox(
            width: widget.labelWidth,
            child: Text(
              widget.label,
              style: AppTypography.bodySmall.copyWith(
                color: _isDragging
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),

          // ─── Centered Slider Track ─────────────────
          Expanded(
            child: _SeedSliderTrack(
              value: widget.value,
              min: widget.min,
              max: widget.max,
              centered: _isCentered,
              trackGradient: widget.trackGradient,
              accentColor: widget.accentColor,
              isDragging: _isDragging,
              onChanged: _handleChanged,
              onChangeStart: (_) => setState(() => _isDragging = true),
              onChangeEnd: (val) {
                setState(() => _isDragging = false);
                widget.onChangeEnd?.call(val);
              },
            ),
          ),

          // ─── Value Display ─────────────────────────
          SizedBox(
            width: widget.valueWidth,
            child: Text(
              _displayValue,
              textAlign: TextAlign.right,
              style: AppTypography.labelMedium.copyWith(
                color: _isDragging
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal slider track widget yang menggambar centered indicator.
class _SeedSliderTrack extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final bool centered;
  final LinearGradient? trackGradient;
  final Color? accentColor;
  final bool isDragging;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  const _SeedSliderTrack({
    required this.value,
    required this.min,
    required this.max,
    required this.centered,
    required this.onChanged,
    this.trackGradient,
    this.accentColor,
    this.isDragging = false,
    this.onChangeStart,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final range = max - min;

        // Calculate positions
        final centerFraction = centered ? (0 - min) / range : 0.0;
        final valueFraction = (value - min) / range;
        final centerX = width * centerFraction;
        final valueX = width * valueFraction;

        return SizedBox(
          height: 36,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // ─── Background Track ──────────────────
              Positioned(
                left: 0,
                right: 0,
                child: trackGradient != null
                    ? Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: trackGradient,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      )
                    : Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.sliderTrack,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
              ),

              // ─── Active Portion (center → thumb) ──
              if (centered)
                Positioned(
                  left: value >= 0 ? centerX : valueX,
                  width: (valueX - centerX).abs().clamp(0, width),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    height: isDragging ? 3 : 2,
                    decoration: BoxDecoration(
                      color: accentColor ??
                          AppColors.textPrimary
                              .withValues(alpha: isDragging ? 0.8 : 0.6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                )
              else
                Positioned(
                  left: 0,
                  width: valueX.clamp(0, width),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 50),
                    height: isDragging ? 3 : 2,
                    decoration: BoxDecoration(
                      color: accentColor ??
                          AppColors.textPrimary
                              .withValues(alpha: isDragging ? 0.8 : 0.6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),

              // ─── Center Dot Indicator ──────────────
              if (centered)
                Positioned(
                  left: centerX - 2,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // ─── Invisible Slider (gesture) ────────
              Positioned.fill(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 0,
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: isDragging
                        ? AppColors.primary
                        : AppColors.textPrimary,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: isDragging ? 7 : 6,
                    ),
                    overlayColor: AppColors.primary.withValues(alpha: 0.08),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                    onChangeStart: onChangeStart,
                    onChangeEnd: onChangeEnd,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Standalone centered slider tanpa layout row.
///
/// Gunakan ini jika ingin slider saja tanpa label/value di samping.
/// Untuk layout lengkap (label + slider + value), gunakan [SeedSlider].
class SeedSliderTrack extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final LinearGradient? trackGradient;
  final Color? accentColor;
  final bool centered;

  const SeedSliderTrack({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.trackGradient,
    this.accentColor,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    return _SeedSliderTrack(
      value: value,
      min: min,
      max: max,
      centered: centered,
      trackGradient: trackGradient,
      accentColor: accentColor,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
    );
  }
}
