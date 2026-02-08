/// Nylab - Stream Repository
///
/// Repository for handling HLS streaming URLs with proxy support
library;

import '../api/aniwatch_api.dart';

/// Stream quality options
enum StreamQuality { auto, p1080, p720, p480, p360 }

/// Stream category (sub/dub)
enum StreamCategory { sub, dub }

/// Resolved stream data
class StreamData {
  final String url;
  final String? proxiedUrl;
  final String? referer;
  final List<SubtitleTrack> subtitles;
  final SkipTimes? skipTimes;
  final int? anilistId;
  final int? malId;
  final StreamQuality quality;
  final StreamCategory category;

  StreamData({
    required this.url,
    this.proxiedUrl,
    this.referer,
    required this.subtitles,
    this.skipTimes,
    this.anilistId,
    this.malId,
    this.quality = StreamQuality.auto,
    this.category = StreamCategory.sub,
  });

  /// Get the best URL (proxied if available)
  String get playableUrl => proxiedUrl ?? url;

  /// Check if stream has subtitles
  bool get hasSubtitles => subtitles.isNotEmpty;

  /// Get default subtitle
  SubtitleTrack? get defaultSubtitle => subtitles.firstWhere(
    (s) => s.isDefault,
    orElse: () =>
        subtitles.isNotEmpty ? subtitles.first : SubtitleTrack.empty(),
  );
}

/// Subtitle track info
class SubtitleTrack {
  final String url;
  final String language;
  final String? kind;
  final bool isDefault;

  SubtitleTrack({
    required this.url,
    required this.language,
    this.kind,
    this.isDefault = false,
  });

  factory SubtitleTrack.empty() => SubtitleTrack(url: '', language: '');

  bool get isEmpty => url.isEmpty;
}

/// Skip times for intro/outro
class SkipTimes {
  final Duration? introStart;
  final Duration? introEnd;
  final Duration? outroStart;
  final Duration? outroEnd;

  SkipTimes({this.introStart, this.introEnd, this.outroStart, this.outroEnd});

  bool get hasIntro => introStart != null && introEnd != null;
  bool get hasOutro => outroStart != null && outroEnd != null;
}

/// Stream repository interface
abstract class StreamRepository {
  Future<StreamData?> getStreamUrl(
    String animeId,
    int episodeNumber, {
    StreamCategory category,
    StreamQuality preferredQuality,
  });

  Future<StreamData?> getStreamUrlByEpisodeId(
    String episodeId, {
    StreamCategory category,
    StreamQuality preferredQuality,
  });

  Future<List<String>> getAvailableServers(String episodeId);
}

/// Aniwatch-backed stream repository
class AniwatchStreamRepository implements StreamRepository {
  final AniwatchApi _api;
  static const String _defaultReferer = 'https://megacloud.blog/';

  AniwatchStreamRepository({AniwatchApi? api}) : _api = api ?? aniwatchApi;

  @override
  Future<StreamData?> getStreamUrl(
    String animeId,
    int episodeNumber, {
    StreamCategory category = StreamCategory.sub,
    StreamQuality preferredQuality = StreamQuality.auto,
  }) async {
    try {
      // First, get episodes to find the episodeId
      final episodes = await _api.getEpisodes(animeId);

      final episode = episodes.firstWhere(
        (e) => e.number == episodeNumber,
        orElse: () => AniwatchEpisode(
          number: episodeNumber,
          title: '',
          episodeId: '$animeId?ep=$episodeNumber',
        ),
      );

      return getStreamUrlByEpisodeId(
        episode.episodeId,
        category: category,
        preferredQuality: preferredQuality,
      );
    } catch (e) {
      print('[StreamRepository] getStreamUrl error: $e');
      return null;
    }
  }

  @override
  Future<StreamData?> getStreamUrlByEpisodeId(
    String episodeId, {
    StreamCategory category = StreamCategory.sub,
    StreamQuality preferredQuality = StreamQuality.auto,
  }) async {
    try {
      final categoryStr = category == StreamCategory.dub ? 'dub' : 'sub';

      // Get streaming sources with fallback servers
      final streamData = await _api.getStreamingSourcesWithFallback(
        episodeId,
        category: categoryStr,
      );

      if (streamData == null || streamData.sources.isEmpty) {
        return null;
      }

      // Find best quality source
      final source = _selectBestSource(streamData.sources, preferredQuality);
      if (source == null) {
        return null;
      }

      // Build proxied URL for CORS bypass
      final referer = streamData.referer ?? _defaultReferer;
      final proxiedUrl = _api.buildProxiedStreamUrl(
        source.url,
        referer: referer,
      );

      // Convert subtitles
      final subtitles = streamData.tracks
          .where((t) => t.kind == 'captions' || t.kind == null)
          .map(
            (t) => SubtitleTrack(
              url: t.url,
              language: t.lang,
              kind: t.kind,
              isDefault: t.isDefault,
            ),
          )
          .toList();

      // Convert skip times
      SkipTimes? skipTimes;
      if (streamData.intro != null || streamData.outro != null) {
        skipTimes = SkipTimes(
          introStart: streamData.intro != null
              ? Duration(seconds: streamData.intro!.start)
              : null,
          introEnd: streamData.intro != null
              ? Duration(seconds: streamData.intro!.end)
              : null,
          outroStart: streamData.outro != null
              ? Duration(seconds: streamData.outro!.start)
              : null,
          outroEnd: streamData.outro != null
              ? Duration(seconds: streamData.outro!.end)
              : null,
        );
      }

      return StreamData(
        url: source.url,
        proxiedUrl: proxiedUrl,
        referer: referer,
        subtitles: subtitles,
        skipTimes: skipTimes,
        anilistId: streamData.anilistId,
        malId: streamData.malId,
        quality: _parseQuality(source.quality),
        category: category,
      );
    } catch (e) {
      print('[StreamRepository] getStreamUrlByEpisodeId error: $e');
      return null;
    }
  }

  @override
  Future<List<String>> getAvailableServers(String episodeId) async {
    // For now, return default server list
    // Could be enhanced to query episode/servers endpoint
    return ['hd-1', 'hd-2', 'megacloud'];
  }

  /// Select the best source based on preferred quality
  AniwatchSource? _selectBestSource(
    List<AniwatchSource> sources,
    StreamQuality preferred,
  ) {
    if (sources.isEmpty) return null;

    // If auto, just return first HLS source
    if (preferred == StreamQuality.auto) {
      return sources.firstWhere((s) => s.isM3U8, orElse: () => sources.first);
    }

    // Try to find matching quality
    final qualityMap = {
      StreamQuality.p1080: ['1080', '1080p'],
      StreamQuality.p720: ['720', '720p'],
      StreamQuality.p480: ['480', '480p'],
      StreamQuality.p360: ['360', '360p'],
    };

    final qualityStrings = qualityMap[preferred] ?? [];
    for (final q in qualityStrings) {
      final match = sources.firstWhere(
        (s) => s.quality?.contains(q) ?? false,
        orElse: () => AniwatchSource(url: '', isM3U8: false),
      );
      if (match.url.isNotEmpty) {
        return match;
      }
    }

    // Fallback to first HLS source
    return sources.firstWhere((s) => s.isM3U8, orElse: () => sources.first);
  }

  StreamQuality _parseQuality(String? quality) {
    if (quality == null) return StreamQuality.auto;
    if (quality.contains('1080')) return StreamQuality.p1080;
    if (quality.contains('720')) return StreamQuality.p720;
    if (quality.contains('480')) return StreamQuality.p480;
    if (quality.contains('360')) return StreamQuality.p360;
    return StreamQuality.auto;
  }
}

/// Singleton instance
final streamRepository = AniwatchStreamRepository();
