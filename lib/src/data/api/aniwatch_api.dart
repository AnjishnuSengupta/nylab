/// Nylab - Aniwatch API Service
///
/// Real API integration with the nyanime-backend-v2 (aniwatch-api)
/// Endpoints from https://github.com/ghoshRitesh12/aniwatch-api
library;

import 'dart:convert';
import 'package:dio/dio.dart';

/// API Response types
class AniwatchSearchResult {
  final String id;
  final String name;
  final String? poster;
  final String? duration;
  final String? type;
  final String? rating;
  final int subEpisodes;
  final int dubEpisodes;

  AniwatchSearchResult({
    required this.id,
    required this.name,
    this.poster,
    this.duration,
    this.type,
    this.rating,
    this.subEpisodes = 0,
    this.dubEpisodes = 0,
  });

  factory AniwatchSearchResult.fromJson(Map<String, dynamic> json) {
    final episodes = json['episodes'] as Map<String, dynamic>?;
    return AniwatchSearchResult(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      poster: json['poster'] as String?,
      duration: json['duration'] as String?,
      type: json['type'] as String?,
      rating: json['rating'] as String?,
      subEpisodes: episodes?['sub'] as int? ?? 0,
      dubEpisodes: episodes?['dub'] as int? ?? 0,
    );
  }
}

class AniwatchEpisode {
  final int number;
  final String title;
  final String episodeId;
  final bool isFiller;

  AniwatchEpisode({
    required this.number,
    required this.title,
    required this.episodeId,
    this.isFiller = false,
  });

  factory AniwatchEpisode.fromJson(Map<String, dynamic> json) {
    return AniwatchEpisode(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      episodeId: json['episodeId'] as String? ?? '',
      isFiller: json['isFiller'] as bool? ?? false,
    );
  }
}

class AniwatchStreamingData {
  final String? referer;
  final List<AniwatchSource> sources;
  final List<AniwatchTrack> tracks;
  final AniwatchSkipTime? intro;
  final AniwatchSkipTime? outro;
  final int? anilistId;
  final int? malId;

  AniwatchStreamingData({
    this.referer,
    required this.sources,
    required this.tracks,
    this.intro,
    this.outro,
    this.anilistId,
    this.malId,
  });

  factory AniwatchStreamingData.fromJson(Map<String, dynamic> json) {
    final headers = json['headers'] as Map<String, dynamic>?;
    return AniwatchStreamingData(
      referer: headers?['Referer'] as String?,
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map((e) => AniwatchSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tracks:
          (json['tracks'] as List<dynamic>?)
              ?.map((e) => AniwatchTrack.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      intro: json['intro'] != null
          ? AniwatchSkipTime.fromJson(json['intro'] as Map<String, dynamic>)
          : null,
      outro: json['outro'] != null
          ? AniwatchSkipTime.fromJson(json['outro'] as Map<String, dynamic>)
          : null,
      anilistId: json['anilistID'] as int?,
      malId: json['malID'] as int?,
    );
  }
}

class AniwatchSource {
  final String url;
  final bool isM3U8;
  final String? quality;

  AniwatchSource({required this.url, required this.isM3U8, this.quality});

  factory AniwatchSource.fromJson(Map<String, dynamic> json) {
    return AniwatchSource(
      url: json['url'] as String? ?? '',
      isM3U8: json['isM3U8'] as bool? ?? true,
      quality: json['quality'] as String?,
    );
  }
}

class AniwatchTrack {
  final String url;
  final String lang;
  final String? kind;
  final bool isDefault;

  AniwatchTrack({
    required this.url,
    required this.lang,
    this.kind,
    this.isDefault = false,
  });

  factory AniwatchTrack.fromJson(Map<String, dynamic> json) {
    return AniwatchTrack(
      url: json['url'] as String? ?? '',
      lang: json['lang'] as String? ?? json['label'] as String? ?? '',
      kind: json['kind'] as String?,
      isDefault: json['default'] as bool? ?? false,
    );
  }
}

class AniwatchSkipTime {
  final int start;
  final int end;

  AniwatchSkipTime({required this.start, required this.end});

  factory AniwatchSkipTime.fromJson(Map<String, dynamic> json) {
    return AniwatchSkipTime(
      start: json['start'] as int? ?? 0,
      end: json['end'] as int? ?? 0,
    );
  }
}

class AniwatchHomeData {
  final List<AniwatchSpotlight> spotlightAnimes;
  final List<AniwatchSearchResult> trendingAnimes;
  final List<AniwatchSearchResult> latestEpisodeAnimes;
  final List<AniwatchSearchResult> topUpcomingAnimes;
  final List<AniwatchSearchResult> topAiringAnimes;
  final List<AniwatchSearchResult> mostPopularAnimes;
  final List<AniwatchSearchResult> mostFavoriteAnimes;
  final List<AniwatchSearchResult> latestCompletedAnimes;

  AniwatchHomeData({
    required this.spotlightAnimes,
    required this.trendingAnimes,
    required this.latestEpisodeAnimes,
    required this.topUpcomingAnimes,
    required this.topAiringAnimes,
    required this.mostPopularAnimes,
    required this.mostFavoriteAnimes,
    required this.latestCompletedAnimes,
  });

  factory AniwatchHomeData.fromJson(Map<String, dynamic> json) {
    List<AniwatchSearchResult> parseList(String key) {
      return (json[key] as List<dynamic>?)
              ?.map(
                (e) => AniwatchSearchResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [];
    }

    return AniwatchHomeData(
      spotlightAnimes:
          (json['spotlightAnimes'] as List<dynamic>?)
              ?.map(
                (e) => AniwatchSpotlight.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      trendingAnimes: parseList('trendingAnimes'),
      latestEpisodeAnimes: parseList('latestEpisodeAnimes'),
      topUpcomingAnimes: parseList('topUpcomingAnimes'),
      topAiringAnimes: parseList('topAiringAnimes'),
      mostPopularAnimes: parseList('mostPopularAnimes'),
      mostFavoriteAnimes: parseList('mostFavoriteAnimes'),
      latestCompletedAnimes: parseList('latestCompletedAnimes'),
    );
  }
}

class AniwatchSpotlight {
  final int rank;
  final String id;
  final String name;
  final String? description;
  final String? poster;
  final String? jname;
  final int subEpisodes;
  final int dubEpisodes;
  final int? totalEpisodes;
  final String? type;

  AniwatchSpotlight({
    required this.rank,
    required this.id,
    required this.name,
    this.description,
    this.poster,
    this.jname,
    this.subEpisodes = 0,
    this.dubEpisodes = 0,
    this.totalEpisodes,
    this.type,
  });

  factory AniwatchSpotlight.fromJson(Map<String, dynamic> json) {
    final otherInfo = json['otherInfo'] as List<dynamic>?;
    final episodes = json['episodes'] as Map<String, dynamic>?;
    return AniwatchSpotlight(
      rank: json['rank'] as int? ?? 0,
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      poster: json['poster'] as String?,
      jname: json['jname'] as String?,
      subEpisodes: episodes?['sub'] as int? ?? 0,
      dubEpisodes: episodes?['dub'] as int? ?? 0,
      totalEpisodes: otherInfo != null && otherInfo.length > 3
          ? int.tryParse(
              otherInfo[3].toString().replaceAll(RegExp(r'[^0-9]'), ''),
            )
          : null,
      type: otherInfo != null && otherInfo.isNotEmpty
          ? otherInfo[0] as String?
          : null,
    );
  }
}

class AniwatchAnimeInfo {
  final AniwatchAnimeDetails anime;
  final List<AniwatchSearchResult> relatedAnimes;
  final List<AniwatchSearchResult> recommendedAnimes;
  final List<String> seasons;

  AniwatchAnimeInfo({
    required this.anime,
    required this.relatedAnimes,
    required this.recommendedAnimes,
    required this.seasons,
  });

  factory AniwatchAnimeInfo.fromJson(Map<String, dynamic> json) {
    return AniwatchAnimeInfo(
      anime: AniwatchAnimeDetails.fromJson(
        json['anime'] as Map<String, dynamic>? ?? {},
      ),
      relatedAnimes:
          (json['relatedAnimes'] as List<dynamic>?)
              ?.map(
                (e) => AniwatchSearchResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      recommendedAnimes:
          (json['recommendedAnimes'] as List<dynamic>?)
              ?.map(
                (e) => AniwatchSearchResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      seasons:
          (json['seasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class AniwatchAnimeDetails {
  final AniwatchAnimeInfoData info;
  final AniwatchAnimeMoreInfo moreInfo;

  AniwatchAnimeDetails({required this.info, required this.moreInfo});

  factory AniwatchAnimeDetails.fromJson(Map<String, dynamic> json) {
    return AniwatchAnimeDetails(
      info: AniwatchAnimeInfoData.fromJson(
        json['info'] as Map<String, dynamic>? ?? {},
      ),
      moreInfo: AniwatchAnimeMoreInfo.fromJson(
        json['moreInfo'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class AniwatchAnimeInfoData {
  final String id;
  final String? anilistId;
  final String? malId;
  final String name;
  final String? poster;
  final String? description;
  final AniwatchStats? stats;
  final String? promotionalVideos;

  AniwatchAnimeInfoData({
    required this.id,
    this.anilistId,
    this.malId,
    required this.name,
    this.poster,
    this.description,
    this.stats,
    this.promotionalVideos,
  });

  factory AniwatchAnimeInfoData.fromJson(Map<String, dynamic> json) {
    return AniwatchAnimeInfoData(
      id: json['id'] as String? ?? '',
      anilistId: json['anilistId']?.toString(),
      malId: json['malId']?.toString(),
      name: json['name'] as String? ?? '',
      poster: json['poster'] as String?,
      description: json['description'] as String?,
      stats: json['stats'] != null
          ? AniwatchStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      promotionalVideos: null,
    );
  }
}

class AniwatchStats {
  final String? rating;
  final String? quality;
  final int subEpisodes;
  final int dubEpisodes;
  final String? type;
  final String? duration;

  AniwatchStats({
    this.rating,
    this.quality,
    this.subEpisodes = 0,
    this.dubEpisodes = 0,
    this.type,
    this.duration,
  });

  factory AniwatchStats.fromJson(Map<String, dynamic> json) {
    final episodes = json['episodes'] as Map<String, dynamic>?;
    return AniwatchStats(
      rating: json['rating'] as String?,
      quality: json['quality'] as String?,
      subEpisodes: episodes?['sub'] as int? ?? 0,
      dubEpisodes: episodes?['dub'] as int? ?? 0,
      type: json['type'] as String?,
      duration: json['duration'] as String?,
    );
  }
}

class AniwatchAnimeMoreInfo {
  final String? japanese;
  final String? synonyms;
  final String? aired;
  final String? premiered;
  final String? duration;
  final String? status;
  final String? malScore;
  final List<String> genres;
  final List<String> studios;
  final List<String> producers;

  AniwatchAnimeMoreInfo({
    this.japanese,
    this.synonyms,
    this.aired,
    this.premiered,
    this.duration,
    this.status,
    this.malScore,
    required this.genres,
    required this.studios,
    required this.producers,
  });

  factory AniwatchAnimeMoreInfo.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        return value.split(',').map((e) => e.trim()).toList();
      }
      return [];
    }

    return AniwatchAnimeMoreInfo(
      japanese: json['japanese'] as String?,
      synonyms: json['synonyms'] as String?,
      aired: json['aired'] as String?,
      premiered: json['premiered'] as String?,
      duration: json['duration'] as String?,
      status: json['status'] as String?,
      malScore: json['malscore'] as String?,
      genres: parseStringList(json['genres']),
      studios: parseStringList(json['studios']),
      producers: parseStringList(json['producers']),
    );
  }
}

/// Aniwatch API Service
class AniwatchApi {
  final Dio _dio;
  static const String _baseUrl = 'https://nyanime-backend-v2.onrender.com';
  static const String _streamProxyUrl = 'https://www.nyanime.tech';

  // Simple in-memory cache
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  AniwatchApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 30),
              headers: {
                'Accept': 'application/json',
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
              },
            ),
          );

  /// Get data from cache or fetch
  T? _getFromCache<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null &&
        DateTime.now().difference(timestamp) < _cacheDuration) {
      return _cache[key] as T?;
    }
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    return null;
  }

  void _setCache(String key, dynamic data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// Unwrap API response
  dynamic _unwrapResponse(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      // Handle wrapped responses
      if (data.containsKey('success') && data.containsKey('data')) {
        return data['data'];
      }
      if (data.containsKey('data')) {
        return data['data'];
      }
    }
    return data;
  }

  /// Get home page data (trending, spotlight, etc.)
  Future<AniwatchHomeData?> getHome() async {
    const cacheKey = 'home';
    final cached = _getFromCache<AniwatchHomeData>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.get('/api/v2/hianime/home');
      final data = _unwrapResponse(response);
      if (data != null) {
        final result = AniwatchHomeData.fromJson(data as Map<String, dynamic>);
        _setCache(cacheKey, result);
        return result;
      }
    } catch (e) {
      print('[AniwatchApi] getHome error: $e');
    }
    return null;
  }

  /// Search anime
  Future<List<AniwatchSearchResult>> searchAnime(
    String query, {
    int page = 1,
  }) async {
    final cacheKey = 'search:$query:$page';
    final cached = _getFromCache<List<AniwatchSearchResult>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        '/api/v2/hianime/search',
        queryParameters: {'q': query, 'page': page},
      );
      final data = _unwrapResponse(response);
      if (data != null && data['animes'] != null) {
        final results = (data['animes'] as List<dynamic>)
            .map(
              (e) => AniwatchSearchResult.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        _setCache(cacheKey, results);
        return results;
      }
    } catch (e) {
      print('[AniwatchApi] searchAnime error: $e');
    }
    return [];
  }

  /// Get anime details
  Future<AniwatchAnimeInfo?> getAnimeInfo(String animeId) async {
    final cacheKey = 'anime:$animeId';
    final cached = _getFromCache<AniwatchAnimeInfo>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.get('/api/v2/hianime/anime/$animeId');
      final data = _unwrapResponse(response);
      if (data != null) {
        final result = AniwatchAnimeInfo.fromJson(data as Map<String, dynamic>);
        _setCache(cacheKey, result);
        return result;
      }
    } catch (e) {
      print('[AniwatchApi] getAnimeInfo error: $e');
    }
    return null;
  }

  /// Get episodes for an anime
  Future<List<AniwatchEpisode>> getEpisodes(String animeId) async {
    final cacheKey = 'episodes:$animeId';
    final cached = _getFromCache<List<AniwatchEpisode>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        '/api/v2/hianime/anime/$animeId/episodes',
      );
      final data = _unwrapResponse(response);
      if (data != null && data['episodes'] != null) {
        final results = (data['episodes'] as List<dynamic>)
            .map((e) => AniwatchEpisode.fromJson(e as Map<String, dynamic>))
            .toList();
        _setCache(cacheKey, results);
        return results;
      }
    } catch (e) {
      print('[AniwatchApi] getEpisodes error: $e');
    }
    return [];
  }

  /// Get streaming sources
  Future<AniwatchStreamingData?> getStreamingSources(
    String episodeId, {
    String category = 'sub',
    String server = 'hd-1',
  }) async {
    // Don't cache streaming sources as URLs may expire
    try {
      final response = await _dio.get(
        '/api/v2/hianime/episode/sources',
        queryParameters: {
          'animeEpisodeId': episodeId,
          'server': server,
          'category': category,
        },
      );
      final data = _unwrapResponse(response);
      if (data != null) {
        return AniwatchStreamingData.fromJson(data as Map<String, dynamic>);
      }
    } catch (e) {
      print('[AniwatchApi] getStreamingSources error: $e');
    }
    return null;
  }

  /// Get streaming sources with fallback servers
  Future<AniwatchStreamingData?> getStreamingSourcesWithFallback(
    String episodeId, {
    String category = 'sub',
  }) async {
    final servers = ['hd-1', 'hd-2', 'megacloud'];

    for (final server in servers) {
      final result = await getStreamingSources(
        episodeId,
        category: category,
        server: server,
      );
      if (result != null && result.sources.isNotEmpty) {
        return result;
      }
    }

    // Try dub if sub didn't work
    if (category == 'sub') {
      for (final server in servers) {
        final result = await getStreamingSources(
          episodeId,
          category: 'dub',
          server: server,
        );
        if (result != null && result.sources.isNotEmpty) {
          return result;
        }
      }
    }

    return null;
  }

  /// Build proxied stream URL for CORS bypass
  String buildProxiedStreamUrl(String url, {String? referer}) {
    final headers = {'Referer': referer ?? 'https://megacloud.blog/'};
    final headersB64 = base64Encode(utf8.encode(jsonEncode(headers)));
    return '$_streamProxyUrl/stream?url=${Uri.encodeComponent(url)}&h=$headersB64';
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}

/// Singleton instance
final aniwatchApi = AniwatchApi();
