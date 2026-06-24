import 'dart:ui';
import 'package:equatable/equatable.dart';

enum MaskType { brush, linear, radial, subject, sky }

/// 🌱 SeedColor — Brush Stroke
///
/// Menyimpan data garis sapuan kuas untuk masker kuas.
class BrushStroke extends Equatable {
  final List<Offset> points; // Koordinat titik sapuan ternormalisasi (0..1)
  final double radius;       // Radius sapuan kuas ternormalisasi
  final double opacity;      // Opasitas sapuan kuas (0..1)
  final double hardness;     // Kekerasan (hardness) brush (0..1)

  const BrushStroke({
    required this.points,
    required this.radius,
    this.opacity = 1.0,
    this.hardness = 0.5,
  });

  @override
  List<Object?> get props => [points, radius, opacity, hardness];
}

/// 🌱 SeedColor — Mask Model
///
/// Menyimpan tipe masker, visibilitas, data geometri, dan parameter penyesuaian lokal.
class MaskModel extends Equatable {
  final String id;
  final String name;
  final MaskType type;
  final bool isVisible;

  // Geometri Brush
  final List<BrushStroke> strokes;

  // Geometri Gradien Linier
  final Offset? linearStart; // Titik awal gradien ternormalisasi (0..1)
  final Offset? linearEnd;   // Titik akhir gradien ternormalisasi (0..1)

  // Geometri Gradien Radial
  final Offset? radialCenter;  // Titik pusat elips gradien ternormalisasi (0..1)
  final double radialRadiusX;  // Radius X ternormalisasi
  final double radialRadiusY;  // Radius Y ternormalisasi
  final double radialRotation; // Sudut rotasi dalam radian

  // Parameter Penyesuaian Lokal (Mask Adjustments)
  final double exposure;   // -5.0 s.d. 5.0
  final double contrast;   // -100.0 s.d. 100.0
  final double shadows;    // -100.0 s.d. 100.0
  final double saturation; // -100.0 s.d. 100.0
  final double temperature;// -100.0 s.d. 100.0
  final double tint;       // -100.0 s.d. 100.0

  const MaskModel({
    required this.id,
    required this.name,
    required this.type,
    this.isVisible = true,
    this.strokes = const [],
    this.linearStart,
    this.linearEnd,
    this.radialCenter,
    this.radialRadiusX = 0.15,
    this.radialRadiusY = 0.15,
    this.radialRotation = 0.0,
    this.exposure = 0.0,
    this.contrast = 0.0,
    this.shadows = 0.0,
    this.saturation = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
  });

  MaskModel copyWith({
    String? name,
    bool? isVisible,
    List<BrushStroke>? strokes,
    Offset? linearStart,
    Offset? linearEnd,
    Offset? radialCenter,
    double? radialRadiusX,
    double? radialRadiusY,
    double? radialRotation,
    double? exposure,
    double? contrast,
    double? shadows,
    double? saturation,
    double? temperature,
    double? tint,
  }) {
    return MaskModel(
      id: id,
      name: name ?? this.name,
      type: type,
      isVisible: isVisible ?? this.isVisible,
      strokes: strokes ?? this.strokes,
      linearStart: linearStart ?? this.linearStart,
      linearEnd: linearEnd ?? this.linearEnd,
      radialCenter: radialCenter ?? this.radialCenter,
      radialRadiusX: radialRadiusX ?? this.radialRadiusX,
      radialRadiusY: radialRadiusY ?? this.radialRadiusY,
      radialRotation: radialRotation ?? this.radialRotation,
      exposure: exposure ?? this.exposure,
      contrast: contrast ?? this.contrast,
      shadows: shadows ?? this.shadows,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isVisible,
        strokes,
        linearStart,
        linearEnd,
        radialCenter,
        radialRadiusX,
        radialRadiusY,
        radialRotation,
        exposure,
        contrast,
        shadows,
        saturation,
        temperature,
        tint,
      ];
}
