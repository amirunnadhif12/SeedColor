import 'package:flutter/material.dart';

/// 🌱 SeedColor — Curve Control Point Style
///
/// Menyimpan konfigurasi visual dan deteksi gestur sentuh
/// untuk titik kontrol pada kurva editor.
class CurveControlPointStyle {
  CurveControlPointStyle._();

  /// Jarak toleransi deteksi sentuhan jari (hitbox radius) dalam piksel.
  /// Jika sentuhan berada di dalam radius ini dari suatu titik, titik tersebut terpilih.
  static const double touchRadius = 24.0;

  /// Radius lingkaran visual titik kontrol (dalam piksel).
  static const double pointRadius = 5.0;

  /// Radius lingkaran aktif (halo/glow) saat titik sedang digeser.
  static const double activeGlowRadius = 12.0;

  /// Mendapatkan warna representasi visual titik aktif sesuai saluran kurva.
  static Color getChannelColor(String channel) {
    switch (channel.toLowerCase()) {
      case 'red':
        return const Color(0xFFFF3B30); // iOS Red
      case 'green':
        return const Color(0xFF34C759); // iOS Green
      case 'blue':
        return const Color(0xFF007AFF); // iOS Blue
      case 'rgb':
      default:
        return Colors.white;
    }
  }
}
