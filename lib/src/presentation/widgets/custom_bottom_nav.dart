/// NYAnime Mobile - Cyberpunk Bottom Navigation Bar
///
/// Glassmorphism bottom navigation with neon underglow, floating lift,
/// and animated indicators.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  static const _cyberPurple = Color(0xFF8B5CF6);
  static const _neonCyan = Color(0xFF06B6D4);

  static const _items = [
    _NavItem(Icons.home_rounded, Icons.home_outlined, 'Home'),
    _NavItem(Icons.search_rounded, Icons.search_outlined, 'Search'),
    _NavItem(
      Icons.bookmark_rounded,
      Icons.bookmark_outline_rounded,
      'Watchlist',
    ),
    _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_glowController.value * 0.4);

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              // Neon underglow - purple
              BoxShadow(
                color: _cyberPurple.withOpacity(glowIntensity * 0.5),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              // Neon underglow - cyan accent
              BoxShadow(
                color: _neonCyan.withOpacity(glowIntensity * 0.3),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
              // Shadow for floating lift
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _cyberPurple.withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_items.length, (index) {
                      return _buildNavItem(index, _items[index]);
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () {
        // Cyberpunk haptic pattern - different per tab
        switch (index) {
          case 0:
            HapticFeedback.lightImpact();
            break;
          case 1:
            HapticFeedback.mediumImpact();
            break;
          case 2:
            HapticFeedback.selectionClick();
            break;
          case 3:
            HapticFeedback.heavyImpact();
            break;
        }
        widget.onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 14,
          vertical: 8,
        ),
        transform: Matrix4.translationValues(
          0,
          isSelected ? -8 : 0, // Floating 8px lift
          0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _cyberPurple.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: _cyberPurple.withOpacity(0.4), width: 1.0)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _cyberPurple.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow effect
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    // Neon glow behind icon
                    Icon(
                      item.activeIcon,
                      key: const ValueKey('glow'),
                      color: _cyberPurple.withOpacity(0.5),
                      size: 28,
                    ),
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? Colors.white : Colors.white38,
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Label with gradient for active
            isSelected
                ? ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_cyberPurple, _neonCyan],
                    ).createShader(bounds),
                    child: Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                : Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white38,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData activeIcon;
  final IconData icon;
  final String label;

  const _NavItem(this.activeIcon, this.icon, this.label);
}
