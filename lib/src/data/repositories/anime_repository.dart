/// Nylab - Anime Repository
///
/// Repository layer for anime data with caching support
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../api/aniwatch_api.dart';
import '../models/models.dart';

/// Simple anime data class for Aniwatch data
class AniwatchAnime {
  final String slug;
  final String title;
  final String? titleJapanese;
  final String? synopsis;
  final String posterUrl;
  final String? type;
  final String? status;
  final double score;
  final int episodeCount;
  final List<String> genres;
  final List<String> studios;
  final int? year;
  final String? season;
  final String? rating;
  final String? duration;
  final int rank;
  final int popularity;

  AniwatchAnime({
    required this.slug,
    required this.title,
    this.titleJapanese,
    this.synopsis,
    required this.posterUrl,
    this.type,
    this.status,
    this.score = 0.0,
    this.episodeCount = 0,
    this.genres = const [],
    this.studios = const [],
    this.year,
    this.season,
    this.rating,
    this.duration,
    this.rank = 0,
    this.popularity = 0,
  });

  /// Convert to domain Anime
  Anime toAnime() {
    return Anime(
      id: slug.hashCode,
      title: title,
      titleJapanese: titleJapanese,
      titleEnglish: title,
      synopsis: synopsis ?? 'No synopsis available.',
      posterUrl: posterUrl,
      bannerUrl: posterUrl,
      trailerUrl: null,
      score: score,
      scoredBy: 0,
      rank: rank,
      popularity: popularity,
      members: 0,
      favorites: 0,
      status: status ?? 'Airing',
      type: type ?? 'TV',
      episodeCount: episodeCount > 0 ? episodeCount : null,
      duration: duration,
      rating: rating,
      season: season,
      year: year,
      airedFrom: null,
      airedTo: null,
      nextEpisodeAt: null,
      nextEpisodeNumber: null,
      genres: genres,
      themes: [],
      studios: studios,
      producers: [],
      source: null,
      isAiring: status?.toLowerCase().contains('airing') ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'title': title,
    'titleJapanese': titleJapanese,
    'synopsis': synopsis,
    'posterUrl': posterUrl,
    'type': type,
    'status': status,
    'score': score,
    'episodeCount': episodeCount,
    'genres': genres,
    'studios': studios,
    'year': year,
    'season': season,
    'rating': rating,
    'duration': duration,
    'rank': rank,
    'popularity': popularity,
  };

  factory AniwatchAnime.fromJson(Map<String, dynamic> json) {
    return AniwatchAnime(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleJapanese: json['titleJapanese'] as String?,
      synopsis: json['synopsis'] as String?,
      posterUrl: json['posterUrl'] as String? ?? '',
      type: json['type'] as String?,
      status: json['status'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      episodeCount: json['episodeCount'] as int? ?? 0,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? [],
      studios: (json['studios'] as List<dynamic>?)?.cast<String>() ?? [],
      year: json['year'] as int?,
      season: json['season'] as String?,
      rating: json['rating'] as String?,
      duration: json['duration'] as String?,
      rank: json['rank'] as int? ?? 0,
      popularity: json['popularity'] as int? ?? 0,
    );
  }
}

/// Simple episode data class
class AniwatchEpisodeData {
  final int number;
  final String title;
  final String episodeId;
  final bool isFiller;

  AniwatchEpisodeData({
    required this.number,
    required this.title,
    required this.episodeId,
    this.isFiller = false,
  });

  /// Convert to domain Episode
  Episode toEpisode(String animeSlug) {
    return Episode(
      id: number,
      animeId: animeSlug.hashCode,
      number: number,
      title: title.isNotEmpty ? title : 'Episode $number',
      titleJapanese: null,
      synopsis: null,
      thumbnailUrl: '',
      streamUrl: null,
      duration: const Duration(minutes: 24),
      airedAt: null,
      isFiller: isFiller,
      isRecap: false,
      score: 0.0,
    );
  }
}

/// Slug storage for reverse lookup
class SlugStore {
  static final Map<int, String> _slugs = {};

  static void store(int id, String slug) {
    _slugs[id] = slug;
  }

  static String? get(int id) => _slugs[id];

  static void clear() => _slugs.clear();
}

/// Abstract anime repository interface
abstract class IAnimeRepository {
  Future<List<Anime>> getTrending();
  Future<List<Anime>> getSeasonal();
  Future<List<Anime>> getTopAiring();
  Future<List<Anime>> getMostPopular();
  Future<List<Anime>> getLatestEpisodes();
  Future<Anime?> getAnimeDetail(String slug);
  Future<List<Episode>> getEpisodes(String slug);
  Future<List<Anime>> searchAnime(String query, {int page});
  String? getSlug(int animeId);
  void clearCache();
}

/// Aniwatch-backed anime repository with JSON cache
class AniwatchAnimeRepository implements IAnimeRepository {
  final AniwatchApi _api;
  late Box<dynamic> _cacheBox;
  bool _isInitialized = false;

  // Cache TTLs
  static const Duration _listCacheTTL = Duration(hours: 1);
  static const Duration _detailCacheTTL = Duration(hours: 24);

  AniwatchAnimeRepository({AniwatchApi? api}) : _api = api ?? aniwatchApi;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    _cacheBox = await Hive.openBox('aniwatch_cache');
    _isInitialized = true;
  }

  /// Convert Aniwatch search result to AniwatchAnime
  AniwatchAnime _convertSearchResult(AniwatchSearchResult result) {
    final anime = AniwatchAnime(
      slug: result.id,
      title: result.name,
      posterUrl: result.poster ?? '',
      type: result.type,
      score: double.tryParse(result.rating ?? '0') ?? 0.0,
      episodeCount: result.subEpisodes > 0
          ? result.subEpisodes
          : result.dubEpisodes,
      rating: result.rating,
      duration: result.duration,
    );
    SlugStore.store(result.id.hashCode, result.id);
    return anime;
  }

  /// Convert Aniwatch spotlight to AniwatchAnime
  AniwatchAnime _convertSpotlight(AniwatchSpotlight spotlight) {
    final anime = AniwatchAnime(
      slug: spotlight.id,
      title: spotlight.name,
      titleJapanese: spotlight.jname,
      synopsis: spotlight.description,
      posterUrl: spotlight.poster ?? '',
      type: spotlight.type,
      episodeCount: spotlight.subEpisodes > 0
          ? spotlight.subEpisodes
          : spotlight.dubEpisodes,
      rank: spotlight.rank,
      popularity: spotlight.rank,
    );
    SlugStore.store(spotlight.id.hashCode, spotlight.id);
    return anime;
  }

  /// Convert Aniwatch anime info to AniwatchAnime
  AniwatchAnime _convertAnimeInfo(AniwatchAnimeInfo info) {
    final animeData = info.anime;
    final animeInfo = animeData.info;
    final moreInfo = animeData.moreInfo;
    final stats = animeInfo.stats;

    final anime = AniwatchAnime(
      slug: animeInfo.id,
      title: animeInfo.name,
      titleJapanese: moreInfo.japanese,
      synopsis: animeInfo.description,
      posterUrl: animeInfo.poster ?? '',
      type: stats?.type,
      status: moreInfo.status,
      score: double.tryParse(moreInfo.malScore ?? '0') ?? 0.0,
      episodeCount: stats?.subEpisodes ?? stats?.dubEpisodes ?? 0,
      genres: moreInfo.genres,
      studios: moreInfo.studios,
      year: _parseYear(moreInfo.aired),
      season: _parseSeason(moreInfo.premiered),
      rating: stats?.rating,
      duration: moreInfo.duration ?? stats?.duration,
    );
    SlugStore.store(animeInfo.id.hashCode, animeInfo.id);
    return anime;
  }

  int _parseYear(String? aired) {
    if (aired == null) return DateTime.now().year;
    final match = RegExp(r'\d{4}').firstMatch(aired);
    return match != null ? int.parse(match.group(0)!) : DateTime.now().year;
  }

  String _parseSeason(String? premiered) {
    if (premiered == null) return 'current';
    final lower = premiered.toLowerCase();
    if (lower.contains('winter')) return 'winter';
    if (lower.contains('spring')) return 'spring';
    if (lower.contains('summer')) return 'summer';
    if (lower.contains('fall')) return 'fall';
    return 'current';
  }

  @override
  Future<List<Anime>> getTrending() async {
    await _ensureInitialized();

    final cacheKey = 'trending';
    final cached = _getCachedAnimeList(cacheKey, _listCacheTTL);
    if (cached != null) return cached;

    final homeData = await _api.getHome();
    if (homeData != null) {
      final animes = homeData.trendingAnimes.map(_convertSearchResult).toList();
      _cacheAnimeList(cacheKey, animes);
      return animes.map((a) => a.toAnime()).toList();
    }
    return [];
  }

  @override
  Future<List<Anime>> getSeasonal() async {
    await _ensureInitialized();

    final cacheKey = 'seasonal';
    final cached = _getCachedAnimeList(cacheKey, _listCacheTTL);
    if (cached != null) return cached;

    final homeData = await _api.getHome();
    if (homeData != null) {
      final animes = [
        ...homeData.spotlightAnimes.map(_convertSpotlight),
        ...homeData.latestEpisodeAnimes.take(10).map(_convertSearchResult),
      ];
      _cacheAnimeList(cacheKey, animes);
      return animes.map((a) => a.toAnime()).toList();
    }
    return [];
  }

  @override
  Future<List<Anime>> getTopAiring() async {
    await _ensureInitialized();

    final cacheKey = 'topAiring';
    final cached = _getCachedAnimeList(cacheKey, _listCacheTTL);
    if (cached != null) return cached;

    final homeData = await _api.getHome();
    if (homeData != null) {
      final animes = homeData.topAiringAnimes
          .map(_convertSearchResult)
          .toList();
      _cacheAnimeList(cacheKey, animes);
      return animes.map((a) => a.toAnime()).toList();
    }
    return [];
  }

  @override
  Future<List<Anime>> getMostPopular() async {
    await _ensureInitialized();

    final cacheKey = 'mostPopular';
    final cached = _getCachedAnimeList(cacheKey, _listCacheTTL);
    if (cached != null) return cached;

    final homeData = await _api.getHome();
    if (homeData != null) {
      final animes = homeData.mostPopularAnimes
          .map(_convertSearchResult)
          .toList();
      _cacheAnimeList(cacheKey, animes);
      return animes.map((a) => a.toAnime()).toList();
    }
    return [];
  }

  @override
  Future<List<Anime>> getLatestEpisodes() async {
    await _ensureInitialized();

    final cacheKey = 'latestEpisodes';
    final cached = _getCachedAnimeList(cacheKey, _listCacheTTL);
    if (cached != null) return cached;

    final homeData = await _api.getHome();
    if (homeData != null) {
      final animes = homeData.latestEpisodeAnimes
          .map(_convertSearchResult)
          .toList();
      _cacheAnimeList(cacheKey, animes);
      return animes.map((a) => a.toAnime()).toList();
    }
    return [];
  }

  @override
  Future<Anime?> getAnimeDetail(String slug) async {
    await _ensureInitialized();

    final cacheKey = 'detail:$slug';
    final cached = _getCachedAnime(cacheKey, _detailCacheTTL);
    if (cached != null) return cached;

    final info = await _api.getAnimeInfo(slug);
    if (info != null) {
      final anime = _convertAnimeInfo(info);
      _cacheAnime(cacheKey, anime);
      return anime.toAnime();
    }
    return null;
  }

  @override
  Future<List<Episode>> getEpisodes(String slug) async {
    await _ensureInitialized();

    final episodes = await _api.getEpisodes(slug);
    return episodes
        .map(
          (e) => AniwatchEpisodeData(
            number: e.number,
            title: e.title,
            episodeId: e.episodeId,
            isFiller: e.isFiller,
          ).toEpisode(slug),
        )
        .toList();
  }

  @override
  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    await _ensureInitialized();

    final results = await _api.searchAnime(query, page: page);
    return results.map(_convertSearchResult).map((a) => a.toAnime()).toList();
  }

  @override
  String? getSlug(int animeId) => SlugStore.get(animeId);

  // Cache helpers using JSON strings
  List<Anime>? _getCachedAnimeList(String key, Duration ttl) {
    try {
      final timestampStr = _cacheBox.get('${key}_timestamp') as String?;
      if (timestampStr == null) return null;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return null;

      if (DateTime.now().difference(timestamp) > ttl) {
        return null;
      }

      final dataJson = _cacheBox.get('${key}_data') as String?;
      if (dataJson == null) return null;

      final dataList = jsonDecode(dataJson) as List;
      return dataList
          .map((e) => AniwatchAnime.fromJson(e as Map<String, dynamic>))
          .map((a) {
            SlugStore.store(a.slug.hashCode, a.slug);
            return a.toAnime();
          })
          .toList();
    } catch (e) {
      return null;
    }
  }

  void _cacheAnimeList(String key, List<AniwatchAnime> data) {
    try {
      _cacheBox.put('${key}_timestamp', DateTime.now().toIso8601String());
      _cacheBox.put(
        '${key}_data',
        jsonEncode(data.map((a) => a.toJson()).toList()),
      );
    } catch (e) {
      print('[AnimeRepository] Cache list error: $e');
    }
  }

  Anime? _getCachedAnime(String key, Duration ttl) {
    try {
      final timestampStr = _cacheBox.get('${key}_timestamp') as String?;
      if (timestampStr == null) return null;

      final timestamp = DateTime.tryParse(timestampStr);
      if (timestamp == null) return null;

      if (DateTime.now().difference(timestamp) > ttl) {
        return null;
      }

      final dataJson = _cacheBox.get('${key}_data') as String?;
      if (dataJson == null) return null;

      final anime = AniwatchAnime.fromJson(
        jsonDecode(dataJson) as Map<String, dynamic>,
      );
      SlugStore.store(anime.slug.hashCode, anime.slug);
      return anime.toAnime();
    } catch (e) {
      return null;
    }
  }

  void _cacheAnime(String key, AniwatchAnime anime) {
    try {
      _cacheBox.put('${key}_timestamp', DateTime.now().toIso8601String());
      _cacheBox.put('${key}_data', jsonEncode(anime.toJson()));
    } catch (e) {
      print('[AnimeRepository] Cache anime error: $e');
    }
  }

  @override
  void clearCache() {
    _cacheBox.clear();
    SlugStore.clear();
    _api.clearCache();
  }
}

/// Singleton instance
final animeRepository = AniwatchAnimeRepository();
