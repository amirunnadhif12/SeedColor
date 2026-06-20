import 'package:get_it/get_it.dart';
import '../../core/database/app_database.dart';
import '../../features/editor/data/repositories/editor_repository_impl.dart';
import '../../features/editor/domain/repositories/editor_repository.dart';
import '../../features/editor/domain/usecases/apply_adjustments.dart';
import '../../features/editor/domain/usecases/apply_curves.dart';
import '../../features/editor/domain/usecases/apply_hsl.dart';
import '../../features/editor/domain/usecases/export_image.dart';
import '../../features/editor/domain/usecases/reset_adjustments.dart';
import '../../features/editor/presentation/bloc/editor_bloc.dart';
import '../../features/library/data/datasources/album_local_datasource.dart';
import '../../features/library/data/datasources/photo_local_datasource.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/domain/usecases/get_albums.dart';
import '../../features/library/domain/usecases/import_photos.dart';
import '../../features/library/domain/usecases/manage_ratings.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';

/// 🌱 SeedColor — Dependency Injection
///
/// Service locator menggunakan GetIt.
/// Semua dependencies di-register di sini.
final GetIt sl = GetIt.instance;

/// Inisialisasi semua dependencies
Future<void> initDependencies() async {
  // ─── Core ─────────────────────────────────────────────
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ─── Data Sources ─────────────────────────────────────
  sl.registerLazySingleton<PhotoLocalDataSource>(() => PhotoLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AlbumLocalDataSource>(() => AlbumLocalDataSourceImpl(sl()));

  // ─── Repositories ─────────────────────────────────────
  sl.registerLazySingleton<EditorRepository>(() => EditorRepositoryImpl());
  sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(
        photoDataSource: sl(),
        albumDataSource: sl(),
      ));

  // ─── Use Cases ────────────────────────────────────────
  sl.registerLazySingleton<ApplyAdjustments>(() => ApplyAdjustments());
  sl.registerLazySingleton<ApplyCurves>(() => ApplyCurves());
  sl.registerLazySingleton<ApplyHsl>(() => ApplyHsl());
  sl.registerLazySingleton<ResetAdjustments>(() => ResetAdjustments());
  sl.registerLazySingleton<ExportImage>(() => ExportImage(sl()));

  sl.registerLazySingleton<ImportPhotos>(() => ImportPhotos(sl()));
  sl.registerLazySingleton<GetAlbums>(() => GetAlbums(sl()));
  sl.registerLazySingleton<ManageRatings>(() => ManageRatings(sl()));

  // ─── BLoCs ────────────────────────────────────────────
  sl.registerFactory<EditorBloc>(() => EditorBloc(
        repository: sl(),
        applyAdjustments: sl(),
        applyCurves: sl(),
        applyHsl: sl(),
        resetAdjustments: sl(),
        exportImage: sl(),
      ));
  sl.registerFactory<LibraryBloc>(() => LibraryBloc(repository: sl()));
}
