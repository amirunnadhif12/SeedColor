import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_typography.dart';

/// 🌱 SeedColor — Main Scaffold dengan Bottom Navigation
///
/// Shell widget yang membungkus 4 tab utama menggunakan
/// GoRouter StatefulShellRoute agar state setiap tab tetap hidup.
///
/// Tab: Library, Presets, Edit, Profile
class MainScaffold extends StatelessWidget {
  /// Navigation shell dari GoRouter StatefulShellRoute.
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.navBarBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: navigationShell,
        bottomNavigationBar: navigationShell.currentIndex == 2
            ? null
            : _BottomNavBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => _onTap(index),
              ),
      ),
    );
  }

  /// Navigate ke tab lain via GoRouter ShellRoute.
  /// [initialLocation: true] agar kembali ke root route tab tersebut.
  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Bottom navigation bar widget (extracted untuk kebersihan).
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBarBackground,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.photo_library_outlined,
                activeIcon: Icons.photo_library_rounded,
                label: 'Library',
                onTap: onTap,
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                label: 'Presets',
                onTap: onTap,
              ),
              _NavItem(
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.edit_outlined,
                activeIcon: Icons.edit_rounded,
                label: 'Edit',
                onTap: onTap,
              ),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual navigation item with animation.
class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  bool get _isSelected => currentIndex == index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_isSelected) {
          HapticFeedback.lightImpact();
        }
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _isSelected ? activeIcon : icon,
                key: ValueKey(_isSelected),
                size: 24,
                color: _isSelected
                    ? AppColors.navBarSelected
                    : AppColors.navBarUnselected,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.toolLabel.copyWith(
                color: _isSelected
                    ? AppColors.navBarSelected
                    : AppColors.navBarUnselected,
                fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
