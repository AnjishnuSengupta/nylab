/// NYAnime Mobile - Splash Screen
///
/// Animated splash screen with logo and loading animation.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(AppConstants.splashDuration);
    if (mounted) {
      // TODO: Check if onboarding completed
      // For now, always go to onboarding
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Animated background particles/glow
            ..._buildBackgroundEffects(),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _buildLogo(),

                  const SizedBox(height: 24),

                  // App name
                  _buildAppName(),

                  const SizedBox(height: 8),

                  // Tagline
                  _buildTagline(),

                  const SizedBox(height: 48),

                  // Loading indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),

            // Version at bottom
            Positioned(bottom: 48, left: 0, right: 0, child: _buildVersion()),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundEffects() {
    return [
      // Purple glow
      Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.2, 1.2),
            duration: 3.seconds,
          )
          .then()
          .scale(
            begin: const Offset(1.2, 1.2),
            end: const Offset(0.8, 0.8),
            duration: 3.seconds,
          ),

      // Pink glow
      Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPink.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.3, 1.3),
            duration: 4.seconds,
          )
          .then()
          .scale(
            begin: const Offset(1.3, 1.3),
            end: const Offset(1.0, 1.0),
            duration: 4.seconds,
          ),
    ];
  }

  Widget _buildLogo() {
    return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_filled_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        )
        .animate()
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildAppName() {
    return ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.neonGradient.createShader(bounds),
          child: Text(
            AppConstants.appName,
            style: AppTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildTagline() {
    return Text(
          AppConstants.appTagline,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms);
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
          width: 150,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
            minHeight: 3,
            borderRadius: BorderRadius.circular(2),
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .shimmer(duration: 1500.ms, delay: 800.ms);
  }

  Widget _buildVersion() {
    return Text(
      'v${AppConstants.appVersion}',
      textAlign: TextAlign.center,
      style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
    ).animate().fadeIn(delay: 800.ms, duration: 400.ms);
  }
}
