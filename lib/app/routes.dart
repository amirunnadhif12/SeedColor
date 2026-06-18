import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_scaffold.dart';
import '../../features/editor/presentation/pages/editor_page.dart';

/// 🌱 SeedColor — Router Configuration
///
/// Menggunakan GoRouter untuk declarative routing.
/// Bottom navigation menggunakan MainScaffold sebagai shell.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String editor = '/editor';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Main scaffold dengan bottom nav
      GoRoute(
        path: home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MainScaffold(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Standalone editor (masuk dari library, tanpa bottom nav)
      GoRoute(
        path: '$editor/:photoId',
        name: 'editor',
        pageBuilder: (context, state) {
          final photoId = state.pathParameters['photoId'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditorPage(photoId: photoId),
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
