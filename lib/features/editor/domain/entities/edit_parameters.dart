import 'package:equatable/equatable.dart';
import 'curve_data.dart';
import 'hsl_adjustments.dart';

/// 🌱 SeedColor — Edit Parameters
///
/// Menyimpan seluruh nilai parameter pengeditan (Light, Color, Effects,
/// Curves, HSL Mixer, dan Color Grading). Objek ini bersifat immutable
/// dan digunakan oleh BLoC serta use cases.
class EditParameters extends Equatable {
  // ─── Light Panel ─────────────────────────────────────
  final double exposure;
  final double contrast;
  final double highlights;
  final double shadows;
  final double whites;
  final double blacks;

  // ─── Color Panel ─────────────────────────────────────
  final double temperature;
  final double tint;
  final double vibrance;
  final double saturation;

  // ─── Effects Panel ───────────────────────────────────
  final double texture;
  final double clarity;
  final double dehaze;
  final double vignette;
  final double grain;

  // ─── Color Grading ───────────────────────────────────
  // Shadows (Hue: 0-360, Saturation: 0-100)
  final double shadowsHue;
  final double shadowsSat;
  // Midtones (Hue: 0-360, Saturation: 0-100)
  final double midtonesHue;
  final double midtonesSat;
  // Highlights (Hue: 0-360, Saturation: 0-100)
  final double highlightsHue;
  final double highlightsSat;
  // Blending & Balance
  final double cgBlending; // 0 s.d. 100
  final double cgBalance;  // -100 s.d. 100

  // ─── Curves & HSL Sub-structures ─────────────────────
  final CurveData curveData;
  final HslAdjustments hslAdjustments;

  const EditParameters({
    this.exposure = 0.0,
    this.contrast = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.whites = 0.0,
    this.blacks = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
    this.vibrance = 0.0,
    this.saturation = 0.0,
    this.texture = 0.0,
    this.clarity = 0.0,
    this.dehaze = 0.0,
    this.vignette = 0.0,
    this.grain = 0.0,
    this.shadowsHue = 0.0,
    this.shadowsSat = 0.0,
    this.midtonesHue = 0.0,
    this.midtonesSat = 0.0,
    this.highlightsHue = 0.0,
    this.highlightsSat = 0.0,
    this.cgBlending = 50.0,
    this.cgBalance = 0.0,
    this.curveData = const CurveData(rgb: [], red: [], green: [], blue: []),
    this.hslAdjustments = const HslAdjustments(),
  });

  /// factory untuk inisialisasi default / identitas filter kosong
  factory EditParameters.identity() {
    return EditParameters(
      curveData: CurveData.identity(),
      hslAdjustments: const HslAdjustments(),
    );
  }

  EditParameters copyWith({
    double? exposure,
    double? contrast,
    double? highlights,
    double? shadows,
    double? whites,
    double? blacks,
    double? temperature,
    double? tint,
    double? vibrance,
    double? saturation,
    double? texture,
    double? clarity,
    double? dehaze,
    double? vignette,
    double? grain,
    double? shadowsHue,
    double? shadowsSat,
    double? midtonesHue,
    double? midtonesSat,
    double? highlightsHue,
    double? highlightsSat,
    double? cgBlending,
    double? cgBalance,
    CurveData? curveData,
    HslAdjustments? hslAdjustments,
  }) {
    return EditParameters(
      exposure: exposure ?? this.exposure,
      contrast: contrast ?? this.contrast,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      whites: whites ?? this.whites,
      blacks: blacks ?? this.blacks,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      vibrance: vibrance ?? this.vibrance,
      saturation: saturation ?? this.saturation,
      texture: texture ?? this.texture,
      clarity: clarity ?? this.clarity,
      dehaze: dehaze ?? this.dehaze,
      vignette: vignette ?? this.vignette,
      grain: grain ?? this.grain,
      shadowsHue: shadowsHue ?? this.shadowsHue,
      shadowsSat: shadowsSat ?? this.shadowsSat,
      midtonesHue: midtonesHue ?? this.midtonesHue,
      midtonesSat: midtonesSat ?? this.midtonesSat,
      highlightsHue: highlightsHue ?? this.highlightsHue,
      highlightsSat: highlightsSat ?? this.highlightsSat,
      cgBlending: cgBlending ?? this.cgBlending,
      cgBalance: cgBalance ?? this.cgBalance,
      curveData: curveData ?? this.curveData,
      hslAdjustments: hslAdjustments ?? this.hslAdjustments,
    );
  }

  @override
  List<Object?> get props => [
        exposure,
        contrast,
        highlights,
        shadows,
        whites,
        blacks,
        temperature,
        tint,
        vibrance,
        saturation,
        texture,
        clarity,
        dehaze,
        vignette,
        grain,
        shadowsHue,
        shadowsSat,
        midtonesHue,
        midtonesSat,
        highlightsHue,
        highlightsSat,
        cgBlending,
        cgBalance,
        curveData,
        hslAdjustments,
      ];
}
