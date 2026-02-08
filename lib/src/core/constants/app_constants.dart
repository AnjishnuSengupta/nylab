/// Nylab - App Constants
///
/// Contains all application-wide constants including API endpoints,
/// animation durations, and configuration values.
library;

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Nylab';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Premium Anime Experience';

  // API Configuration
  static const String baseUrl = 'https://www.nyanime.tech';
  static const String baseApiUrl = 'https://nyanime-backend-v2.onrender.com';
  static const String streamProxyUrl = 'https://www.nyanime.tech';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Animation Durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration heroAnimation = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);

  // UI Constants
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCircular = 100.0;
  static const double borderRadiusFull = 100.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Card dimensions
  static const double animeCardWidth = 140.0;
  static const double animeCardHeight = 200.0;
  static const double carouselHeight = 280.0;
  static const double episodeCardHeight = 80.0;

  // Glassmorphism
  static const double glassBlur = 20.0;
  static const double glassOpacity = 0.15;
  static const double glassBorderOpacity = 0.2;

  // Pagination
  static const int defaultPageSize = 20;
  static const int searchDebounceMs = 500;

  // Cache settings
  static const String hiveCacheBox = 'nylab_cache';
  static const String hiveUserBox = 'nylab_user';
  static const String hiveWatchlistBox = 'nylab_watchlist';
  static const Duration cacheExpiry = Duration(hours: 6);

  // Video Player
  static const List<double> playbackSpeeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];
  static const double defaultPlaybackSpeed = 1.0;

  // Onboarding
  static const int onboardingPageCount = 3;
}

/// Asset paths for the application
class AppAssets {
  AppAssets._();

  // Lottie animations
  static const String lottiePath = 'assets/lottie';
  static const String onboarding1 = '$lottiePath/anime_watching.json';
  static const String onboarding2 = '$lottiePath/anime_search.json';
  static const String onboarding3 = '$lottiePath/anime_collection.json';
  static const String loading = '$lottiePath/loading.json';
  static const String error = '$lottiePath/error.json';
  static const String empty = '$lottiePath/empty.json';

  // Images
  static const String imagesPath = 'assets/images';
  static const String logo = '$imagesPath/logo.png';
  static const String placeholder = '$imagesPath/placeholder.png';
  static const String errorImage = '$imagesPath/error.png';
}

/// Route names for go_router
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String search = '/search';
  static const String animeDetail = '/anime/:id';
  static const String player = '/player/:animeId/:episodeId';
  static const String profile = '/profile';
  static const String watchlist = '/watchlist';
  static const String settings = '/settings';
}
