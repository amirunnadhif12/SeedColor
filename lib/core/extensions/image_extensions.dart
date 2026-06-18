import 'dart:typed_data';
import 'dart:ui' as ui;

/// 🌱 SeedColor — Image Extension Methods
///
/// Extension methods pada [ui.Image] untuk convenience methods
/// yang sering digunakan di image processing pipeline.
extension SeedImageExtension on ui.Image {
  /// Dapatkan aspect ratio (width / height).
  ///
  /// ```dart
  /// image.aspectRatio // → 1.777... untuk 16:9
  /// ```
  double get aspectRatio => width / height;

  /// Apakah gambar ini landscape?
  bool get isLandscape => width > height;

  /// Apakah gambar ini portrait?
  bool get isPortrait => height > width;

  /// Apakah gambar ini square?
  bool get isSquare => width == height;

  /// Dapatkan string dimensi readable.
  ///
  /// ```dart
  /// image.dimensionString // → "1920 × 1080"
  /// ```
  String get dimensionString => '$width × $height';

  /// Hitung total pixel count.
  int get pixelCount => width * height;

  /// Hitung megapixel (dibulatkan 1 desimal).
  ///
  /// ```dart
  /// // 4000x3000 image
  /// image.megapixels // → "12,0 MP"
  /// ```
  String get megapixels {
    final mp = pixelCount / 1000000;
    return '${mp.toStringAsFixed(1).replaceAll('.', ',')} MP';
  }

  /// Konversi ke RGBA byte data.
  ///
  /// Returns: `Future<ByteData?>` dalam format RGBA.
  Future<ByteData?> toRgbaBytes() {
    return toByteData(format: ui.ImageByteFormat.rawRgba);
  }

  /// Konversi ke PNG byte data.
  ///
  /// Returns: `Future<ByteData?>` dalam format PNG.
  Future<ByteData?> toPngBytes() {
    return toByteData(format: ui.ImageByteFormat.png);
  }
}

/// Extension pada Size untuk image-related calculations.
extension SeedSizeExtension on ui.Size {
  /// Dapatkan aspect ratio.
  double get aspectRatio => width / height;

  /// Fit ukuran ini ke dalam [maxSize] mempertahankan aspect ratio.
  ui.Size fitInto(ui.Size maxSize) {
    if (width <= maxSize.width && height <= maxSize.height) {
      return this;
    }

    final scaleX = maxSize.width / width;
    final scaleY = maxSize.height / height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    return ui.Size(width * scale, height * scale);
  }

  /// Scale ukuran ini ke [factor].
  ui.Size scale(double factor) {
    return ui.Size(width * factor, height * factor);
  }
}
