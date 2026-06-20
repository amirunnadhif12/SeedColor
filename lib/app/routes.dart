import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_scaffold.dart';
import '../features/library/presentation/pages/library_page.dart';
import '../features/library/presentation/pages/album_detail_page.dart';
import '../features/presets/presentation/pages/preset_browser_page.dart';
import '../features/editor/presentation/pages/editor_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

/// 🌱 SeedColor — Router Configuration
///
/// Menggunakan GoRouter dengan StatefulShellRoute untuk
/// bottom navigation yang persistent antar tab.
/// Setiap tab memiliki navigasi stack sendiri.
class AppRoutes {
  AppRoutes._();

  // ─── Route Paths ─────────────────────────────────────
  static const String library = '/library';
  static const String presets = '/presets';
  static const String edit = '/edit';
  static const String profile = '/profile';
  static const String editor = '/editor';

  // ─── Navigation Key ──────────────────────────────────
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: library,
    routes: [
      // ─── ShellRoute: Bottom Navigation ──────────────
      // Membungkus 4 tab utama agar bottom nav tetap
      // persistent saat navigasi antar tab.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: library,
                name: 'library',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LibraryPage(),
                ),
                routes: [
                  GoRoute(
                    path: 'album/:id',
                    name: 'album',
                    builder: (context, state) {
                      final albumId = state.pathParameters['id'] ?? '';
                      final albumName = state.uri.queryParameters['name'] ?? '';
                      return AlbumDetailPage(albumId: albumId, albumName: albumName);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 1: Presets
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: presets,
                name: 'presets',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PresetBrowserPage(),
                ),
              ),
            ],
          ),

          // Tab 2: Edit
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: edit,
                name: 'edit',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: EditorScreen(photoId: 'sample'),
                ),
              ),
            ],
          ),

          // Tab 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                name: 'profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ─── Standalone Editor ────────────────────────────
      // Masuk dari library (tanpa bottom nav, full screen)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '$editor/:photoId',
        name: 'editor',
        pageBuilder: (context, state) {
          final photoId = state.pathParameters['photoId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditorScreen(photoId: photoId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
    ],
  );
}
