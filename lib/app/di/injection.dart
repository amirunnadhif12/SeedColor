import 'package:get_it/get_it.dart';
import '../../features/editor/data/repositories/editor_repository_impl.dart';
import '../../features/editor/domain/repositories/editor_repository.dart';
import '../../features/editor/domain/usecases/apply_adjustments.dart';
import '../../features/editor/domain/usecases/apply_curves.dart';
import '../../features/editor/domain/usecases/apply_hsl.dart';
import '../../features/editor/domain/usecases/export_image.dart';
import '../../features/editor/domain/usecases/reset_adjustments.dart';
import '../../features/editor/presentation/bloc/editor_bloc.dart';

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
  sl.registerLazySingleton<EditorRepository>(() => EditorRepositoryImpl());

  // ─── Use Cases ────────────────────────────────────────
  sl.registerLazySingleton<ApplyAdjustments>(() => ApplyAdjustments());
  sl.registerLazySingleton<ApplyCurves>(() => ApplyCurves());
  sl.registerLazySingleton<ApplyHsl>(() => ApplyHsl());
  sl.registerLazySingleton<ResetAdjustments>(() => ResetAdjustments());
  sl.registerLazySingleton<ExportImage>(() => ExportImage(sl()));

  // ─── BLoCs ────────────────────────────────────────────
  sl.registerFactory<EditorBloc>(() => EditorBloc(
        repository: sl(),
        applyAdjustments: sl(),
        applyCurves: sl(),
        applyHsl: sl(),
        resetAdjustments: sl(),
        exportImage: sl(),
      ));
}
