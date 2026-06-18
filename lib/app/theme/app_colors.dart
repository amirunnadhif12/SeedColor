import 'package:flutter/material.dart';

/// 🌱 SeedColor Design System — Color Palette
///
/// Dark-mode-first color palette terinspirasi dari
/// professional photo editing apps.
/// Brand color: Biru (#0A84FF)
class AppColors {
  AppColors._();

  // ─── Brand Colors ───────────────────────────────────────
  /// Primary brand blue
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryLight = Color(0xFF409CFF);
  static const Color primaryDark = Color(0xFF0066CC);
  static const Color primarySurface = Color(0x1A0A84FF); // 10% opacity

  // ─── Background Colors ──────────────────────────────────
  /// Deepest background — main canvas
  static const Color backgroundDark = Color(0xFF0A0A0F);

  /// Slightly lighter — panels, cards, bottom nav
  static const Color backgroundPanel = Color(0xFF1C1C24);

  /// Surface — elevated elements, cards
  static const Color surface = Color(0xFF252530);

  /// Surface variant — hover states, borders
  static const Color surfaceVariant = Color(0xFF2E2E3A);

  /// Elevated surface — dialogs, dropdowns
  static const Color surfaceElevated = Color(0xFF38384A);

  // ─── Text Colors ────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color textDisabled = Color(0xFF484F58);

  // ─── Border Colors ──────────────────────────────────────
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF21262D);
  static const Color borderFocus = Color(0xFF0A84FF);

  // ─── Tool Accent Colors ─────────────────────────────────
  /// Setiap tool punya warna aksen sendiri agar mudah dikenali
  static const Color toolLight = Color(0xFFF5C542); // Kuning warm
  static const Color toolColor = Color(0xFF58A6FF); // Biru cerah
  static const Color toolHSL = Color(0xFFE040FB); // Magenta/rainbow
  static const Color toolEffects = Color(0xFF79C0FF); // Cyan
  static const Color toolDetail = Color(0xFFD29922); // Amber
  static const Color toolCurves = Color(0xFF7EE787); // Hijau muda
  static const Color toolColorGrading = Color(0xFFF78166); // Oranye coral
  static const Color toolGeometry = Color(0xFFBC8CFF); // Ungu
  static const Color toolMasking = Color(0xFF0A84FF); // Biru brand

  // ─── Slider Colors ──────────────────────────────────────
  static const Color sliderTrack = Color(0xFF30363D);
  static const Color sliderActive = Color(0xFFF0F6FC);
  static const Color sliderThumb = Color(0xFFF0F6FC);
  static const Color sliderLabel = Color(0xFF0A84FF);

  // ─── Status Colors ──────────────────────────────────────
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF5C542);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF58A6FF);

  // ─── HSL Color Mixer Colors ─────────────────────────────
  static const Color hslRed = Color(0xFFFF4444);
  static const Color hslOrange = Color(0xFFFF8C00);
  static const Color hslYellow = Color(0xFFFFD700);
  static const Color hslGreen = Color(0xFF00C853);
  static const Color hslAqua = Color(0xFF00E5FF);
  static const Color hslBlue = Color(0xFF2979FF);
  static const Color hslPurple = Color(0xFF9C27B0);
  static const Color hslMagenta = Color(0xFFFF4081);

  // ─── Bottom Navigation ──────────────────────────────────
  static const Color navBarBackground = Color(0xFF14141C);
  static const Color navBarSelected = Color(0xFF0A84FF);
  static const Color navBarUnselected = Color(0xFF6E7681);

  // ─── Gradient Presets ───────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundPanel],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient hslRainbow = LinearGradient(
    colors: [
      hslRed,
      hslOrange,
      hslYellow,
      hslGreen,
      hslAqua,
      hslBlue,
      hslPurple,
      hslMagenta,
      hslRed,
    ],
  );

  /// Temperature gradient (cool blue → warm orange)
  static const LinearGradient temperatureGradient = LinearGradient(
    colors: [
      Color(0xFF4A90D9), // Cool blue
      Color(0xFFF0F6FC), // Neutral white
      Color(0xFFFFAA33), // Warm orange
    ],
  );

  /// Tint gradient (green → magenta)
  static const LinearGradient tintGradient = LinearGradient(
    colors: [
      Color(0xFF00C853), // Green
      Color(0xFFF0F6FC), // Neutral
      Color(0xFFFF4081), // Magenta
    ],
  );
}
