/// Nylab - Anime Repository (Domain Layer - Refactored)
///
/// Uses Jikan API for metadata (matching nyanime.tech exactly)
/// Uses Aniwatch API for streaming only via StreamRepository
library;

import '../../data/data.dart';
import '../../data/repositories/jikan_anime_repository.dart' as impl;

/// Domain-level anime repository wrapping the Jikan-based implementation
class AnimeRepository {
  final impl.JikanAnimeRepository _repo;

  AnimeRepository({impl.JikanAnimeRepository? repo})
    : _repo = repo ?? impl.animeRepository;

  // ============ METADATA ENDPOINTS (Jikan API - matching nyanime website) ============

  /// Get trending anime (currently airing, top rated)
  /// Matches: /top/anime?filter=airing in nyanime website
  Future<List<Anime>> getTrendingAnime({
    int limit = 25,
    bool forceRefresh = false,
  }) async {
    return _repo.getTrending(limit: limit, forceRefresh: forceRefresh);
  }

  /// Get popular anime (by popularity)
  /// Matches: /top/anime?filter=bypopularity in nyanime website
  Future<List<Anime>> getPopularAnime({
    int limit = 25,
    bool forceRefresh = false,
  }) async {
    return _repo.getPopular(limit: limit, forceRefresh: forceRefresh);
  }

  /// Get seasonal anime (current season)
  /// Matches: /seasons/now in nyanime website
  Future<List<Anime>> getSeasonalAnime({
    int limit = 25,
    bool forceRefresh = false,
  }) async {
    return _repo.getSeasonal(limit: limit, forceRefresh: forceRefresh);
  }

  /// Get anime by MAL ID
  /// Matches: /anime/{id} in nyanime website
  Future<Anime?> getAnimeById(int malId, {bool forceRefresh = false}) async {
    return _repo.getAnimeById(malId, forceRefresh: forceRefresh);
  }

  /// Get similar anime (recommendations)
  /// Matches: /anime/{id}/recommendations in nyanime website
  Future<List<Anime>> getSimilarAnime(int malId) async {
    return _repo.getSimilar(malId);
  }

  /// Search anime with filters
  /// Matches: /anime?q={query}&page={page} in nyanime website
  Future<({List<Anime> anime, bool hasNextPage, int totalPages})> searchAnime(
    String query, {
    String? genre,
    String? year,
    String? status,
    int page = 1,
  }) async {
    return _repo.searchAnime(
      query,
      genre: genre,
      year: year,
      status: status,
      page: page,
    );
  }

  /// Simple search (returns just anime list)
  Future<List<Anime>> searchAnimeSimple(String query) async {
    final result = await searchAnime(query);
    return result.anime;
  }

  /// Get genres list
  Future<List<String>> getGenres() async {
    return _repo.getGenres();
  }

  // ============ STREAMING HELPERS (for Aniwatch lookups) ============

  /// Get Aniwatch slug for streaming
  /// Used to find the anime on Aniwatch for episode/stream lookups
  Future<String?> getAniwatchSlug(int malId, String title) async {
    return _repo.getAniwatchSlug(malId, title);
  }

  // ============ LEGACY METHODS (for backward compatibility) ============

  /// Get top airing (alias for trending)
  Future<List<Anime>> getTopAiring({bool forceRefresh = false}) async {
    return getTrendingAnime(forceRefresh: forceRefresh);
  }

  /// Get most popular (alias for popular)
  Future<List<Anime>> getMostPopular({bool forceRefresh = false}) async {
    return getPopularAnime(forceRefresh: forceRefresh);
  }

  /// Get latest episodes (returns seasonal as proxy)
  Future<List<Anime>> getLatestEpisodes({bool forceRefresh = false}) async {
    return getSeasonalAnime(forceRefresh: forceRefresh);
  }

  /// Clear all caches
  void clearCache() {
    _repo.clearCache();
  }
}

/// Singleton instance
final animeRepository = AnimeRepository();
