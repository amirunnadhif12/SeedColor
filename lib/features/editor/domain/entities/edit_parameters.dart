import 'package:equatable/equatable.dart';
import 'curve_data.dart';
import 'hsl_adjustments.dart';
import 'mask_model.dart';

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

  // ─── Detail Panel ────────────────────────────────────
  final double sharpeningAmount;
  final double sharpeningRadius;
  final double sharpeningDetail;
  final double sharpeningMasking;
  final double luminanceNR;
  final double colorNR;

  // ─── Optics Panel ────────────────────────────────────
  final bool removeChromaticAberration;
  final bool enableLensCorrection;

  // ─── Geometry Panel ──────────────────────────────────
  final double cropLeft;
  final double cropTop;
  final double cropRight;
  final double cropBottom;
  final double rotation; // dalam derajat (-45.0 s.d. +45.0)
  final double perspectiveHorizontal;
  final double perspectiveVertical;
  final bool flipHorizontal;
  final bool flipVertical;
  final String aspectRatio; // 'Bebas', '1:1', '4:3', '16:9', '3:2'

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

  // ─── 3D LUT Support ──────────────────────────────────
  final String? lutPath;
  final double lutIntensity; // 0.0 s.d. 1.0
  final double lutSize;      // misal 33.0, atau 0.0 jika dinonaktifkan

  // ─── Masking Panel ───────────────────────────────────
  final List<MaskModel> masks;
  final String? activeMaskId;

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
    this.sharpeningAmount = 0.0,
    this.sharpeningRadius = 0.0,
    this.sharpeningDetail = 0.0,
    this.sharpeningMasking = 0.0,
    this.luminanceNR = 0.0,
    this.colorNR = 0.0,
    this.removeChromaticAberration = false,
    this.enableLensCorrection = false,
    this.cropLeft = 0.0,
    this.cropTop = 0.0,
    this.cropRight = 1.0,
    this.cropBottom = 1.0,
    this.rotation = 0.0,
    this.perspectiveHorizontal = 0.0,
    this.perspectiveVertical = 0.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.aspectRatio = 'Bebas',
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
    this.lutPath,
    this.lutIntensity = 1.0,
    this.lutSize = 0.0,
    this.masks = const [],
    this.activeMaskId,
  });

  /// factory untuk inisialisasi default / identitas filter kosong
  factory EditParameters.identity() {
    return EditParameters(
      curveData: CurveData.identity(),
      hslAdjustments: const HslAdjustments(),
      lutPath: null,
      lutIntensity: 1.0,
      lutSize: 0.0,
      masks: const [],
      activeMaskId: null,
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
    double? sharpeningAmount,
    double? sharpeningRadius,
    double? sharpeningDetail,
    double? sharpeningMasking,
    double? luminanceNR,
    double? colorNR,
    bool? removeChromaticAberration,
    bool? enableLensCorrection,
    double? cropLeft,
    double? cropTop,
    double? cropRight,
    double? cropBottom,
    double? rotation,
    double? perspectiveHorizontal,
    double? perspectiveVertical,
    bool? flipHorizontal,
    bool? flipVertical,
    String? aspectRatio,
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
    String? lutPath,
    double? lutIntensity,
    double? lutSize,
    List<MaskModel>? masks,
    String? activeMaskId,
    bool clearActiveMask = false,
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
      sharpeningAmount: sharpeningAmount ?? this.sharpeningAmount,
      sharpeningRadius: sharpeningRadius ?? this.sharpeningRadius,
      sharpeningDetail: sharpeningDetail ?? this.sharpeningDetail,
      sharpeningMasking: sharpeningMasking ?? this.sharpeningMasking,
      luminanceNR: luminanceNR ?? this.luminanceNR,
      colorNR: colorNR ?? this.colorNR,
      removeChromaticAberration: removeChromaticAberration ?? this.removeChromaticAberration,
      enableLensCorrection: enableLensCorrection ?? this.enableLensCorrection,
      cropLeft: cropLeft ?? this.cropLeft,
      cropTop: cropTop ?? this.cropTop,
      cropRight: cropRight ?? this.cropRight,
      cropBottom: cropBottom ?? this.cropBottom,
      rotation: rotation ?? this.rotation,
      perspectiveHorizontal: perspectiveHorizontal ?? this.perspectiveHorizontal,
      perspectiveVertical: perspectiveVertical ?? this.perspectiveVertical,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      aspectRatio: aspectRatio ?? this.aspectRatio,
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
      lutPath: lutPath ?? this.lutPath,
      lutIntensity: lutIntensity ?? this.lutIntensity,
      lutSize: lutSize ?? this.lutSize,
      masks: masks ?? this.masks,
      activeMaskId: clearActiveMask ? null : (activeMaskId ?? this.activeMaskId),
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
        sharpeningAmount,
        sharpeningRadius,
        sharpeningDetail,
        sharpeningMasking,
        luminanceNR,
        colorNR,
        removeChromaticAberration,
        enableLensCorrection,
        cropLeft,
        cropTop,
        cropRight,
        cropBottom,
        rotation,
        perspectiveHorizontal,
        perspectiveVertical,
        flipHorizontal,
        flipVertical,
        aspectRatio,
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
        lutPath,
        lutIntensity,
        lutSize,
        masks,
        activeMaskId,
      ];
}
