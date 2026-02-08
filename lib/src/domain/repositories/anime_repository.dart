/// Nylab - Anime Repository (Domain Layer)
///
/// Uses Jikan API for metadata (matching nyanime.tech exactly)
/// Uses Aniwatch API via StreamRepository for streaming only
library;

import '../../data/data.dart';
import '../../data/repositories/jikan_anime_repository.dart' as jikan_impl;
import '../../data/repositories/anime_repository.dart' as aniwatch_impl;

class AnimeRepository {
  // ignore: unused_field
  final ApiClient? _apiClient;
  // ignore: unused_field
  final LocalStorage? _localStorage;
  final jikan_impl.JikanAnimeRepository _jikanRepo;
  final aniwatch_impl.AniwatchAnimeRepository _aniwatchRepo;

  AnimeRepository({
    ApiClient? apiClient,
    LocalStorage? localStorage,
    jikan_impl.JikanAnimeRepository? jikanRepo,
    aniwatch_impl.AniwatchAnimeRepository? aniwatchRepo,
  }) : _apiClient = apiClient,
       _localStorage = localStorage,
       _jikanRepo = jikanRepo ?? jikan_impl.animeRepository,
       _aniwatchRepo = aniwatchRepo ?? aniwatch_impl.animeRepository;

  // ============ METADATA (Jikan API - matching nyanime website) ============

  /// Get trending anime (currently airing, top rated)
  /// Matches: /top/anime?filter=airing in nyanime website
  Future<List<Anime>> getTrendingAnime({bool forceRefresh = false}) async {
    return _jikanRepo.getTrending(limit: 25, forceRefresh: forceRefresh);
  }

  /// Get seasonal anime (current season)
  /// Matches: /seasons/now in nyanime website
  Future<List<Anime>> getSeasonalAnime({
    String? season,
    int? year,
    bool forceRefresh = false,
  }) async {
    return _jikanRepo.getSeasonal(limit: 25, forceRefresh: forceRefresh);
  }

  /// Get anime by MAL ID (Jikan API)
  Future<Anime?> getAnimeById(int id, {bool forceRefresh = false}) async {
    return _jikanRepo.getAnimeById(id, forceRefresh: forceRefresh);
  }

  /// Get anime by slug (uses Aniwatch for backward compatibility)
  Future<Anime?> getAnimeBySlug(
    String slug, {
    bool forceRefresh = false,
  }) async {
    return _aniwatchRepo.getAnimeDetail(slug);
  }

  /// Get episodes for an anime by MAL ID
  /// Maps to Aniwatch slug for episode fetching
  Future<List<Episode>> getEpisodes(
    int animeId, {
    bool forceRefresh = false,
  }) async {
    // First try to get anime details to get title for slug lookup
    final anime = await _jikanRepo.getAnimeById(animeId);
    if (anime != null) {
      final slug = await _jikanRepo.getAniwatchSlug(animeId, anime.title);
      if (slug != null) {
        return _aniwatchRepo.getEpisodes(slug);
      }
    }
    return [];
  }

  /// Get episodes by slug (uses Aniwatch directly)
  Future<List<Episode>> getEpisodesBySlug(
    String slug, {
    bool forceRefresh = false,
  }) async {
    return _aniwatchRepo.getEpisodes(slug);
  }

  /// Get episode stream URL - now handled by StreamRepository
  Future<String?> getEpisodeStreamUrl(int animeId, int episodeId) async {
    return null;
  }

  /// Search anime with filters (Jikan API)
  /// Matches: /anime?q={query} in nyanime website
  Future<List<Anime>> searchAnime(
    String query, {
    List<String>? genres,
    String? type,
    String? status,
  }) async {
    final genre = genres?.isNotEmpty == true ? genres!.first : null;
    final result = await _jikanRepo.searchAnime(
      query,
      genre: genre,
      status: status,
    );
    return result.anime;
  }

  /// Search with pagination (Jikan API)
  Future<({List<Anime> anime, bool hasNextPage, int totalPages})>
  searchAnimePaginated(
    String query, {
    String? genre,
    String? year,
    String? status,
    int page = 1,
  }) async {
    return _jikanRepo.searchAnime(
      query,
      genre: genre,
      year: year,
      status: status,
      page: page,
    );
  }

  /// Get top airing anime (alias for trending)
  Future<List<Anime>> getTopAiring() async {
    return getTrendingAnime();
  }

  /// Get most popular anime (Jikan API)
  Future<List<Anime>> getMostPopular() async {
    return _jikanRepo.getPopular(limit: 25);
  }

  /// Get latest episode releases (returns seasonal as proxy)
  Future<List<Anime>> getLatestEpisodes() async {
    return getSeasonalAnime();
  }

  /// Get similar anime (recommendations from Jikan)
  Future<List<Anime>> getSimilarAnime(int malId) async {
    return _jikanRepo.getSimilar(malId);
  }

  /// Get all genres (Jikan API)
  Future<List<String>> getGenres() async {
    return _jikanRepo.getGenres();
  }

  /// Get Aniwatch slug for streaming
  Future<String?> getAniwatchSlug(int malId, String title) async {
    return _jikanRepo.getAniwatchSlug(malId, title);
  }

  /// Get slug from anime ID (backward compat - uses both)
  String? getSlug(int animeId) {
    // Check Aniwatch cache first
    final aniwatchSlug = _aniwatchRepo.getSlug(animeId);
    if (aniwatchSlug != null) return aniwatchSlug;
    // Otherwise return null - caller should use getAniwatchSlug()
    return null;
  }

  /// Clear all caches
  void clearCache() {
    _jikanRepo.clearCache();
    _aniwatchRepo.clearCache();
  }
}
