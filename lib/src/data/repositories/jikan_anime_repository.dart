/// Nylab - Anime Repository (Refactored)
///
/// Uses Jikan API for metadata (matching nyanime.tech website exactly)
/// Uses Aniwatch API for streaming only (via StreamRepository)
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/jikan_api.dart';
import '../api/aniwatch_api.dart';
import '../models/models.dart';

// ============================================================================
// SLUG STORAGE (for Aniwatch ID lookups)
// ============================================================================

/// Stores anime title to Aniwatch slug mappings for streaming lookups
class AniwatchSlugStore {
  static final Map<int, String> _malIdToSlug = {};
  static final Map<String, String> _titleToSlug = {};

  /// Store slug mapping
  static void storeByMalId(int malId, String slug) {
    _malIdToSlug[malId] = slug;
  }

  static void storeByTitle(String title, String slug) {
    _titleToSlug[title.toLowerCase()] = slug;
  }

  /// Get slug by MAL ID
  static String? getByMalId(int malId) => _malIdToSlug[malId];

  /// Get slug by title (normalized)
  static String? getByTitle(String title) => _titleToSlug[title.toLowerCase()];

  /// Clear all mappings
  static void clear() {
    _malIdToSlug.clear();
    _titleToSlug.clear();
  }
}

// ============================================================================
// JIKAN TO ANIME CONVERTER
// ============================================================================

/// Convert Jikan API data to domain Anime model
extension JikanAnimeConverter on JikanAnime {
  Anime toAnime() {
    // Calculate next episode date for airing anime
    DateTime? nextEpisodeAt;
    int? nextEpisodeNumber;

    if (airing == true && broadcast != null) {
      nextEpisodeAt = broadcast!.getNextBroadcast();
      // Estimate next episode number based on aired episodes
      if (episodes != null && status == 'Currently Airing') {
        final startDate = aired?.from != null
            ? DateTime.tryParse(aired!.from!)
            : null;
        if (startDate != null) {
          final weeksSinceStart =
              DateTime.now().difference(startDate).inDays ~/ 7;
          nextEpisodeNumber = (weeksSinceStart + 1).clamp(1, episodes! + 1);
        }
      }
    }

    return Anime(
      id: malId,
      title: titleEnglish ?? title,
      titleJapanese: titleJapanese,
      titleEnglish: titleEnglish ?? title,
      synopsis: synopsis ?? 'No synopsis available.',
      posterUrl: images.jpg.largeImageUrl ?? images.jpg.imageUrl ?? '',
      bannerUrl:
          images.webp?.largeImageUrl ??
          images.jpg.largeImageUrl ??
          images.jpg.imageUrl ??
          '',
      trailerUrl: trailer?.embedUrl ?? trailer?.url,
      score: score ?? 0.0,
      scoredBy: 0,
      rank: rank ?? 0,
      popularity: popularity ?? 0,
      members: members ?? 0,
      favorites: favorites ?? 0,
      status: status ?? 'Unknown',
      type: type ?? (episodes == 1 ? 'Movie' : 'TV'),
      episodeCount: episodes,
      duration: duration,
      rating: rating,
      season: season,
      year: year,
      airedFrom: aired?.from != null ? DateTime.tryParse(aired!.from!) : null,
      airedTo: aired?.to != null ? DateTime.tryParse(aired!.to!) : null,
      nextEpisodeAt: nextEpisodeAt,
      nextEpisodeNumber: nextEpisodeNumber,
      genres: genres.map((g) => g.name).toList(),
      themes: [],
      studios: studios?.map((s) => s.name).toList() ?? [],
      producers: [],
      source: source,
      isAiring: airing ?? (status?.toLowerCase().contains('airing') ?? false),
    );
  }
}

// ============================================================================
// ANIME REPOSITORY INTERFACE
// ============================================================================

abstract class IAnimeRepository {
  Future<List<Anime>> getTrending({int limit, bool forceRefresh});
  Future<List<Anime>> getPopular({int limit, bool forceRefresh});
  Future<List<Anime>> getSeasonal({int limit, bool forceRefresh});
  Future<Anime?> getAnimeById(int malId, {bool forceRefresh});
  Future<List<Anime>> getSimilar(int malId);
  Future<({List<Anime> anime, bool hasNextPage, int totalPages})> searchAnime(
    String query, {
    String? genre,
    String? year,
    String? status,
    int page,
  });
  Future<List<String>> getGenres();
  Future<String?> getAniwatchSlug(int malId, String title);
  void clearCache();
}

// ============================================================================
// JIKAN-BASED ANIME REPOSITORY
// ============================================================================

class JikanAnimeRepository implements IAnimeRepository {
  final JikanApi _jikanApi;
  final AniwatchApi _aniwatchApi;
  late Box<dynamic> _cacheBox;
  bool _isInitialized = false;

  // Cache keys
  static const String _trendingKey = 'jikan_trending';
  static const String _popularKey = 'jikan_popular';
  static const String _seasonalKey = 'jikan_seasonal';
  static const String _genresKey = 'jikan_genres';

  // Cache TTLs
  static const Duration _listCacheTTL = Duration(hours: 1);
  static const Duration _detailCacheTTL = Duration(hours: 24);

  JikanAnimeRepository({JikanApi? jikanApi, AniwatchApi? aniwatchApi})
    : _jikanApi = jikanApi ?? JikanApi(),
      _aniwatchApi = aniwatchApi ?? AniwatchApi();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _cacheBox = await Hive.openBox('jikan_cache');
    _isInitialized = true;
  }

  /// Check if cache is valid
  bool _isCacheValid(String key, Duration ttl) {
    final timestampKey = '${key}_timestamp';
    final timestamp = _cacheBox.get(timestampKey) as int?;
    if (timestamp == null) return false;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateTime.now().difference(cacheTime) < ttl;
  }

  /// Save to cache
  Future<void> _saveToCache(String key, dynamic data) async {
    await _cacheBox.put(key, jsonEncode(data));
    await _cacheBox.put(
      '${key}_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Get from cache
  T? _getFromCache<T>(String key, T Function(dynamic) fromJson) {
    final data = _cacheBox.get(key) as String?;
    if (data == null) return null;
    try {
      return fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Anime>> getTrending({
    int limit = 25,
    bool forceRefresh = false,
  }) async {
    await _ensureInitialized();

    // Check cache
    if (!forceRefresh && _isCacheValid(_trendingKey, _listCacheTTL)) {
      final cached = _getFromCache<List<dynamic>>(
        _trendingKey,
        (d) => d as List,
      );
      if (cached != null) {
        return cached
            .map((e) => Anime.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    // Fetch from API
    final jikanAnime = await _jikanApi.getTrending(limit: limit);
    final anime = jikanAnime.map((j) => j.toAnime()).toList();

    // Cache results
    await _saveToCache(_trendingKey, anime.map((a) => a.toJson()).toList());

    return anime;
  }

  @override
  Future<List<Anime>> getPopular({
    int limit = 25,
    bool forceRefresh = false,
  }) async {
    await _ensureInitialized();

    if (!forceRefresh && _isCacheValid(_popularKey, _listCacheTTL)) {
      final cached = _getFromCache<List<dynamic>>(
        _popularKey,
        (d) => d as List,
      );
      if (cached != null) {
        return cached
            .map((e) => Anime.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final jikanAnime = await _jikanApi.getPopular(limit: limit);
    final anime = jikanAnime.map((j) => j.toAnime()).toList();

    await _saveToCache(_popularKey, anime.map((a) => a.toJson()).toList());

    return anime;
  }

  @override
  Future<List<Anime>> getSeasonal({
    int limit = 25,
    bool forceRefresh = false,
  }) async {
    await _ensureInitialized();

    if (!forceRefresh && _isCacheValid(_seasonalKey, _listCacheTTL)) {
      final cached = _getFromCache<List<dynamic>>(
        _seasonalKey,
        (d) => d as List,
      );
      if (cached != null) {
        return cached
            .map((e) => Anime.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    final jikanAnime = await _jikanApi.getSeasonal(limit: limit);
    final anime = jikanAnime.map((j) => j.toAnime()).toList();

    await _saveToCache(_seasonalKey, anime.map((a) => a.toJson()).toList());

    return anime;
  }

  @override
  Future<Anime?> getAnimeById(int malId, {bool forceRefresh = false}) async {
    await _ensureInitialized();

    final key = 'anime_$malId';
    if (!forceRefresh && _isCacheValid(key, _detailCacheTTL)) {
      final cached = _getFromCache<Map<String, dynamic>>(
        key,
        (d) => d as Map<String, dynamic>,
      );
      if (cached != null) {
        return Anime.fromJson(cached);
      }
    }

    final jikanAnime = await _jikanApi.getAnimeById(malId);
    if (jikanAnime == null) return null;

    final anime = jikanAnime.toAnime();

    await _saveToCache(key, anime.toJson());

    return anime;
  }

  @override
  Future<List<Anime>> getSimilar(int malId) async {
    final jikanAnime = await _jikanApi.getSimilarAnime(malId);
    return jikanAnime.map((j) => j.toAnime()).toList();
  }

  @override
  Future<({List<Anime> anime, bool hasNextPage, int totalPages})> searchAnime(
    String query, {
    String? genre,
    String? year,
    String? status,
    int page = 1,
  }) async {
    final result = await _jikanApi.searchAnime(
      query,
      genre: genre,
      year: year,
      status: status,
      page: page,
    );

    final anime = result.anime.map((j) => j.toAnime()).toList();

    return (
      anime: anime,
      hasNextPage: result.pagination.hasNextPage,
      totalPages: result.pagination.lastVisiblePage,
    );
  }

  @override
  Future<List<String>> getGenres() async {
    await _ensureInitialized();

    if (_isCacheValid(_genresKey, _detailCacheTTL)) {
      final cached = _getFromCache<List<dynamic>>(_genresKey, (d) => d as List);
      if (cached != null) {
        return cached.cast<String>();
      }
    }

    final genres = await _jikanApi.getGenres();

    await _saveToCache(_genresKey, genres);

    return genres;
  }

  /// Get Aniwatch slug for streaming by searching title on Aniwatch API
  @override
  Future<String?> getAniwatchSlug(int malId, String title) async {
    // Check cache first
    final cached = AniwatchSlugStore.getByMalId(malId);
    if (cached != null) return cached;

    // Search on Aniwatch
    try {
      final results = await _aniwatchApi.searchAnime(title);
      if (results.isEmpty) return null;

      // Use best match algorithm (same as nyanime website)
      final bestMatch = _findBestMatch(results, title);
      if (bestMatch != null) {
        AniwatchSlugStore.storeByMalId(malId, bestMatch.id);
        AniwatchSlugStore.storeByTitle(title, bestMatch.id);
        return bestMatch.id;
      }

      // Fallback to first result
      final slug = results.first.id;
      AniwatchSlugStore.storeByMalId(malId, slug);
      AniwatchSlugStore.storeByTitle(title, slug);
      return slug;
    } catch (e) {
      print('[JikanAnimeRepository] getAniwatchSlug error: $e');
      return null;
    }
  }

  /// Find best match from search results (simplified version of nyanime website algorithm)
  AniwatchSearchResult? _findBestMatch(
    List<AniwatchSearchResult> results,
    String targetTitle,
  ) {
    if (results.isEmpty) return null;
    if (results.length == 1) return results.first;

    final targetNormalized = _normalize(targetTitle);
    final targetWords = _getWords(targetTitle);

    int bestScore = 0;
    AniwatchSearchResult? bestMatch;

    for (final result in results) {
      int score = 0;
      final resultNormalized = _normalize(result.name);
      final resultWords = _getWords(result.name);

      // Exact match bonus
      if (resultNormalized == targetNormalized) {
        score += 1000;
      }

      // Word matching
      final matchingWords = targetWords
          .where((w) => resultWords.contains(w))
          .length;
      final wordMatchRatio = matchingWords / targetWords.length;
      score += (wordMatchRatio * 400).toInt();

      // Episode count bonus (prefer series with more episodes)
      final episodeCount = result.subEpisodes > 0
          ? result.subEpisodes
          : result.dubEpisodes;
      score += (episodeCount.clamp(0, 50) * 2);

      if (score > bestScore) {
        bestScore = score;
        bestMatch = result;
      }
    }

    return bestMatch ?? results.first;
  }

  String _normalize(String str) {
    return str
        .toLowerCase()
        .replaceAll(RegExp(r'[-_:]'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _getWords(String str) {
    return _normalize(str).split(' ').where((w) => w.isNotEmpty).toList();
  }

  @override
  void clearCache() {
    if (_isInitialized) {
      _cacheBox.clear();
    }
    AniwatchSlugStore.clear();
  }
}

// ============================================================================
// SINGLETON INSTANCE
// ============================================================================

final animeRepository = JikanAnimeRepository(
  jikanApi: jikanApi,
  aniwatchApi: aniwatchApi,
);
