import 'package:equatable/equatable.dart';

/// 🌱 SeedColor — HSL Per-color Adjustment
///
/// Menyimpan data penyesuaian Hue, Saturation, dan Lightness (Luminance)
/// untuk satu saluran warna tertentu.
class HslColorAdjustment extends Equatable {
  final double hue;        // -100.0 s.d. 100.0
  final double saturation; // -100.0 s.d. 100.0
  final double lightness;  // -100.0 s.d. 100.0

  const HslColorAdjustment({
    this.hue = 0.0,
    this.saturation = 0.0,
    this.lightness = 0.0,
  });

  HslColorAdjustment copyWith({
    double? hue,
    double? saturation,
    double? lightness,
  }) {
    return HslColorAdjustment(
      hue: hue ?? this.hue,
      saturation: saturation ?? this.saturation,
      lightness: lightness ?? this.lightness,
    );
  }

  @override
  List<Object?> get props => [hue, saturation, lightness];
}

/// 🌱 SeedColor — HSL Adjustments Group
///
/// Menyimpan kumpulan penyesuaian HSL untuk 8 saluran warna utama.
class HslAdjustments extends Equatable {
  final HslColorAdjustment red;
  final HslColorAdjustment orange;
  final HslColorAdjustment yellow;
  final HslColorAdjustment green;
  final HslColorAdjustment aqua;
  final HslColorAdjustment blue;
  final HslColorAdjustment purple;
  final HslColorAdjustment magenta;

  const HslAdjustments({
    this.red = const HslColorAdjustment(),
    this.orange = const HslColorAdjustment(),
    this.yellow = const HslColorAdjustment(),
    this.green = const HslColorAdjustment(),
    this.aqua = const HslColorAdjustment(),
    this.blue = const HslColorAdjustment(),
    this.purple = const HslColorAdjustment(),
    this.magenta = const HslColorAdjustment(),
  });

  HslAdjustments copyWith({
    HslColorAdjustment? red,
    HslColorAdjustment? orange,
    HslColorAdjustment? yellow,
    HslColorAdjustment? green,
    HslColorAdjustment? aqua,
    HslColorAdjustment? blue,
    HslColorAdjustment? purple,
    HslColorAdjustment? magenta,
  }) {
    return HslAdjustments(
      red: red ?? this.red,
      orange: orange ?? this.orange,
      yellow: yellow ?? this.yellow,
      green: green ?? this.green,
      aqua: aqua ?? this.aqua,
      blue: blue ?? this.blue,
      purple: purple ?? this.purple,
      magenta: magenta ?? this.magenta,
    );
  }

  @override
  List<Object?> get props => [
        red,
        orange,
        yellow,
        green,
        aqua,
        blue,
        purple,
        magenta,
      ];
}
