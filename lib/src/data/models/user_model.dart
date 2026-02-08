/// NYAnime Mobile - User Models
///
/// Data models for user profile, watch progress, and watchlist.
library;

import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? avatarUrl;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final UserStats stats;

  const UserProfile({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.stats,
  });

  factory UserProfile.empty() {
    return UserProfile(
      id: 'local_user',
      username: 'Anime Fan',
      email: null,
      avatarUrl: null,
      createdAt: DateTime.now(),
      stats: UserStats.empty(),
    );
  }

  UserProfile copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    UserStats? stats,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      stats: stats ?? this.stats,
    );
  }
}

@HiveType(typeId: 3)
class UserStats {
  @HiveField(0)
  final int totalEpisodesWatched;

  @HiveField(1)
  final int totalAnimeCompleted;

  @HiveField(2)
  final int totalWatchTimeMinutes;

  @HiveField(3)
  final int currentStreak;

  @HiveField(4)
  final int longestStreak;

  @HiveField(5)
  final Map<String, int> genreDistribution;

  @HiveField(6)
  final List<String> favoriteStudios;

  @HiveField(7)
  final double averageScore;

  @HiveField(8)
  final Map<int, int> scoreDistribution;

  const UserStats({
    required this.totalEpisodesWatched,
    required this.totalAnimeCompleted,
    required this.totalWatchTimeMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.genreDistribution,
    required this.favoriteStudios,
    required this.averageScore,
    required this.scoreDistribution,
  });

  factory UserStats.empty() {
    return const UserStats(
      totalEpisodesWatched: 0,
      totalAnimeCompleted: 0,
      totalWatchTimeMinutes: 0,
      currentStreak: 0,
      longestStreak: 0,
      genreDistribution: {},
      favoriteStudios: [],
      averageScore: 0.0,
      scoreDistribution: {},
    );
  }

  /// Get formatted watch time string
  String get watchTimeFormatted {
    final hours = totalWatchTimeMinutes ~/ 60;
    final days = hours ~/ 24;
    if (days > 0) {
      return '${days}d ${hours % 24}h';
    }
    return '${hours}h ${totalWatchTimeMinutes % 60}m';
  }

  UserStats copyWith({
    int? totalEpisodesWatched,
    int? totalAnimeCompleted,
    int? totalWatchTimeMinutes,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? genreDistribution,
    List<String>? favoriteStudios,
    double? averageScore,
    Map<int, int>? scoreDistribution,
  }) {
    return UserStats(
      totalEpisodesWatched: totalEpisodesWatched ?? this.totalEpisodesWatched,
      totalAnimeCompleted: totalAnimeCompleted ?? this.totalAnimeCompleted,
      totalWatchTimeMinutes:
          totalWatchTimeMinutes ?? this.totalWatchTimeMinutes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      genreDistribution: genreDistribution ?? this.genreDistribution,
      favoriteStudios: favoriteStudios ?? this.favoriteStudios,
      averageScore: averageScore ?? this.averageScore,
      scoreDistribution: scoreDistribution ?? this.scoreDistribution,
    );
  }
}

@HiveType(typeId: 4)
class WatchProgress {
  @HiveField(0)
  final int animeId;

  @HiveField(1)
  final int episodeId;

  @HiveField(2)
  final int episodeNumber;

  @HiveField(3)
  final Duration watchedDuration;

  @HiveField(4)
  final Duration totalDuration;

  @HiveField(5)
  final DateTime lastWatchedAt;

  @HiveField(6)
  final bool isCompleted;

  const WatchProgress({
    required this.animeId,
    required this.episodeId,
    required this.episodeNumber,
    required this.watchedDuration,
    required this.totalDuration,
    required this.lastWatchedAt,
    this.isCompleted = false,
  });

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercent {
    if (totalDuration.inSeconds == 0) return 0.0;
    return (watchedDuration.inSeconds / totalDuration.inSeconds).clamp(
      0.0,
      1.0,
    );
  }

  /// Check if nearly completed (>90%)
  bool get isNearlyCompleted => progressPercent >= 0.9;

  WatchProgress copyWith({
    int? animeId,
    int? episodeId,
    int? episodeNumber,
    Duration? watchedDuration,
    Duration? totalDuration,
    DateTime? lastWatchedAt,
    bool? isCompleted,
  }) {
    return WatchProgress(
      animeId: animeId ?? this.animeId,
      episodeId: episodeId ?? this.episodeId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      watchedDuration: watchedDuration ?? this.watchedDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

@HiveType(typeId: 5)
class WatchlistItem {
  @HiveField(0)
  final int animeId;

  @HiveField(1)
  final String animeTitle;

  @HiveField(2)
  final String animePosterUrl;

  @HiveField(3)
  final DateTime addedAt;

  @HiveField(4)
  final WatchlistStatus status;

  @HiveField(5)
  final int? userScore;

  @HiveField(6)
  final int episodesWatched;

  @HiveField(7)
  final int? totalEpisodes;

  const WatchlistItem({
    required this.animeId,
    required this.animeTitle,
    required this.animePosterUrl,
    required this.addedAt,
    required this.status,
    this.userScore,
    this.episodesWatched = 0,
    this.totalEpisodes,
  });

  /// Get progress text
  String get progressText {
    if (totalEpisodes == null) {
      return '$episodesWatched / ?';
    }
    return '$episodesWatched / $totalEpisodes';
  }

  WatchlistItem copyWith({
    int? animeId,
    String? animeTitle,
    String? animePosterUrl,
    DateTime? addedAt,
    WatchlistStatus? status,
    int? userScore,
    int? episodesWatched,
    int? totalEpisodes,
  }) {
    return WatchlistItem(
      animeId: animeId ?? this.animeId,
      animeTitle: animeTitle ?? this.animeTitle,
      animePosterUrl: animePosterUrl ?? this.animePosterUrl,
      addedAt: addedAt ?? this.addedAt,
      status: status ?? this.status,
      userScore: userScore ?? this.userScore,
      episodesWatched: episodesWatched ?? this.episodesWatched,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
    );
  }
}

@HiveType(typeId: 6)
enum WatchlistStatus {
  @HiveField(0)
  watching,

  @HiveField(1)
  completed,

  @HiveField(2)
  planToWatch,

  @HiveField(3)
  dropped,

  @HiveField(4)
  onHold,
}

extension WatchlistStatusExtension on WatchlistStatus {
  String get displayName {
    switch (this) {
      case WatchlistStatus.watching:
        return 'Watching';
      case WatchlistStatus.completed:
        return 'Completed';
      case WatchlistStatus.planToWatch:
        return 'Plan to Watch';
      case WatchlistStatus.dropped:
        return 'Dropped';
      case WatchlistStatus.onHold:
        return 'On Hold';
    }
  }

  String get emoji {
    switch (this) {
      case WatchlistStatus.watching:
        return '▶️';
      case WatchlistStatus.completed:
        return '✅';
      case WatchlistStatus.planToWatch:
        return '📋';
      case WatchlistStatus.dropped:
        return '❌';
      case WatchlistStatus.onHold:
        return '⏸️';
    }
  }
}
