import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_constants.dart';

/// 🌱 SeedColor — Loading Overlay
///
/// Fullscreen loading indicator dengan:
/// - Semi-transparent dark backdrop
/// - Animated pulse ring
/// - Optional progress text
///
/// ```dart
/// // Show loading
/// LoadingOverlay.show(context, message: 'Mengekspor...');
///
/// // Hide loading
/// LoadingOverlay.hide(context);
/// ```
class LoadingOverlay {
  LoadingOverlay._();

  static OverlayEntry? _overlayEntry;

  /// Tampilkan loading overlay di atas semua widget.
  static void show(
    BuildContext context, {
    String? message,
  }) {
    // Hindari duplikat overlay
    hide(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingOverlayWidget(message: message),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Sembunyikan loading overlay.
  static void hide(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Tampilkan loading overlay sebagai dialog (alternatif).
  /// Lebih aman karena menggunakan Navigator route.
  static Future<void> showDialog(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black54,
      transitionDuration: AppConstants.animNormal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _LoadingOverlayWidget(message: message);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
    );
  }
}

class _LoadingOverlayWidget extends StatefulWidget {
  final String? message;

  const _LoadingOverlayWidget({this.message});

  @override
  State<_LoadingOverlayWidget> createState() => _LoadingOverlayWidgetState();
}

class _LoadingOverlayWidgetState extends State<_LoadingOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Animated Pulse Ring ────────────────
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Progress Text ─────────────────────
              if (widget.message != null) ...[
                const SizedBox(height: 20),
                Text(
                  widget.message!,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // ─── Linear progress indicator ─────────
              const SizedBox(height: 16),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    backgroundColor:
                        AppColors.textPrimary.withValues(alpha: 0.1),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
