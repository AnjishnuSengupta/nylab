/// NYAnime Mobile - Episode Model
///
/// Data model for anime episodes with playback info.
library;

import 'package:hive/hive.dart';

part 'episode_model.g.dart';

@HiveType(typeId: 1)
class Episode {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int animeId;

  @HiveField(2)
  final int number;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String? titleJapanese;

  @HiveField(5)
  final String? synopsis;

  @HiveField(6)
  final String thumbnailUrl;

  @HiveField(7)
  final String? streamUrl; // HLS URL

  @HiveField(8)
  final Duration duration;

  @HiveField(9)
  final DateTime? airedAt;

  @HiveField(10)
  final bool isFiller;

  @HiveField(11)
  final bool isRecap;

  @HiveField(12)
  final double score;

  const Episode({
    required this.id,
    required this.animeId,
    required this.number,
    required this.title,
    this.titleJapanese,
    this.synopsis,
    required this.thumbnailUrl,
    this.streamUrl,
    required this.duration,
    this.airedAt,
    this.isFiller = false,
    this.isRecap = false,
    this.score = 0.0,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['mal_id'] as int? ?? 0,
      animeId: json['anime_id'] as int? ?? 0,
      number: json['episode'] as int? ?? json['mal_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Episode ${json['mal_id'] ?? 0}',
      titleJapanese: json['title_japanese'] as String?,
      synopsis: json['synopsis'] as String?,
      thumbnailUrl: json['images']?['jpg']?['image_url'] as String? ?? '',
      streamUrl: json['stream_url'] as String?,
      duration: Duration(seconds: (json['duration'] as num?)?.toInt() ?? 1440),
      airedAt: json['aired'] != null
          ? DateTime.tryParse(json['aired'] as String)
          : null,
      isFiller: json['filler'] as bool? ?? false,
      isRecap: json['recap'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mal_id': id,
      'anime_id': animeId,
      'episode': number,
      'title': title,
      'title_japanese': titleJapanese,
      'synopsis': synopsis,
      'images': {
        'jpg': {'image_url': thumbnailUrl},
      },
      'stream_url': streamUrl,
      'duration': duration.inSeconds,
      'aired': airedAt?.toIso8601String(),
      'filler': isFiller,
      'recap': isRecap,
      'score': score,
    };
  }

  /// Display title with episode number
  String get displayTitle => 'Episode $number: $title';

  /// Short title
  String get shortTitle => 'Ep. $number';

  /// Format duration as string
  String get durationString {
    final minutes = duration.inMinutes;
    return '$minutes min';
  }

  Episode copyWith({
    int? id,
    int? animeId,
    int? number,
    String? title,
    String? titleJapanese,
    String? synopsis,
    String? thumbnailUrl,
    String? streamUrl,
    Duration? duration,
    DateTime? airedAt,
    bool? isFiller,
    bool? isRecap,
    double? score,
  }) {
    return Episode(
      id: id ?? this.id,
      animeId: animeId ?? this.animeId,
      number: number ?? this.number,
      title: title ?? this.title,
      titleJapanese: titleJapanese ?? this.titleJapanese,
      synopsis: synopsis ?? this.synopsis,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      duration: duration ?? this.duration,
      airedAt: airedAt ?? this.airedAt,
      isFiller: isFiller ?? this.isFiller,
      isRecap: isRecap ?? this.isRecap,
      score: score ?? this.score,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Episode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          animeId == other.animeId &&
          number == other.number;

  @override
  int get hashCode => Object.hash(id, animeId, number);
}
