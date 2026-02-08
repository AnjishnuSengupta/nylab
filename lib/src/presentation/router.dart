/// NYAnime Mobile - Router Configuration
///
/// App router using go_router with declarative routing.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';
import 'screens/screens.dart';
import 'screens/main_shell.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Search
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SearchScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Watchlist
          GoRoute(
            path: '/watchlist',
            name: 'watchlist',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const WatchlistScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),

      // Anime detail (outside shell for full screen)
      GoRoute(
        path: '/anime/:animeId',
        name: 'animeDetail',
        builder: (context, state) {
          final animeId =
              int.tryParse(state.pathParameters['animeId'] ?? '') ?? 0;
          return AnimeDetailScreen(animeId: animeId);
        },
      ),

      // Player (outside shell for full screen)
      GoRoute(
        path: '/player/:animeId/:episodeId',
        name: 'player',
        builder: (context, state) {
          final animeId =
              int.tryParse(state.pathParameters['animeId'] ?? '') ?? 0;
          final episodeId =
              int.tryParse(state.pathParameters['episodeId'] ?? '') ?? 0;
          return PlayerScreen(animeId: animeId, episodeId: episodeId);
        },
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.accentRed,
              ),
              const SizedBox(height: 16),
              Text(
                '404 - Page Not Found',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The page you\'re looking for doesn\'t exist',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

// Custom fade transition
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
    child: child,
  );
}
