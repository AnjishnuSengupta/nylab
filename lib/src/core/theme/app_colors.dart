/// NYAnime Mobile - App Colors
///
/// Premium dark theme color palette with glassmorphism and neon accents
/// Inspired by modern anime streaming platforms.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Background Gradient Colors
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color backgroundMid = Color(0xFF1A1A2E);
  static const Color backgroundLight = Color(0xFF16213E);

  // Primary Accent Colors - Neon Purple/Pink anime style
  static const Color primaryPurple = Color(0xFF9D4EDD);
  static const Color primaryPink = Color(0xFFE040FB);
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color primaryMagenta = Color(0xFFFF00FF);

  // Secondary Accent Colors
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentRed = Color(0xFFFF5252);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF707070);
  static const Color textDisabled = Color(0xFF4A4A4A);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);
  static const Color glassDark = Color(0x33000000);

  // Card Colors
  static const Color cardBackground = Color(0xFF1E1E2E);
  static const Color cardBorder = Color(0xFF2A2A3E);
  static const Color cardHighlight = Color(0xFF2E2E4E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Genre Colors (for tags)
  static const Color genreAction = Color(0xFFFF5722);
  static const Color genreComedy = Color(0xFFFFEB3B);
  static const Color genreDrama = Color(0xFF9C27B0);
  static const Color genreFantasy = Color(0xFF3F51B5);
  static const Color genreHorror = Color(0xFF212121);
  static const Color genreRomance = Color(0xFFE91E63);
  static const Color genreSciFi = Color(0xFF00BCD4);
  static const Color genreSciF1 = Color(0xFF00BCD4); // Alias
  static const Color genreSliceOfLife = Color(0xFF8BC34A);
  static const Color genreSports = Color(0xFFFF9800);
  static const Color genreSupernatural = Color(0xFF673AB7);
  static const Color genreAdventure = Color(0xFF4CAF50);

  // Border Colors
  static const Color borderColor = Color(0xFF2A2A3E);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF2A2A3E);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark, backgroundMid],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryPink],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCyan, primaryPurple, primaryPink],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E2E), Color(0xFF2A2A3E)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
  );

  static const RadialGradient spotlightGradient = RadialGradient(
    center: Alignment.center,
    radius: 1.0,
    colors: [Color(0x33FF00FF), Color(0x00FF00FF)],
  );

  // Shadow Colors
  static const Color shadowPrimary = Color(0x669D4EDD);
  static const Color shadowDark = Color(0x66000000);

  /// Get genre color by genre name
  static Color getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return genreAction;
      case 'comedy':
        return genreComedy;
      case 'drama':
        return genreDrama;
      case 'fantasy':
        return genreFantasy;
      case 'horror':
        return genreHorror;
      case 'romance':
        return genreRomance;
      case 'sci-fi':
      case 'science fiction':
        return genreSciF1;
      case 'slice of life':
        return genreSliceOfLife;
      case 'sports':
        return genreSports;
      case 'supernatural':
        return genreSupernatural;
      default:
        return primaryPurple;
    }
  }
}
