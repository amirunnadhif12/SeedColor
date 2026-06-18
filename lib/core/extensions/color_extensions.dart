import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🌱 SeedColor — Color Extension Methods
///
/// Extension methods untuk konversi warna dan utilitas
/// yang dibutuhkan oleh color processing pipeline.

/// Extension pada [Color] untuk operasi warna umum.
extension SeedColorExtension on Color {
  // ─── HSL Konversi ───────────────────────────────────────

  /// Konversi Color ke HSL record.
  ///
  /// Returns: `(h: 0-360, s: 0-1, l: 0-1)`
  ///
  /// ```dart
  /// Colors.red.toHSL // → (h: 0.0, s: 1.0, l: 0.5)
  /// ```
  ({double h, double s, double l}) get toHSL {
    final r = this.r;
    final g = this.g;
    final b = this.b;

    final cMax = math.max(r, math.max(g, b));
    final cMin = math.min(r, math.min(g, b));
    final delta = cMax - cMin;

    // Lightness
    final l = (cMax + cMin) / 2;

    // Saturation
    double s;
    if (delta == 0) {
      s = 0;
    } else {
      s = delta / (1 - (2 * l - 1).abs());
    }

    // Hue
    double h;
    if (delta == 0) {
      h = 0;
    } else if (cMax == r) {
      h = 60 * (((g - b) / delta) % 6);
    } else if (cMax == g) {
      h = 60 * (((b - r) / delta) + 2);
    } else {
      h = 60 * (((r - g) / delta) + 4);
    }

    if (h < 0) h += 360;

    return (h: h, s: s.clamp(0.0, 1.0), l: l.clamp(0.0, 1.0));
  }

  // ─── Color Mixing ──────────────────────────────────────

  /// Mix dua warna dengan [amount] (0.0 = this, 1.0 = other).
  ///
  /// ```dart
  /// Colors.red.mix(Colors.blue, 0.5) // → purple-ish
  /// ```
  Color mix(Color other, double amount) {
    final t = amount.clamp(0.0, 1.0);
    return Color.fromARGB(
      _lerpInt(a.toInt(), other.a.toInt(), t),
      _lerpInt(r.toInt(), other.r.toInt(), t),
      _lerpInt(g.toInt(), other.g.toInt(), t),
      _lerpInt(b.toInt(), other.b.toInt(), t),
    );
  }

  static int _lerpInt(int a, int b, double t) {
    return (a + (b - a) * t).round().clamp(0, 255);
  }

  // ─── Perceived Brightness ──────────────────────────────

  /// Perceived brightness berdasarkan ITU-R BT.709.
  ///
  /// Returns: 0.0 (hitam) → 1.0 (putih)
  /// Lebih akurat dari [computeLuminance] untuk persepsi manusia.
  double get perceivedBrightness {
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Apakah warna ini dianggap "gelap"?
  bool get isDark => perceivedBrightness < 0.5;

  /// Apakah warna ini dianggap "terang"?
  bool get isLight => perceivedBrightness >= 0.5;

  // ─── Hex Helpers ───────────────────────────────────────

  /// Konversi ke hex string tanpa alpha.
  ///
  /// ```dart
  /// Colors.red.toHex // → "#FF0000"
  /// ```
  String get toHex {
    return '#${(toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Konversi ke hex string dengan alpha.
  ///
  /// ```dart
  /// Colors.red.withOpacity(0.5).toHexWithAlpha // → "#80FF0000"
  /// ```
  String get toHexWithAlpha {
    return '#${toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  // ─── Adjustment Helpers ────────────────────────────────

  /// Adjust brightness: positif = terangkan, negatif = gelapkan.
  /// [amount] range: -1.0 → +1.0
  Color adjustBrightness(double amount) {
    final hsl = HSLColor.fromColor(this);
    final newL = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(newL).toColor();
  }

  /// Adjust saturation: positif = lebih saturated, negatif = desaturate.
  /// [amount] range: -1.0 → +1.0
  Color adjustSaturation(double amount) {
    final hsl = HSLColor.fromColor(this);
    final newS = (hsl.saturation + amount).clamp(0.0, 1.0);
    return hsl.withSaturation(newS).toColor();
  }
}

// ─── Color Temperature Functions ───────────────────────────

/// Helper class untuk konversi color temperature ke RGB.
///
/// Berdasarkan algoritma Tanner Helland — konversi suhu warna
/// (Kelvin) ke nilai RGB. Digunakan untuk Temperature slider
/// dan visual indicator.
class ColorTemperature {
  ColorTemperature._();

  /// Konversi suhu warna (Kelvin) ke [Color].
  ///
  /// [kelvin] range: 1000K (sangat warm) → 40000K (sangat cool)
  /// Daylight: ~5500K-6500K
  ///
  /// ```dart
  /// ColorTemperature.toColor(3000)  // → warm orange
  /// ColorTemperature.toColor(5500)  // → neutral white
  /// ColorTemperature.toColor(9000)  // → cool blue
  /// ```
  static Color toColor(double kelvin) {
    final temp = kelvin / 100.0;

    double r, g, b;

    // Red
    if (temp <= 66) {
      r = 255;
    } else {
      r = 329.698727446 * math.pow(temp - 60, -0.1332047592);
    }

    // Green
    if (temp <= 66) {
      g = 99.4708025861 * math.log(temp) - 161.1195681661;
    } else {
      g = 288.1221695283 * math.pow(temp - 60, -0.0755148492);
    }

    // Blue
    if (temp >= 66) {
      b = 255;
    } else if (temp <= 19) {
      b = 0;
    } else {
      b = 138.5177312231 * math.log(temp - 10) - 305.0447927307;
    }

    return Color.fromARGB(
      255,
      r.round().clamp(0, 255),
      g.round().clamp(0, 255),
      b.round().clamp(0, 255),
    );
  }

  /// Konversi slider value (-100..+100) ke approx Kelvin.
  ///
  /// -100 → ~2000K (warm), 0 → ~5500K (daylight), +100 → ~12000K (cool)
  static double sliderToKelvin(double sliderValue) {
    // Non-linear mapping: lebih sensitif di area warm
    final normalized = sliderValue / 100.0; // -1 → +1
    if (normalized >= 0) {
      return 5500 + normalized * 6500; // 5500K → 12000K
    } else {
      return 5500 + normalized * 3500; // 2000K → 5500K
    }
  }
}

/// Extension pada [HSLColor] untuk convenience.
extension SeedHSLColorExtension on HSLColor {
  /// Shift hue by [degrees], wrapping around 360°.
  HSLColor shiftHue(double degrees) {
    return withHue((hue + degrees) % 360);
  }

  /// Multiply saturation by [factor] (clamped 0-1).
  HSLColor scaleSaturation(double factor) {
    return withSaturation((saturation * factor).clamp(0.0, 1.0));
  }

  /// Multiply lightness by [factor] (clamped 0-1).
  HSLColor scaleLightness(double factor) {
    return withLightness((lightness * factor).clamp(0.0, 1.0));
  }
}

/// Parse hex string ke [Color].
///
/// Mendukung format: "#RGB", "#RRGGBB", "#AARRGGBB"
///
/// ```dart
/// colorFromHex("#FF0000") // → Colors.red
/// colorFromHex("#80FF0000") // → Colors.red.withOpacity(0.5)
/// ```
Color colorFromHex(String hex) {
  String cleaned = hex.replaceAll('#', '').replaceAll('0x', '');

  if (cleaned.length == 3) {
    // #RGB → #RRGGBB
    cleaned = cleaned.split('').map((c) => '$c$c').join();
  }

  if (cleaned.length == 6) {
    cleaned = 'FF$cleaned'; // Add full opacity
  }

  return Color(int.parse(cleaned, radix: 16));
}
