/// NYAnime Mobile - Anime Model
///
/// Core data model for anime information.
/// Structure inspired by Jikan API (https://docs.jikan.moe)
library;

import 'package:hive/hive.dart';

part 'anime_model.g.dart';

@HiveType(typeId: 0)
class Anime {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? titleJapanese;

  @HiveField(3)
  final String? titleEnglish;

  @HiveField(4)
  final String synopsis;

  @HiveField(5)
  final String posterUrl;

  @HiveField(6)
  final String? bannerUrl;

  @HiveField(7)
  final String? trailerUrl;

  @HiveField(8)
  final double score;

  @HiveField(9)
  final int scoredBy;

  @HiveField(10)
  final int rank;

  @HiveField(11)
  final int popularity;

  @HiveField(12)
  final int members;

  @HiveField(13)
  final int favorites;

  @HiveField(14)
  final String status; // "airing", "complete", "upcoming"

  @HiveField(15)
  final String type; // "TV", "Movie", "OVA", "ONA", "Special"

  @HiveField(16)
  final int? episodeCount;

  @HiveField(17)
  final String? duration; // Duration per episode

  @HiveField(18)
  final String? rating; // Age rating

  @HiveField(19)
  final String? season;

  @HiveField(20)
  final int? year;

  @HiveField(21)
  final DateTime? airedFrom;

  @HiveField(22)
  final DateTime? airedTo;

  @HiveField(23)
  final DateTime? nextEpisodeAt;

  @HiveField(24)
  final int? nextEpisodeNumber;

  @HiveField(25)
  final List<String> genres;

  @HiveField(26)
  final List<String> themes;

  @HiveField(27)
  final List<String> studios;

  @HiveField(28)
  final List<String> producers;

  @HiveField(29)
  final String? source; // "Manga", "Light Novel", "Original", etc.

  @HiveField(30)
  final bool isAiring;

  const Anime({
    required this.id,
    required this.title,
    this.titleJapanese,
    this.titleEnglish,
    required this.synopsis,
    required this.posterUrl,
    this.bannerUrl,
    this.trailerUrl,
    required this.score,
    required this.scoredBy,
    required this.rank,
    required this.popularity,
    required this.members,
    required this.favorites,
    required this.status,
    required this.type,
    this.episodeCount,
    this.duration,
    this.rating,
    this.season,
    this.year,
    this.airedFrom,
    this.airedTo,
    this.nextEpisodeAt,
    this.nextEpisodeNumber,
    required this.genres,
    required this.themes,
    required this.studios,
    required this.producers,
    this.source,
    required this.isAiring,
  });

  /// Create from JSON (Jikan API format)
  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final aired = json['aired'] as Map<String, dynamic>?;
    final broadcast = json['broadcast'] as Map<String, dynamic>?;

    return Anime(
      id: json['mal_id'] as int,
      title: json['title'] as String,
      titleJapanese: json['title_japanese'] as String?,
      titleEnglish: json['title_english'] as String?,
      synopsis: (json['synopsis'] as String?) ?? 'No synopsis available.',
      posterUrl: images?['jpg']?['large_image_url'] as String? ?? '',
      bannerUrl: images?['jpg']?['large_image_url'] as String?,
      trailerUrl: json['trailer']?['url'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      scoredBy: json['scored_by'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      popularity: json['popularity'] as int? ?? 0,
      members: json['members'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
      status: json['status'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'Unknown',
      episodeCount: json['episodes'] as int?,
      duration: json['duration'] as String?,
      rating: json['rating'] as String?,
      season: json['season'] as String?,
      year: json['year'] as int?,
      airedFrom: aired?['from'] != null
          ? DateTime.tryParse(aired!['from'] as String)
          : null,
      airedTo: aired?['to'] != null
          ? DateTime.tryParse(aired!['to'] as String)
          : null,
      nextEpisodeAt: broadcast?['time'] != null
          ? _parseNextBroadcast(broadcast!)
          : null,
      nextEpisodeNumber: null,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((g) => g['name'] as String)
              .toList() ??
          [],
      themes:
          (json['themes'] as List<dynamic>?)
              ?.map((t) => t['name'] as String)
              .toList() ??
          [],
      studios:
          (json['studios'] as List<dynamic>?)
              ?.map((s) => s['name'] as String)
              .toList() ??
          [],
      producers:
          (json['producers'] as List<dynamic>?)
              ?.map((p) => p['name'] as String)
              .toList() ??
          [],
      source: json['source'] as String?,
      isAiring: json['airing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': id,
      'title': title,
      'title_japanese': titleJapanese,
      'title_english': titleEnglish,
      'synopsis': synopsis,
      'images': {
        'jpg': {'large_image_url': posterUrl},
      },
      'score': score,
      'scored_by': scoredBy,
      'rank': rank,
      'popularity': popularity,
      'members': members,
      'favorites': favorites,
      'status': status,
      'type': type,
      'episodes': episodeCount,
      'duration': duration,
      'rating': rating,
      'season': season,
      'year': year,
      'aired': {
        'from': airedFrom?.toIso8601String(),
        'to': airedTo?.toIso8601String(),
      },
      'genres': genres.map((g) => {'name': g}).toList(),
      'themes': themes.map((t) => {'name': t}).toList(),
      'studios': studios.map((s) => {'name': s}).toList(),
      'producers': producers.map((p) => {'name': p}).toList(),
      'source': source,
      'airing': isAiring,
    };
  }

  /// Get display title (English preferred, fallback to main title)
  String get displayTitle => titleEnglish ?? title;

  /// Get season display string
  String? get seasonDisplay {
    if (season == null || year == null) return null;
    return '${season![0].toUpperCase()}${season!.substring(1)} $year';
  }

  /// Check if anime has upcoming episode
  bool get hasUpcomingEpisode =>
      nextEpisodeAt != null && nextEpisodeAt!.isAfter(DateTime.now());

  /// Get time until next episode
  Duration? get timeUntilNextEpisode {
    if (nextEpisodeAt == null) return null;
    return nextEpisodeAt!.difference(DateTime.now());
  }

  Anime copyWith({
    int? id,
    String? title,
    String? titleJapanese,
    String? titleEnglish,
    String? synopsis,
    String? posterUrl,
    String? bannerUrl,
    String? trailerUrl,
    double? score,
    int? scoredBy,
    int? rank,
    int? popularity,
    int? members,
    int? favorites,
    String? status,
    String? type,
    int? episodeCount,
    String? duration,
    String? rating,
    String? season,
    int? year,
    DateTime? airedFrom,
    DateTime? airedTo,
    DateTime? nextEpisodeAt,
    int? nextEpisodeNumber,
    List<String>? genres,
    List<String>? themes,
    List<String>? studios,
    List<String>? producers,
    String? source,
    bool? isAiring,
  }) {
    return Anime(
      id: id ?? this.id,
      title: title ?? this.title,
      titleJapanese: titleJapanese ?? this.titleJapanese,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      synopsis: synopsis ?? this.synopsis,
      posterUrl: posterUrl ?? this.posterUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      score: score ?? this.score,
      scoredBy: scoredBy ?? this.scoredBy,
      rank: rank ?? this.rank,
      popularity: popularity ?? this.popularity,
      members: members ?? this.members,
      favorites: favorites ?? this.favorites,
      status: status ?? this.status,
      type: type ?? this.type,
      episodeCount: episodeCount ?? this.episodeCount,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      season: season ?? this.season,
      year: year ?? this.year,
      airedFrom: airedFrom ?? this.airedFrom,
      airedTo: airedTo ?? this.airedTo,
      nextEpisodeAt: nextEpisodeAt ?? this.nextEpisodeAt,
      nextEpisodeNumber: nextEpisodeNumber ?? this.nextEpisodeNumber,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      studios: studios ?? this.studios,
      producers: producers ?? this.producers,
      source: source ?? this.source,
      isAiring: isAiring ?? this.isAiring,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Anime && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Parse next broadcast time from Jikan API
DateTime? _parseNextBroadcast(Map<String, dynamic> broadcast) {
  // This is a simplified version - real implementation would need
  // to calculate next occurrence based on day/time
  final time = broadcast['time'] as String?;
  final day = broadcast['day'] as String?;
  if (time == null || day == null) return null;

  // For demo purposes, return a date in the future
  final now = DateTime.now();
  final daysOfWeek = [
    'Mondays',
    'Tuesdays',
    'Wednesdays',
    'Thursdays',
    'Fridays',
    'Saturdays',
    'Sundays',
  ];
  final dayIndex = daysOfWeek.indexOf(day);
  if (dayIndex == -1) return null;

  var nextDate = now.add(Duration(days: (dayIndex - now.weekday + 7) % 7));
  if (nextDate.isBefore(now)) {
    nextDate = nextDate.add(const Duration(days: 7));
  }
  return nextDate;
}
