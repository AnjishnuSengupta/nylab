/// Nylab - Riverpod Providers
///
/// State management using hooks_riverpod with FutureProvider/StateProvider.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/core.dart';
import '../../data/data.dart' hide UserRepository;
import '../../domain/domain.dart';

// ============ Core Providers ============

/// Network status stream provider
final networkStatusStreamProvider = StreamProvider<NetworkStatus>((ref) {
  return networkService.statusStream;
});

/// Current network status provider
final networkStatusProvider = Provider<NetworkStatus>((ref) {
  final asyncStatus = ref.watch(networkStatusStreamProvider);
  return asyncStatus.valueOrNull ?? NetworkStatus.unknown;
});

/// Is offline provider
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(networkStatusProvider);
  return status == NetworkStatus.offline;
});

/// API Client provider (legacy, kept for compatibility)
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(() => client.dispose());
  return client;
});

/// Local Storage provider
final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage.instance;
});

/// Anime Repository provider (uses real Aniwatch API)
final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  return AnimeRepository(
    apiClient: ref.watch(apiClientProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

/// User Repository provider (with Firebase sync)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(localStorage: ref.watch(localStorageProvider));
});

/// Stream Repository provider (for HLS streaming)
final streamRepositoryProvider = Provider<AniwatchStreamRepository>((ref) {
  return streamRepository;
});

// ============ Anime Data Providers ============

/// Trending anime provider
final trendingAnimeProvider = FutureProvider<List<Anime>>((ref) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getTrendingAnime();
});

/// Seasonal anime provider
final seasonalAnimeProvider = FutureProvider<List<Anime>>((ref) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getSeasonalAnime();
});

/// Top airing anime provider
final topAiringAnimeProvider = FutureProvider<List<Anime>>((ref) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getTopAiring();
});

/// Most popular anime provider
final mostPopularAnimeProvider = FutureProvider<List<Anime>>((ref) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getMostPopular();
});

/// Latest episodes provider
final latestEpisodesProvider = FutureProvider<List<Anime>>((ref) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getLatestEpisodes();
});

/// Anime detail provider (family for different anime slugs)
final animeDetailProvider = FutureProvider.family<Anime?, String>((
  ref,
  slug,
) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getAnimeBySlug(slug);
});

/// Anime detail by ID provider (for backward compatibility)
final animeDetailByIdProvider = FutureProvider.family<Anime?, int>((
  ref,
  id,
) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getAnimeById(id);
});

/// Episodes provider (family using slug)
final episodesBySlugProvider = FutureProvider.family<List<Episode>, String>((
  ref,
  slug,
) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getEpisodesBySlug(slug);
});

/// Episodes provider (family for different anime IDs - backward compat)
final episodesProvider = FutureProvider.family<List<Episode>, int>((
  ref,
  animeId,
) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getEpisodes(animeId);
});

/// Genres provider
final genresProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getGenres();
});

// ============ Stream Providers ============

/// Stream URL provider (for playing episodes)
final streamUrlProvider =
    FutureProvider.family<StreamData?, ({String slug, int episodeNumber})>((
      ref,
      params,
    ) async {
      final repository = ref.watch(streamRepositoryProvider);
      return repository.getStreamUrl(params.slug, params.episodeNumber);
    });

// ============ Search Providers ============

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected genres for filtering
final selectedGenresProvider = StateProvider<List<String>>((ref) => []);

/// Search results provider
final searchResultsProvider = FutureProvider<List<Anime>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final genres = ref.watch(selectedGenresProvider);

  if (query.isEmpty && genres.isEmpty) {
    // Return trending if no search/filter
    final repository = ref.watch(animeRepositoryProvider);
    return repository.getTrendingAnime();
  }

  final repository = ref.watch(animeRepositoryProvider);
  return repository.searchAnime(query, genres: genres.isEmpty ? null : genres);
});

// ============ User Data Providers ============

/// Continue watching provider
final continueWatchingProvider = Provider<List<WatchProgress>>((ref) {
  try {
    final repository = ref.watch(userRepositoryProvider);
    return repository.getContinueWatching();
  } catch (e) {
    // LocalStorage may not be initialized yet
    return [];
  }
});

/// Watchlist provider
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<WatchlistItem>>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return WatchlistNotifier(repository);
    });

/// User stats provider
final userStatsProvider = Provider<UserStats>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserStats();
});

/// User profile provider
final userProfileProvider = Provider<UserProfile>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserProfile();
});

/// Check if anime is in watchlist
final isInWatchlistProvider = Provider.family<bool, int>((ref, animeId) {
  final watchlist = ref.watch(watchlistProvider);
  return watchlist.any((item) => item.animeId == animeId);
});

// ============ Sync Providers ============

/// Firebase auth state
final isSignedInProvider = Provider<bool>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.isSignedIn;
});

/// Last sync time provider
final lastSyncTimeProvider = Provider<String>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.lastSyncedAgo;
});

// ============ Settings Providers ============

/// Onboarding completed provider
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  try {
    final repository = ref.watch(userRepositoryProvider);
    return repository.isOnboardingCompleted();
  } catch (e) {
    return false;
  }
});

/// Playback speed provider
final playbackSpeedProvider = StateProvider<double>((ref) {
  try {
    final repository = ref.watch(userRepositoryProvider);
    return repository.getPlaybackSpeed();
  } catch (e) {
    return 1.0;
  }
});

// ============ State Notifiers ============

/// Watchlist state notifier
class WatchlistNotifier extends StateNotifier<List<WatchlistItem>> {
  final UserRepository _repository;

  WatchlistNotifier(this._repository) : super(_safeGetWatchlist(_repository));

  static List<WatchlistItem> _safeGetWatchlist(UserRepository repo) {
    try {
      return repo.getWatchlist();
    } catch (e) {
      return [];
    }
  }

  void add(Anime anime) {
    final item = WatchlistItem(
      animeId: anime.id,
      animeTitle: anime.displayTitle,
      animePosterUrl: anime.posterUrl,
      status: WatchlistStatus.planToWatch,
      addedAt: DateTime.now(),
    );
    _repository.addToWatchlist(item);
    state = [...state, item];
  }

  void addToWatchlist(WatchlistItem item) {
    _repository.addToWatchlist(item);
    state = [...state, item];
  }

  void remove(int animeId) {
    _repository.removeFromWatchlist(animeId);
    state = state.where((item) => item.animeId != animeId).toList();
  }

  void removeFromWatchlist(int animeId) {
    _repository.removeFromWatchlist(animeId);
    state = state.where((item) => item.animeId != animeId).toList();
  }

  void updateStatus(int animeId, WatchlistStatus status) {
    final index = state.indexWhere((item) => item.animeId == animeId);
    if (index != -1) {
      final item = state[index];
      final updatedItem = WatchlistItem(
        animeId: item.animeId,
        animeTitle: item.animeTitle,
        animePosterUrl: item.animePosterUrl,
        status: status,
        addedAt: item.addedAt,
      );
      _repository.updateWatchlistItem(updatedItem);
      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    }
  }

  void updateItem(WatchlistItem item) {
    _repository.updateWatchlistItem(item);
    state = state.map((i) => i.animeId == item.animeId ? item : i).toList();
  }

  void refresh() {
    state = _repository.getWatchlist();
  }
}

/// Watch progress notifier for player
class WatchProgressNotifier extends StateNotifier<WatchProgress?> {
  final UserRepository _repository;

  WatchProgressNotifier(this._repository) : super(null);

  void loadProgress(int animeId, int episodeId) {
    state = _repository.getWatchProgress(animeId, episodeId);
  }

  void updateProgress(WatchProgress progress) {
    _repository.saveWatchProgress(progress);
    state = progress;
  }
}

/// Watch progress notifier provider (family for different anime/episode combos)
final watchProgressNotifierProvider =
    StateNotifierProvider.family<
      WatchProgressNotifier,
      WatchProgress?,
      ({int animeId, int episodeId})
    >((ref, params) {
      final repository = ref.watch(userRepositoryProvider);
      final notifier = WatchProgressNotifier(repository);
      notifier.loadProgress(params.animeId, params.episodeId);
      return notifier;
    });

// ============ Navigation Providers ============

/// Current bottom nav index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Selected navigation index for main shell
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

/// Player state provider
final isPlayerFullscreenProvider = StateProvider<bool>((ref) => false);

/// Dark mode provider
final darkModeProvider = StateProvider<bool>((ref) => true);

/// Autoplay provider
final autoplayProvider = StateProvider<bool>((ref) => true);

/// Offline mode provider
final offlineModeProvider = StateProvider<bool>((ref) => false);

/// Episodes provider (alias for consistency)
final animeEpisodesProvider = FutureProvider.family<List<Episode>, int>((
  ref,
  animeId,
) async {
  final repository = ref.watch(animeRepositoryProvider);
  return repository.getEpisodes(animeId);
});

/// Watch progress provider (global for player)
final watchProgressProvider =
    StateNotifierProvider<GlobalWatchProgressNotifier, WatchProgress?>((ref) {
      final repository = ref.watch(userRepositoryProvider);
      return GlobalWatchProgressNotifier(repository);
    });

/// Global watch progress notifier
class GlobalWatchProgressNotifier extends StateNotifier<WatchProgress?> {
  final UserRepository _repository;

  GlobalWatchProgressNotifier(this._repository) : super(null);

  void updateProgress(WatchProgress progress) {
    _repository.saveWatchProgress(progress);
    state = progress;
  }

  void clear() {
    state = null;
  }
}
