/// 🌱 SeedColor — Global App Constants
///
/// Konstanta yang digunakan di seluruh aplikasi.
/// Jangan hardcode angka-angka ini di widget — gunakan dari sini.
class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────
  static const String appName = 'SeedColor';
  static const String appVersion = '1.0.0';
  static const String developer = 'DevSeed Studio';

  // ─── Animation Durations ──────────────────────────────
  /// Untuk micro-interactions (hover, tap feedback)
  static const Duration animFast = Duration(milliseconds: 150);

  /// Untuk transisi umum (panel switch, fade)
  static const Duration animNormal = Duration(milliseconds: 300);

  /// Untuk transisi besar (page transition, overlay)
  static const Duration animSlow = Duration(milliseconds: 500);

  /// Untuk animasi entrance (scale up, slide in)
  static const Duration animEntrance = Duration(milliseconds: 400);

  // ─── Debounce & Throttle ──────────────────────────────
  /// Default debounce untuk slider (60fps = 16ms)
  static const Duration sliderDebounce = Duration(milliseconds: 16);

  /// Debounce untuk search input
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Throttle untuk scroll events
  static const Duration scrollThrottle = Duration(milliseconds: 100);

  // ─── Border Radius Presets ────────────────────────────
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 10.0;
  static const double radiusLarge = 14.0;
  static const double radiusXLarge = 20.0;
  static const double radiusRound = 100.0;

  // ─── Padding Presets ──────────────────────────────────
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 14.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 28.0;

  // ─── Layout ───────────────────────────────────────────
  /// Preview area mengambil ~70% layar
  static const double previewRatio = 0.70;

  /// Max height panel adjustment sliders
  static const double maxPanelHeight = 220.0;

  /// Bottom nav bar height
  static const double bottomNavHeight = 60.0;

  /// Top bar height di editor
  static const double editorTopBarHeight = 48.0;

  /// Tool selector bar height
  static const double toolSelectorHeight = 60.0;
}
