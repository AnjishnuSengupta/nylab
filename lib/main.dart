/// Nylab - Main Entry Point
///
/// A premium anime streaming app with modern Material You design,
/// glassmorphism effects, and smooth animations.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/core/core.dart';
import 'src/data/data.dart';
import 'src/presentation/presentation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(AnimeAdapter());
  Hive.registerAdapter(EpisodeAdapter());

  // Open Hive boxes
  await Hive.openBox<Anime>('anime_cache');
  await Hive.openBox<List<Episode>>('episodes_cache');
  await Hive.openBox('watchlist');
  await Hive.openBox('watch_progress');
  await Hive.openBox('settings');
  await Hive.openBox('aniwatch_cache');
  await Hive.openBox('watch_history');
  await Hive.openBox('user_settings');

  // Initialize LocalStorage (opens nylab_cache, nylab_user, nylab_watchlist boxes)
  await LocalStorage.instance.init();

  // Initialize network service
  await networkService.initialize();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: NylabApp()));
}

class NylabApp extends ConsumerWidget {
  const NylabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Nylab',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Router
      routerConfig: router,

      // Builder for global overlays
      builder: (context, child) {
        // Apply text scale factor limit for accessibility
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
