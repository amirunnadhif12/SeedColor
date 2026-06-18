/// 🌱 SeedColor — Image Processing Constants
///
/// Konstanta terkait pemrosesan gambar: ukuran, format,
/// slider ranges, dan konfigurasi export.
class ImageConstants {
  ImageConstants._();

  // ─── Image Size Limits ────────────────────────────────
  /// Max dimensions untuk preview rendering (GPU friendly)
  static const int maxPreviewWidth = 4096;
  static const int maxPreviewHeight = 4096;

  /// Max dimensions untuk export full-res
  static const int maxExportWidth = 8192;
  static const int maxExportHeight = 8192;

  // ─── Thumbnail Sizes ──────────────────────────────────
  static const int thumbnailSmall = 150;
  static const int thumbnailMedium = 300;
  static const int thumbnailLarge = 600;

  // ─── Export Quality ───────────────────────────────────
  static const int jpegDefaultQuality = 95;
  static const int jpegMinQuality = 1;
  static const int jpegMaxQuality = 100;

  // ─── Supported Formats ────────────────────────────────
  static const List<String> supportedImageFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.heic',
    '.heif',
    '.webp',
  ];

  static const List<String> supportedRawFormats = [
    '.dng',
    '.cr2',
    '.cr3',
    '.nef',
    '.arw',
    '.orf',
    '.raf',
    '.rw2',
  ];

  static const List<String> supportedLutFormats = [
    '.cube',
    '.3dl',
  ];

  // ─── Slider Ranges ────────────────────────────────────
  // Light Panel
  static const double exposureMin = -5.0;
  static const double exposureMax = 5.0;
  static const double contrastMin = -100.0;
  static const double contrastMax = 100.0;
  static const double highlightsMin = -100.0;
  static const double highlightsMax = 100.0;
  static const double shadowsMin = -100.0;
  static const double shadowsMax = 100.0;
  static const double whitesMin = -100.0;
  static const double whitesMax = 100.0;
  static const double blacksMin = -100.0;
  static const double blacksMax = 100.0;

  // Color Panel
  static const double temperatureMin = -100.0;
  static const double temperatureMax = 100.0;
  static const double tintMin = -100.0;
  static const double tintMax = 100.0;
  static const double vibranceMin = -100.0;
  static const double vibranceMax = 100.0;
  static const double saturationMin = -100.0;
  static const double saturationMax = 100.0;

  // HSL Per-channel
  static const double hslHueMin = -100.0;
  static const double hslHueMax = 100.0;
  static const double hslSatMin = -100.0;
  static const double hslSatMax = 100.0;
  static const double hslLumMin = -100.0;
  static const double hslLumMax = 100.0;

  // Effects Panel
  static const double textureMin = -100.0;
  static const double textureMax = 100.0;
  static const double clarityMin = -100.0;
  static const double clarityMax = 100.0;
  static const double dehazeMin = -100.0;
  static const double dehazeMax = 100.0;
  static const double vignetteMin = -100.0;
  static const double vignetteMax = 100.0;
  static const double grainMin = 0.0;
  static const double grainMax = 100.0;

  // Detail Panel
  static const double sharpeningMin = 0.0;
  static const double sharpeningMax = 150.0;
  static const double sharpenRadiusMin = 0.5;
  static const double sharpenRadiusMax = 3.0;
  static const double sharpenDetailMin = 0.0;
  static const double sharpenDetailMax = 100.0;
  static const double sharpenMaskingMin = 0.0;
  static const double sharpenMaskingMax = 100.0;
  static const double noiseReductionMin = 0.0;
  static const double noiseReductionMax = 100.0;

  // Color Grading
  static const double cgBlendingMin = 0.0;
  static const double cgBlendingMax = 100.0;
  static const double cgBalanceMin = -100.0;
  static const double cgBalanceMax = 100.0;

  // Geometry
  static const double rotateMin = -45.0;
  static const double rotateMax = 45.0;
  static const double perspectiveMin = -100.0;
  static const double perspectiveMax = 100.0;

  // ─── Curves ───────────────────────────────────────────
  /// LUT size (entries) untuk curve interpolation
  static const int curveLutSize = 256;

  /// Max control points per channel
  static const int curveMaxPoints = 16;

  /// Min distance antara control points (normalized 0-1)
  static const double curveMinPointDistance = 0.02;

  // ─── Color Temperature ────────────────────────────────
  /// Color temperature range in Kelvin (daylight balance)
  static const double tempKelvinMin = 2000.0;
  static const double tempKelvinMax = 12000.0;
  static const double tempKelvinDaylight = 5500.0;
}
