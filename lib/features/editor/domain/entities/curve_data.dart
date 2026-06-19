import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import '../../../../core/constants/image_constants.dart';

/// 🌱 SeedColor — Curve Data
///
/// Menyimpan daftar titik kontrol untuk masing-masing saluran kurva:
/// RGB (Gabungan), Red, Green, dan Blue.
class CurveData extends Equatable {
  final List<math.Point<double>> rgb;
  final List<math.Point<double>> red;
  final List<math.Point<double>> green;
  final List<math.Point<double>> blue;

  const CurveData({
    required this.rgb,
    required this.red,
    required this.green,
    required this.blue,
  });

  /// Inisialisasi awal berupa diagonal linier
  /// (y = x, hitam tetap hitam, putih tetap putih).
  factory CurveData.identity() {
    return const CurveData(
      rgb: [math.Point(0.0, 0.0), math.Point(1.0, 1.0)],
      red: [math.Point(0.0, 0.0), math.Point(1.0, 1.0)],
      green: [math.Point(0.0, 0.0), math.Point(1.0, 1.0)],
      blue: [math.Point(0.0, 0.0), math.Point(1.0, 1.0)],
    );
  }

  /// Mendapatkan list titik kontrol untuk saluran tertentu.
  List<math.Point<double>> getChannelPoints(String channel) {
    switch (channel.toLowerCase()) {
      case 'red':
        return red;
      case 'green':
        return green;
      case 'blue':
        return blue;
      case 'rgb':
      default:
        return rgb;
    }
  }

  /// Membuat instance baru dengan mengganti saluran tertentu.
  CurveData _copyWithChannel(String channel, List<math.Point<double>> newPoints) {
    return CurveData(
      rgb: channel.toLowerCase() == 'rgb' ? newPoints : rgb,
      red: channel.toLowerCase() == 'red' ? newPoints : red,
      green: channel.toLowerCase() == 'green' ? newPoints : green,
      blue: channel.toLowerCase() == 'blue' ? newPoints : blue,
    );
  }

  /// Menambahkan titik kontrol baru secara aman.
  CurveData addPoint(String channel, math.Point<double> point) {
    final points = List<math.Point<double>>.from(getChannelPoints(channel));
    if (points.length >= ImageConstants.curveMaxPoints) return this;

    // Clamp nilai koordinat
    final clampedX = point.x.clamp(0.0, 1.0);
    final clampedY = point.y.clamp(0.0, 1.0);

    // Cari apakah terlalu dekat dengan titik yang sudah ada
    for (final p in points) {
      if ((p.x - clampedX).abs() < ImageConstants.curveMinPointDistance) {
        return this; // Batalkan jika terlalu dekat secara horizontal
      }
    }

    final newPoint = math.Point(clampedX, clampedY);
    points.add(newPoint);
    points.sort((a, b) => a.x.compareTo(b.x));

    return _copyWithChannel(channel, points);
  }

  /// Memperbarui titik kontrol yang ada secara aman.
  CurveData updatePoint(String channel, int index, math.Point<double> newPoint) {
    final points = List<math.Point<double>>.from(getChannelPoints(channel));
    if (index < 0 || index >= points.length) return this;

    final clampedY = newPoint.y.clamp(0.0, 1.0);
    double clampedX = newPoint.x.clamp(0.0, 1.0);

    // Aturan untuk ujung kurva
    if (index == 0) {
      clampedX = 0.0; // Ujung kiri harus tetap di X = 0.0
    } else if (index == points.length - 1) {
      clampedX = 1.0; // Ujung kanan harus tetap di X = 1.0
    } else {
      // Batasi X di antara tetangga kiri dan kanannya
      final leftLimit = points[index - 1].x + ImageConstants.curveMinPointDistance;
      final rightLimit = points[index + 1].x - ImageConstants.curveMinPointDistance;
      
      if (leftLimit > rightLimit) return this; // Ruang tidak cukup
      clampedX = clampedX.clamp(leftLimit, rightLimit);
    }

    points[index] = math.Point(clampedX, clampedY);
    return _copyWithChannel(channel, points);
  }

  /// Menghapus titik kontrol (tidak diizinkan menghapus ujung kurva).
  CurveData removePoint(String channel, int index) {
    final points = List<math.Point<double>>.from(getChannelPoints(channel));
    if (index <= 0 || index >= points.length - 1) return this; // Endpoints tidak boleh dihapus

    points.removeAt(index);
    return _copyWithChannel(channel, points);
  }

  @override
  List<Object?> get props => [rgb, red, green, blue];
}
