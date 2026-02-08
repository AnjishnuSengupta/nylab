/// Nylab - Jikan API Service
///
/// Integration with Jikan API (MyAnimeList unofficial API)
/// Matches the exact structure used by nyanime.tech website
/// API Documentation: https://docs.api.jikan.moe/
library;

import 'package:dio/dio.dart';

// ============================================================================
// TYPES & INTERFACES (matching nyanime website exactly)
// ============================================================================

/// Jikan anime response from API
class JikanAnime {
  final int malId;
  final String title;
  final String? titleEnglish;
  final String? titleJapanese;
  final JikanImages images;
  final String? synopsis;
  final String? status;
  final List<JikanGenre> genres;
  final List<JikanStudio>? studios;
  final double? score;
  final int? year;
  final int? episodes;
  final JikanAired? aired;
  final JikanTrailer? trailer;
  final String? duration;
  final String? rating;
  final String? type;
  final int? rank;
  final int? popularity;
  final int? members;
  final int? favorites;
  final String? source;
  final bool? airing;
  final String? season;
  final JikanBroadcast? broadcast;

  JikanAnime({
    required this.malId,
    required this.title,
    this.titleEnglish,
    this.titleJapanese,
    required this.images,
    this.synopsis,
    this.status,
    this.genres = const [],
    this.studios,
    this.score,
    this.year,
    this.episodes,
    this.aired,
    this.trailer,
    this.duration,
    this.rating,
    this.type,
    this.rank,
    this.popularity,
    this.members,
    this.favorites,
    this.source,
    this.airing,
    this.season,
    this.broadcast,
  });

  factory JikanAnime.fromJson(Map<String, dynamic> json) {
    return JikanAnime(
      malId: json['mal_id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      titleEnglish: json['title_english'] as String?,
      titleJapanese: json['title_japanese'] as String?,
      images: JikanImages.fromJson(
        json['images'] as Map<String, dynamic>? ?? {},
      ),
      synopsis: json['synopsis'] as String?,
      status: json['status'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((g) => JikanGenre.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [],
      studios: (json['studios'] as List<dynamic>?)
          ?.map((s) => JikanStudio.fromJson(s as Map<String, dynamic>))
          .toList(),
      score: (json['score'] as num?)?.toDouble(),
      year: json['year'] as int?,
      episodes: json['episodes'] as int?,
      aired: json['aired'] != null
          ? JikanAired.fromJson(json['aired'] as Map<String, dynamic>)
          : null,
      trailer: json['trailer'] != null
          ? JikanTrailer.fromJson(json['trailer'] as Map<String, dynamic>)
          : null,
      duration: json['duration'] as String?,
      rating: json['rating'] as String?,
      type: json['type'] as String?,
      rank: json['rank'] as int?,
      popularity: json['popularity'] as int?,
      members: json['members'] as int?,
      favorites: json['favorites'] as int?,
      source: json['source'] as String?,
      airing: json['airing'] as bool?,
      season: json['season'] as String?,
      broadcast: json['broadcast'] != null
          ? JikanBroadcast.fromJson(json['broadcast'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JikanImages {
  final JikanImageFormat jpg;
  final JikanImageFormat? webp;

  JikanImages({required this.jpg, this.webp});

  factory JikanImages.fromJson(Map<String, dynamic> json) {
    return JikanImages(
      jpg: JikanImageFormat.fromJson(
        json['jpg'] as Map<String, dynamic>? ?? {},
      ),
      webp: json['webp'] != null
          ? JikanImageFormat.fromJson(json['webp'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JikanImageFormat {
  final String? imageUrl;
  final String? smallImageUrl;
  final String? largeImageUrl;

  JikanImageFormat({this.imageUrl, this.smallImageUrl, this.largeImageUrl});

  factory JikanImageFormat.fromJson(Map<String, dynamic> json) {
    return JikanImageFormat(
      imageUrl: json['image_url'] as String?,
      smallImageUrl: json['small_image_url'] as String?,
      largeImageUrl: json['large_image_url'] as String?,
    );
  }
}

class JikanGenre {
  final int malId;
  final String name;
  final String? type;

  JikanGenre({required this.malId, required this.name, this.type});

  factory JikanGenre.fromJson(Map<String, dynamic> json) {
    return JikanGenre(
      malId: json['mal_id'] as int,
      name: json['name'] as String,
      type: json['type'] as String?,
    );
  }
}

class JikanStudio {
  final int malId;
  final String name;

  JikanStudio({required this.malId, required this.name});

  factory JikanStudio.fromJson(Map<String, dynamic> json) {
    return JikanStudio(
      malId: json['mal_id'] as int,
      name: json['name'] as String,
    );
  }
}

class JikanAired {
  final String? from;
  final String? to;

  JikanAired({this.from, this.to});

  factory JikanAired.fromJson(Map<String, dynamic> json) {
    return JikanAired(from: json['from'] as String?, to: json['to'] as String?);
  }
}

class JikanTrailer {
  final String? youtubeId;
  final String? url;
  final String? embedUrl;

  JikanTrailer({this.youtubeId, this.url, this.embedUrl});

  factory JikanTrailer.fromJson(Map<String, dynamic> json) {
    return JikanTrailer(
      youtubeId: json['youtube_id'] as String?,
      url: json['url'] as String?,
      embedUrl: json['embed_url'] as String?,
    );
  }
}

class JikanBroadcast {
  final String? day;
  final String? time;
  final String? timezone;
  final String? string;

  JikanBroadcast({this.day, this.time, this.timezone, this.string});

  factory JikanBroadcast.fromJson(Map<String, dynamic> json) {
    return JikanBroadcast(
      day: json['day'] as String?,
      time: json['time'] as String?,
      timezone: json['timezone'] as String?,
      string: json['string'] as String?,
    );
  }

  /// Calculate next broadcast datetime
  DateTime? getNextBroadcast() {
    if (day == null || time == null) return null;

    try {
      final dayMap = {
        'Mondays': DateTime.monday,
        'Tuesdays': DateTime.tuesday,
        'Wednesdays': DateTime.wednesday,
        'Thursdays': DateTime.thursday,
        'Fridays': DateTime.friday,
        'Saturdays': DateTime.saturday,
        'Sundays': DateTime.sunday,
      };

      final targetDay = dayMap[day];
      if (targetDay == null) return null;

      // Parse time (format: "HH:MM")
      final timeParts = time!.split(':');
      if (timeParts.length != 2) return null;

      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;

      // Get current time in JST (Japan Standard Time, UTC+9)
      final now = DateTime.now().toUtc().add(const Duration(hours: 9));
      var nextBroadcast = DateTime.utc(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Find the next occurrence of the target day
      final daysUntil = (targetDay - now.weekday + 7) % 7;
      nextBroadcast = nextBroadcast.add(Duration(days: daysUntil));

      // If it's today but already passed, get next week
      if (daysUntil == 0 && nextBroadcast.isBefore(now)) {
        nextBroadcast = nextBroadcast.add(const Duration(days: 7));
      }

      // Convert back from JST to UTC
      return nextBroadcast.subtract(const Duration(hours: 9));
    } catch (e) {
      return null;
    }
  }
}

class JikanPagination {
  final int lastVisiblePage;
  final bool hasNextPage;
  final int currentPage;
  final JikanPaginationItems? items;

  JikanPagination({
    required this.lastVisiblePage,
    required this.hasNextPage,
    required this.currentPage,
    this.items,
  });

  factory JikanPagination.fromJson(Map<String, dynamic> json) {
    return JikanPagination(
      lastVisiblePage: json['last_visible_page'] as int? ?? 1,
      hasNextPage: json['has_next_page'] as bool? ?? false,
      currentPage: json['current_page'] as int? ?? 1,
      items: json['items'] != null
          ? JikanPaginationItems.fromJson(json['items'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JikanPaginationItems {
  final int count;
  final int total;
  final int perPage;

  JikanPaginationItems({
    required this.count,
    required this.total,
    required this.perPage,
  });

  factory JikanPaginationItems.fromJson(Map<String, dynamic> json) {
    return JikanPaginationItems(
      count: json['count'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 25,
    );
  }
}

/// Genre ID mapping (same as nyanime website)
const genreIdMap = <String, int>{
  'action': 1,
  'adventure': 2,
  'comedy': 4,
  'drama': 8,
  'fantasy': 10,
  'horror': 14,
  'mystery': 7,
  'romance': 22,
  'sci-fi': 24,
  'slice of life': 36,
  'sports': 30,
  'supernatural': 37,
  'suspense': 41,
  'ecchi': 9,
  'mecha': 18,
  'music': 19,
  'psychological': 40,
  'school': 23,
  'shounen': 27,
  'shoujo': 25,
  'seinen': 42,
  'isekai': 62,
  'military': 38,
  'historical': 13,
  'martial arts': 17,
  'space': 29,
  'vampire': 32,
  'harem': 35,
  'parody': 20,
  'samurai': 21,
  'super power': 31,
};

// ============================================================================
// JIKAN API SERVICE (matching nyanime website exactly)
// ============================================================================

class JikanApi {
  static const String _baseUrl = 'https://api.jikan.moe/v4';
  static const int _maxLimit = 25; // Same as nyanime website
  static const int _rateLimitDelay = 1000; // 1 second between requests

  final Dio _dio;
  DateTime _lastRequestTime = DateTime.fromMillisecondsSinceEpoch(0);

  // In-memory cache
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  JikanApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'Nylab-Mobile/1.0',
              },
            ),
          );

  /// Rate limit helper
  Future<void> _respectRateLimit() async {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRequestTime).inMilliseconds;
    if (elapsed < _rateLimitDelay) {
      await Future.delayed(Duration(milliseconds: _rateLimitDelay - elapsed));
    }
    _lastRequestTime = DateTime.now();
  }

  /// Check cache
  T? _getFromCache<T>(String key) {
    if (_cache.containsKey(key) && _cacheTimestamps.containsKey(key)) {
      final timestamp = _cacheTimestamps[key]!;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return _cache[key] as T?;
      }
      _cache.remove(key);
      _cacheTimestamps.remove(key);
    }
    return null;
  }

  /// Set cache
  void _setCache<T>(String key, T data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Fetch trending anime (currently airing, top rated)
  /// Matches: fetchTrendingAnime() in nyanime website
  Future<List<JikanAnime>> getTrending({int limit = 25}) async {
    final cacheKey = 'trending_$limit';
    final cached = _getFromCache<List<JikanAnime>>(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get(
        '/top/anime',
        queryParameters: {
          'filter': 'airing',
          'limit': limit.clamp(1, _maxLimit),
        },
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      final anime = data
          .map((e) => JikanAnime.fromJson(e as Map<String, dynamic>))
          .toList();

      _setCache(cacheKey, anime);
      return anime;
    } catch (e) {
      print('[JikanApi] getTrending error: $e');
      return [];
    }
  }

  /// Fetch popular anime (by popularity)
  /// Matches: fetchPopularAnime() in nyanime website
  Future<List<JikanAnime>> getPopular({int limit = 25}) async {
    final cacheKey = 'popular_$limit';
    final cached = _getFromCache<List<JikanAnime>>(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get(
        '/top/anime',
        queryParameters: {
          'filter': 'bypopularity',
          'limit': limit.clamp(1, _maxLimit),
        },
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      final anime = data
          .map((e) => JikanAnime.fromJson(e as Map<String, dynamic>))
          .toList();

      _setCache(cacheKey, anime);
      return anime;
    } catch (e) {
      print('[JikanApi] getPopular error: $e');
      return [];
    }
  }

  /// Fetch seasonal anime (current season)
  /// Matches: fetchSeasonalAnime() in nyanime website
  Future<List<JikanAnime>> getSeasonal({int limit = 25}) async {
    final cacheKey = 'seasonal_$limit';
    final cached = _getFromCache<List<JikanAnime>>(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get(
        '/seasons/now',
        queryParameters: {'limit': limit.clamp(1, _maxLimit)},
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      final anime = data
          .map((e) => JikanAnime.fromJson(e as Map<String, dynamic>))
          .toList();

      _setCache(cacheKey, anime);
      return anime;
    } catch (e) {
      print('[JikanApi] getSeasonal error: $e');
      return [];
    }
  }

  /// Search anime
  /// Matches: searchAnime() in nyanime website
  Future<({List<JikanAnime> anime, JikanPagination pagination})> searchAnime(
    String query, {
    String? genre,
    String? year,
    String? status,
    int page = 1,
  }) async {
    final cacheKey = 'search_${query}_${genre}_${year}_${status}_$page';
    final cached =
        _getFromCache<({List<JikanAnime> anime, JikanPagination pagination})>(
          cacheKey,
        );
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final params = <String, dynamic>{'page': page, 'limit': _maxLimit};

      if (query.isNotEmpty) {
        params['q'] = query;
      }

      if (genre != null && genre.isNotEmpty) {
        final genreLower = genre.toLowerCase();
        final genreId = genreIdMap[genreLower];
        if (genreId != null) {
          params['genres'] = genreId;
        }
      }

      if (year != null && year.isNotEmpty) {
        params['start_date'] = year;
      }

      if (status != null && status.isNotEmpty) {
        final statusMap = {
          'Airing': 'airing',
          'Completed': 'complete',
          'Upcoming': 'upcoming',
        };
        params['status'] = statusMap[status] ?? status.toLowerCase();
      }

      final response = await _dio.get('/anime', queryParameters: params);

      final data = response.data['data'] as List<dynamic>? ?? [];
      final anime = data
          .map((e) => JikanAnime.fromJson(e as Map<String, dynamic>))
          .toList();
      final pagination = JikanPagination.fromJson(
        response.data['pagination'] as Map<String, dynamic>? ?? {},
      );

      final result = (anime: anime, pagination: pagination);
      _setCache(cacheKey, result);
      return result;
    } catch (e) {
      print('[JikanApi] searchAnime error: $e');
      return (
        anime: <JikanAnime>[],
        pagination: JikanPagination(
          lastVisiblePage: 0,
          hasNextPage: false,
          currentPage: page,
        ),
      );
    }
  }

  /// Get anime by MAL ID
  /// Matches: getAnimeById() in nyanime website
  Future<JikanAnime?> getAnimeById(int id) async {
    final cacheKey = 'anime_$id';
    final cached = _getFromCache<JikanAnime>(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get('/anime/$id');
      final data = response.data['data'] as Map<String, dynamic>?;

      if (data == null) return null;

      final anime = JikanAnime.fromJson(data);
      _setCache(cacheKey, anime);
      return anime;
    } catch (e) {
      print('[JikanApi] getAnimeById error: $e');
      return null;
    }
  }

  /// Get similar anime (recommendations)
  /// Matches: getSimilarAnime() in nyanime website
  Future<List<JikanAnime>> getSimilarAnime(int id, {int limit = 5}) async {
    final cacheKey = 'similar_$id';
    final cached = _getFromCache<List<JikanAnime>>(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get('/anime/$id/recommendations');
      final data = response.data['data'] as List<dynamic>? ?? [];

      final anime = data
          .take(limit)
          .where((rec) => rec != null && rec['entry'] != null)
          .map(
            (rec) => JikanAnime.fromJson(rec['entry'] as Map<String, dynamic>),
          )
          .toList();

      _setCache(cacheKey, anime);
      return anime;
    } catch (e) {
      print('[JikanApi] getSimilarAnime error: $e');
      return [];
    }
  }

  /// Get genres list
  Future<List<String>> getGenres() async {
    final cacheKey = 'genres';
    final cached = _getFromCache<List<String>>(cacheKey);
    if (cached != null) return cached;

    await _respectRateLimit();

    try {
      final response = await _dio.get('/genres/anime');
      final data = response.data['data'] as List<dynamic>? ?? [];

      final genres = data
          .map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      _setCache(cacheKey, genres);
      return genres;
    } catch (e) {
      print('[JikanApi] getGenres error: $e');
      return [];
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

// ============================================================================
// SINGLETON INSTANCE
// ============================================================================

final jikanApi = JikanApi();
