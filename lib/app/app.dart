import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

/// 🌱 SeedColor — Main Application Widget
///
/// Root widget aplikasi SeedColor.
class SeedColorApp extends StatelessWidget {
  const SeedColorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852), // Based on Pixel 7 / standard Android
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          // ─── App Info ────────────────────────────────
          title: 'SeedColor',
          debugShowCheckedModeBanner: false,

          // ─── Theme ───────────────────────────────────
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,

          // ─── Routing ─────────────────────────────────
          routerConfig: AppRoutes.router,
        );
      },
    );
  }
}
