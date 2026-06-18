import 'dart:io';
import 'package:path/path.dart' as p;

import '../constants/image_constants.dart';

/// 🌱 SeedColor — Image Utilities
///
/// Helper functions untuk operasi gambar:
/// format detection, file size formatting, dll.
class ImageUtils {
  ImageUtils._();

  // ─── Format Detection ──────────────────────────────────

  /// Deteksi apakah file adalah gambar yang didukung berdasarkan extension.
  static bool isSupportedImage(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return ImageConstants.supportedImageFormats.contains(ext);
  }

  /// Deteksi apakah file adalah RAW format.
  static bool isRawFormat(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return ImageConstants.supportedRawFormats.contains(ext);
  }

  /// Deteksi apakah file adalah LUT format.
  static bool isLutFormat(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return ImageConstants.supportedLutFormats.contains(ext);
  }

  /// Dapatkan tipe format gambar dari path file.
  static ImageFormat getImageFormat(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return ImageFormat.jpeg;
      case '.png':
        return ImageFormat.png;
      case '.heic':
      case '.heif':
        return ImageFormat.heic;
      case '.webp':
        return ImageFormat.webp;
      case '.dng':
        return ImageFormat.dng;
      case '.cr2':
      case '.cr3':
        return ImageFormat.cr;
      case '.nef':
        return ImageFormat.nef;
      case '.arw':
        return ImageFormat.arw;
      default:
        return ImageFormat.unknown;
    }
  }

  // ─── File Size Formatting ──────────────────────────────

  /// Format ukuran file ke string readable.
  ///
  /// ```dart
  /// ImageUtils.formatFileSize(1024) // → "1,0 KB"
  /// ImageUtils.formatFileSize(1500000) // → "1,4 MB"
  /// ```
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1).replaceAll('.', ',')} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} GB';
    }
  }

  // ─── Dimension Helpers ─────────────────────────────────

  /// Hitung dimensi resize mempertahankan aspect ratio.
  ///
  /// [maxWidth] dan [maxHeight] adalah batas maksimal.
  /// Returns: `(width, height)` yang fit dalam batas.
  static (int, int) fitDimensions(
    int sourceWidth,
    int sourceHeight, {
    required int maxWidth,
    required int maxHeight,
  }) {
    if (sourceWidth <= maxWidth && sourceHeight <= maxHeight) {
      return (sourceWidth, sourceHeight);
    }

    final aspectRatio = sourceWidth / sourceHeight;

    int targetWidth = maxWidth;
    int targetHeight = (maxWidth / aspectRatio).round();

    if (targetHeight > maxHeight) {
      targetHeight = maxHeight;
      targetWidth = (maxHeight * aspectRatio).round();
    }

    return (targetWidth, targetHeight);
  }

  /// Hitung aspect ratio string dari width dan height.
  ///
  /// ```dart
  /// ImageUtils.aspectRatioString(1920, 1080) // → "16:9"
  /// ImageUtils.aspectRatioString(1000, 1000) // → "1:1"
  /// ```
  static String aspectRatioString(int width, int height) {
    final gcd = _gcd(width, height);
    final w = width ~/ gcd;
    final h = height ~/ gcd;

    // Simplify common ratios
    if (w == h) return '1:1';
    if (w == 16 && h == 9) return '16:9';
    if (w == 4 && h == 3) return '4:3';
    if (w == 3 && h == 2) return '3:2';

    return '$w:$h';
  }

  /// Hitung GCD (greatest common divisor).
  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  // ─── File Helpers ──────────────────────────────────────

  /// Dapatkan ukuran file dalam bytes.
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Generate nama file unik dengan timestamp.
  ///
  /// ```dart
  /// ImageUtils.generateExportFilename('jpeg')
  /// // → "SeedColor_20260618_143052.jpeg"
  /// ```
  static String generateExportFilename(String extension) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
    return 'SeedColor_$timestamp.$extension';
  }
}

/// Enum format gambar yang didukung
enum ImageFormat {
  jpeg,
  png,
  heic,
  webp,
  dng,
  cr,
  nef,
  arw,
  unknown,
}
