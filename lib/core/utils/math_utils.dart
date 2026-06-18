import 'dart:math' as math;

/// 🌱 SeedColor — Math Utilities
///
/// Fungsi matematika untuk image processing.
/// Terutama digunakan oleh Curves editor dan shader pipeline.
class MathUtils {
  MathUtils._();

  // ─── Linear Interpolation ──────────────────────────────

  /// Linear interpolation antara [a] dan [b] dengan faktor [t] (0.0 - 1.0).
  ///
  /// ```dart
  /// MathUtils.lerp(0, 100, 0.5) // → 50.0
  /// MathUtils.lerp(0, 100, 0.25) // → 25.0
  /// ```
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Inverse linear interpolation — menghitung t dari value.
  ///
  /// ```dart
  /// MathUtils.inverseLerp(0, 100, 50) // → 0.5
  /// ```
  static double inverseLerp(double a, double b, double value) {
    if ((b - a).abs() < 1e-10) return 0.0;
    return (value - a) / (b - a);
  }

  /// Remap value dari satu range ke range lain.
  ///
  /// ```dart
  /// MathUtils.remap(50, 0, 100, -1, 1) // → 0.0
  /// MathUtils.remap(75, 0, 100, 0, 255) // → 191.25
  /// ```
  static double remap(
    double value,
    double fromMin,
    double fromMax,
    double toMin,
    double toMax,
  ) {
    final t = inverseLerp(fromMin, fromMax, value);
    return lerp(toMin, toMax, t);
  }

  // ─── Clamp Helpers ─────────────────────────────────────

  /// Clamp value antara 0.0 dan 1.0.
  static double clamp01(double value) {
    return value.clamp(0.0, 1.0);
  }

  /// Clamp value antara [min] dan [max].
  static double clampRange(double value, double min, double max) {
    return value.clamp(min, max);
  }

  // ─── Catmull-Rom Spline ────────────────────────────────

  /// Catmull-Rom spline interpolation.
  ///
  /// Menghasilkan smooth curve dari control points.
  /// Digunakan untuk generate LUT 256-entry dari curve control points.
  ///
  /// [points] harus sorted by x ascending, dengan minimal 2 points.
  /// Returns: List of doubles with [lutSize] entries (default 256),
  /// di mana index i = output value untuk input i/255.
  ///
  /// Contoh:
  /// ```dart
  /// final points = [
  ///   Offset(0, 0),       // black stays black
  ///   Offset(0.25, 0.15), // darken shadows
  ///   Offset(0.75, 0.85), // brighten highlights
  ///   Offset(1, 1),       // white stays white
  /// ];
  /// final lut = MathUtils.catmullRomSplineLut(points);
  /// // lut[0] ≈ 0.0, lut[128] ≈ 0.5, lut[255] ≈ 1.0
  /// ```
  static List<double> catmullRomSplineLut(
    List<math.Point<double>> points, {
    int lutSize = 256,
    double tension = 0.0,
  }) {
    assert(points.length >= 2, 'Minimal 2 control points diperlukan');

    // Sort by x
    final sorted = List<math.Point<double>>.from(points)
      ..sort((a, b) => a.x.compareTo(b.x));

    // Ensure endpoints at 0 and 1
    if (sorted.first.x > 0) {
      sorted.insert(0, math.Point(0.0, sorted.first.y));
    }
    if (sorted.last.x < 1) {
      sorted.add(math.Point(1.0, sorted.last.y));
    }

    final lut = List<double>.filled(lutSize, 0.0);

    for (int i = 0; i < lutSize; i++) {
      final x = i / (lutSize - 1);

      // Find segment
      int segIdx = 0;
      for (int j = 0; j < sorted.length - 1; j++) {
        if (x >= sorted[j].x && x <= sorted[j + 1].x) {
          segIdx = j;
          break;
        }
      }

      // Get 4 points for Catmull-Rom (p0, p1, p2, p3)
      final p0 = sorted[math.max(0, segIdx - 1)];
      final p1 = sorted[segIdx];
      final p2 = sorted[math.min(sorted.length - 1, segIdx + 1)];
      final p3 = sorted[math.min(sorted.length - 1, segIdx + 2)];

      // Calculate t (local parameter within segment)
      double t;
      if ((p2.x - p1.x).abs() < 1e-10) {
        t = 0.0;
      } else {
        t = (x - p1.x) / (p2.x - p1.x);
      }

      // Catmull-Rom interpolation with tension
      final y = _catmullRom(t, p0.y, p1.y, p2.y, p3.y, tension);
      lut[i] = clamp01(y);
    }

    return lut;
  }

  /// Internal Catmull-Rom interpolation per component.
  static double _catmullRom(
    double t,
    double p0,
    double p1,
    double p2,
    double p3,
    double tension,
  ) {
    final s = (1.0 - tension) / 2.0;
    final t2 = t * t;
    final t3 = t2 * t;

    return (2 * p1) +
        (-p0 + p2) * s * t +
        (2 * p0 - 5 * p1 + 4 * p2 - p3) * s * t2 +
        (-p0 + 3 * p1 - 3 * p2 + p3) * s * t3;
  }

  // ─── Cubic Bezier ──────────────────────────────────────

  /// Evaluasi cubic Bezier curve di parameter [t] (0.0 - 1.0).
  ///
  /// [p0] = start point value
  /// [p1] = first control point value
  /// [p2] = second control point value
  /// [p3] = end point value
  static double cubicBezier(
    double t,
    double p0,
    double p1,
    double p2,
    double p3,
  ) {
    final mt = 1.0 - t;
    final mt2 = mt * mt;
    final mt3 = mt2 * mt;
    final t2 = t * t;
    final t3 = t2 * t;

    return mt3 * p0 + 3 * mt2 * t * p1 + 3 * mt * t2 * p2 + t3 * p3;
  }

  /// Evaluasi cubic Bezier 2D (x, y) di parameter [t].
  static math.Point<double> cubicBezier2D(
    double t,
    math.Point<double> p0,
    math.Point<double> p1,
    math.Point<double> p2,
    math.Point<double> p3,
  ) {
    return math.Point(
      cubicBezier(t, p0.x, p1.x, p2.x, p3.x),
      cubicBezier(t, p0.y, p1.y, p2.y, p3.y),
    );
  }

  // ─── Gaussian Function ─────────────────────────────────

  /// Fungsi Gaussian (normal distribution).
  /// Digunakan untuk weight distribution di blur/sharpening kernel.
  ///
  /// [x] = jarak dari center
  /// [sigma] = standard deviation (lebar distribusi)
  static double gaussian(double x, double sigma) {
    return math.exp(-(x * x) / (2 * sigma * sigma)) /
        (sigma * math.sqrt(2 * math.pi));
  }

  /// Generate 1D Gaussian kernel dengan [radius] tertentu.
  ///
  /// Returns: List normalized weights (sum ≈ 1.0)
  static List<double> gaussianKernel(int radius, double sigma) {
    final size = 2 * radius + 1;
    final kernel = List<double>.filled(size, 0.0);
    double sum = 0.0;

    for (int i = 0; i < size; i++) {
      kernel[i] = gaussian((i - radius).toDouble(), sigma);
      sum += kernel[i];
    }

    // Normalize
    for (int i = 0; i < size; i++) {
      kernel[i] /= sum;
    }

    return kernel;
  }

  // ─── Smoothstep ────────────────────────────────────────

  /// GLSL-compatible smoothstep function.
  /// Returns smooth Hermite interpolation antara 0 dan 1
  /// ketika value antara [edge0] dan [edge1].
  static double smoothstep(double edge0, double edge1, double value) {
    final t = clamp01((value - edge0) / (edge1 - edge0));
    return t * t * (3.0 - 2.0 * t);
  }

  // ─── Angle Helpers ─────────────────────────────────────

  /// Konversi derajat ke radian.
  static double degToRad(double degrees) => degrees * math.pi / 180.0;

  /// Konversi radian ke derajat.
  static double radToDeg(double radians) => radians * 180.0 / math.pi;
}
