/// NYAnime Mobile - Glassmorphism Card Widget
///
/// A beautiful glassmorphism card with blur effect and gradient border.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/core.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final double borderOpacity;
  final Color? borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppConstants.borderRadiusLarge,
    this.blur = AppConstants.glassBlur,
    this.backgroundColor,
    this.backgroundOpacity = AppConstants.glassOpacity,
    this.borderOpacity = AppConstants.glassBorderOpacity,
    this.borderColor,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                decoration: BoxDecoration(
                  color: (backgroundColor ?? Colors.white).withOpacity(
                    backgroundOpacity,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color:
                        borderColor ?? Colors.white.withOpacity(borderOpacity),
                    width: 1,
                  ),
                  boxShadow: shadows,
                ),
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism button variant
class GlassmorphismButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final bool isLoading;

  const GlassmorphismButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderRadius = AppConstants.borderRadiusMedium,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.glowColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
