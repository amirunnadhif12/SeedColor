import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_constants.dart';

/// 🌱 SeedColor — SeedButton Variants
///
/// Koleksi button premium dengan micro-animations.
/// Digunakan di seluruh aplikasi untuk konsistensi visual.

// ═══════════════════════════════════════════════════════════
//  SeedIconButton — Icon button dengan scale animation
// ═══════════════════════════════════════════════════════════

/// Icon button premium dengan:
/// - Scale animation on press (shrink to 0.9)
/// - Optional badge dot (untuk notifikasi/status)
/// - Haptic feedback
///
/// ```dart
/// SeedIconButton(
///   icon: Icons.undo_rounded,
///   onPressed: () => bloc.add(Undo()),
///   tooltip: 'Urungkan',
/// )
/// ```
class SeedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? activeColor;
  final bool isActive;
  final bool showBadge;
  final Color? badgeColor;
  final bool haptic;

  const SeedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.size = 22,
    this.color,
    this.activeColor,
    this.isActive = false,
    this.showBadge = false,
    this.badgeColor,
    this.haptic = true,
  });

  @override
  State<SeedIconButton> createState() => _SeedIconButtonState();
}

class _SeedIconButtonState extends State<SeedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.haptic) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final color = widget.isActive
        ? (widget.activeColor ?? AppColors.primary)
        : (widget.color ??
            (isEnabled ? AppColors.textSecondary : AppColors.textDisabled));

    Widget button = GestureDetector(
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      onTap: isEnabled ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(widget.icon, size: widget.size, color: color),
              if (widget.showBadge)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: widget.badgeColor ?? AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }
}

// ═══════════════════════════════════════════════════════════
//  SeedActionButton — Text+icon button (Auto, Reset, dll)
// ═══════════════════════════════════════════════════════════

/// Button dengan text dan optional icon.
/// Digunakan untuk aksi seperti "Auto", "Reset", "Apply".
///
/// ```dart
/// SeedActionButton(
///   label: 'Auto',
///   icon: Icons.auto_fix_high_rounded,
///   onPressed: () => bloc.add(AutoExposure()),
/// )
/// ```
class SeedActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isCompact;

  const SeedActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.isCompact = false,
  });

  @override
  State<SeedActionButton> createState() => _SeedActionButtonState();
}

class _SeedActionButtonState extends State<SeedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _controller.forward() : null,
      onTapUp: isEnabled ? (_) => _controller.reverse() : null,
      onTapCancel: isEnabled ? () => _controller.reverse() : null,
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCompact ? 10 : 14,
            vertical: widget.isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? AppColors.primary
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: widget.isCompact ? 14 : 16,
                  color: widget.isPrimary
                      ? Colors.white
                      : (isEnabled
                          ? AppColors.textSecondary
                          : AppColors.textDisabled),
                ),
                SizedBox(width: widget.isCompact ? 4 : 6),
              ],
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.isPrimary
                      ? Colors.white
                      : (isEnabled
                          ? AppColors.textSecondary
                          : AppColors.textDisabled),
                  fontSize: widget.isCompact ? 11 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  SeedToggleButton — Toggle on/off dengan animated state
// ═══════════════════════════════════════════════════════════

/// Toggle button yang berubah warna saat aktif.
/// Digunakan untuk Lens Correction, Chromatic Aberration, dll.
///
/// ```dart
/// SeedToggleButton(
///   label: 'Koreksi Lensa',
///   icon: Icons.lens_rounded,
///   isActive: _lensCorrection,
///   onToggle: (val) => setState(() => _lensCorrection = val),
/// )
/// ```
class SeedToggleButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const SeedToggleButton({
    super.key,
    required this.label,
    this.icon,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle(!isActive);
      },
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 1.0 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: AppConstants.animFast,
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  width: 1.5,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
