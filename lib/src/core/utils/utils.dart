/// NYAnime Mobile - Core Utilities
///
/// Common utility functions, extensions, and helpers used throughout the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Extension on BuildContext for easy access to theme and media query
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isTablet => screenWidth > 600;
  bool get isDesktop => screenWidth > 1200;
}

/// Extension on Duration for formatting
extension DurationExtensions on Duration {
  /// Format duration as "Xd Xh Xm Xs" countdown
  String toCountdown() {
    final days = inDays;
    final hours = inHours.remainder(24);
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format duration as video timestamp "HH:MM:SS" or "MM:SS"
  String toTimestamp() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Extension on DateTime for formatting
extension DateTimeExtensions on DateTime {
  /// Format as "MMM DD, YYYY"
  String toDisplayDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Get time until this date as Duration
  Duration get timeUntil => difference(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get season name from date
  String get season {
    if (month >= 1 && month <= 3) return 'Winter';
    if (month >= 4 && month <= 6) return 'Spring';
    if (month >= 7 && month <= 9) return 'Summer';
    return 'Fall';
  }
}

/// Extension on String for common operations
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }
}

/// Extension on num for formatting
extension NumExtensions on num {
  /// Format number with K/M suffix
  String toCompact() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Alias for toCompact
  String compactNumber() => toCompact();

  /// Format as rating (e.g., "8.5")
  String toRating() {
    return toStringAsFixed(1);
  }
}

/// Utility class for haptic feedback
class HapticUtils {
  HapticUtils._();

  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  static void vibrate() {
    HapticFeedback.vibrate();
  }
}

/// Utility class for common decorations
class DecorationUtils {
  DecorationUtils._();

  /// Glassmorphism decoration
  static BoxDecoration glass({
    double blur = 20,
    double opacity = 0.15,
    double borderOpacity = 0.2,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1,
      ),
    );
  }

  /// Neumorphic light decoration
  static BoxDecoration neumorphicLight({
    Color color = AppColors.cardBackground,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          offset: const Offset(-4, -4),
          blurRadius: 8,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
      ],
    );
  }

  /// Neon glow decoration
  static BoxDecoration neonGlow({
    Color glowColor = AppColors.primaryPurple,
    double intensity = 0.5,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(intensity * 0.4),
          blurRadius: 8,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: glowColor.withOpacity(intensity * 0.2),
          blurRadius: 16,
          spreadRadius: 4,
        ),
      ],
    );
  }

  /// Gradient overlay for images
  static BoxDecoration imageOverlay({
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors:
            colors ??
            [
              Colors.transparent,
              AppColors.backgroundDark.withOpacity(0.5),
              AppColors.backgroundDark,
            ],
        stops: const [0.0, 0.6, 1.0],
      ),
    );
  }
}

/// Utility class for responsive values
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get responsive value based on screen width
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive grid cross axis count
  static int gridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    if (width >= 400) return 3;
    return 2;
  }

  /// Get responsive padding
  static EdgeInsets screenPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return const EdgeInsets.symmetric(horizontal: 48);
    if (width >= 600) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 16);
  }
}

/// Utility class for debouncing
class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  bool _isDisposed = false;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _action = action;
    Future.delayed(delay, () {
      if (!_isDisposed && _action != null) {
        _action!();
      }
    });
  }

  void dispose() {
    _isDisposed = true;
    _action = null;
  }
}
