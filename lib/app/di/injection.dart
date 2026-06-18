import 'package:get_it/get_it.dart';

/// 🌱 SeedColor — Dependency Injection
///
/// Service locator menggunakan GetIt.
/// Semua dependencies di-register di sini.
final GetIt sl = GetIt.instance;

/// Inisialisasi semua dependencies
Future<void> initDependencies() async {
  // ─── Core ─────────────────────────────────────────────

  // ─── Data Sources ─────────────────────────────────────

  // ─── Repositories ─────────────────────────────────────

  // ─── Use Cases ────────────────────────────────────────

  // ─── BLoCs ────────────────────────────────────────────

  // Dependencies akan ditambahkan seiring development
  // setiap feature module.
}
