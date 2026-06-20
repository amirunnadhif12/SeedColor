import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/launch_utils.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _slides = [
    const OnboardingItem(
      icon: Icons.eco_rounded,
      iconColor: AppColors.primary,
      title: 'Selamat Datang di SeedColor',
      description: 'Aplikasi pengeditan warna dan color grading foto profesional berkecepatan tinggi dengan akselerasi penuh shader GPU.',
    ),
    const OnboardingItem(
      icon: Icons.auto_graph_rounded,
      iconColor: AppColors.toolLight,
      title: 'Kontrol Tonalitas Presisi',
      description: 'Sesuaikan pencahayaan, temperatur warna, HSL mixer, hingga kurva warna RGB secara detail untuk hasil akhir berkualitas tinggi.',
    ),
    const OnboardingItem(
      icon: Icons.style_rounded,
      iconColor: Color(0xFF00E6FF),
      title: '15+ Presets Premium & XMP',
      description: 'Gunakan puluhan preset bawaan yang menakjubkan atau impor dan ekspor preset Lightroom-compatible dalam format .XMP.',
    ),
    const OnboardingItem(
      icon: Icons.ios_share_rounded,
      iconColor: AppColors.toolGeometry,
      title: 'Ekspor Resolusi Penuh & Share',
      description: 'Ekspor karya terbaik Anda ke format JPEG dengan kualitas disesuaikan atau format PNG lossless, serta bagikan langsung ke media sosial.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() async {
    await LaunchUtils.markFirstLaunchCompleted();
    if (mounted) {
      context.go('/library');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLastPage
                    ? const SizedBox(height: 36)
                    : TextButton(
                        onPressed: _onFinish,
                        child: Text(
                          'Lewati',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
              ),
            ),

            // Page Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Slide Logo in Gradient Circle
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: slide.iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: slide.iconColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 56,
                            color: slide.iconColor,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Title
                        Text(
                          slide.title,
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          slide.description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Dot Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          _onFinish();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const OnboardingItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
