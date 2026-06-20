import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/launch_utils.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0.0;
  Timer? _fadeTimer;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _fadeTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    _navTimer = Timer(const Duration(milliseconds: 1800), _navigateNext);
  }

  void _navigateNext() async {
    final first = await LaunchUtils.isFirstLaunch();
    if (mounted) {
      if (first) {
        context.go('/onboarding');
      } else {
        context.go('/library');
      }
    }
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'SeedColor',
                style: AppTypography.heading1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Professional Color Grading Engine',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
