import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_constants.dart';

/// 🌱 SeedColor — SeedBottomSheet
///
/// Pattern bottom sheet yang konsisten di seluruh aplikasi.
/// Menyediakan:
/// - Drag handle
/// - Title bar dengan optional close button
/// - Scrollable content area
/// - Smooth animasi masuk/keluar

/// Menampilkan SeedBottomSheet sebagai modal.
///
/// ```dart
/// SeedBottomSheet.show(
///   context: context,
///   title: 'Pilih Aspect Ratio',
///   builder: (context) => Column(
///     children: [
///       ListTile(title: Text('Free')),
///       ListTile(title: Text('1:1')),
///       ListTile(title: Text('4:3')),
///     ],
///   ),
/// );
/// ```
class SeedBottomSheet {
  SeedBottomSheet._();

  /// Tampilkan bottom sheet modal.
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    String? title,
    bool showCloseButton = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeight,
    bool useRootNavigator = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useRootNavigator: useRootNavigator,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SeedBottomSheetContent(
          title: title,
          showCloseButton: showCloseButton,
          maxHeight: maxHeight,
          child: builder(context),
        );
      },
    );
  }
}

class _SeedBottomSheetContent extends StatelessWidget {
  final String? title;
  final bool showCloseButton;
  final double? maxHeight;
  final Widget child;

  const _SeedBottomSheetContent({
    this.title,
    this.showCloseButton = true,
    this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPanel,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Drag Handle ─────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),

          // ─── Title Bar ───────────────────────────
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.heading4.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (showCloseButton)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ─── Divider ─────────────────────────────
          if (title != null)
            const Divider(
              color: AppColors.border,
              height: 1,
              thickness: 0.5,
            ),

          // ─── Content ─────────────────────────────
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: child,
            ),
          ),

          // ─── Bottom Safe Area ────────────────────
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}
