// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 2;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String?,
      avatarUrl: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      stats: fields[5] as UserStats,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 3;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      totalEpisodesWatched: fields[0] as int,
      totalAnimeCompleted: fields[1] as int,
      totalWatchTimeMinutes: fields[2] as int,
      currentStreak: fields[3] as int,
      longestStreak: fields[4] as int,
      genreDistribution: (fields[5] as Map).cast<String, int>(),
      favoriteStudios: (fields[6] as List).cast<String>(),
      averageScore: fields[7] as double,
      scoreDistribution: (fields[8] as Map).cast<int, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.totalEpisodesWatched)
      ..writeByte(1)
      ..write(obj.totalAnimeCompleted)
      ..writeByte(2)
      ..write(obj.totalWatchTimeMinutes)
      ..writeByte(3)
      ..write(obj.currentStreak)
      ..writeByte(4)
      ..write(obj.longestStreak)
      ..writeByte(5)
      ..write(obj.genreDistribution)
      ..writeByte(6)
      ..write(obj.favoriteStudios)
      ..writeByte(7)
      ..write(obj.averageScore)
      ..writeByte(8)
      ..write(obj.scoreDistribution);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchProgressAdapter extends TypeAdapter<WatchProgress> {
  @override
  final int typeId = 4;

  @override
  WatchProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchProgress(
      animeId: fields[0] as int,
      episodeId: fields[1] as int,
      episodeNumber: fields[2] as int,
      watchedDuration: fields[3] as Duration,
      totalDuration: fields[4] as Duration,
      lastWatchedAt: fields[5] as DateTime,
      isCompleted: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WatchProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.animeId)
      ..writeByte(1)
      ..write(obj.episodeId)
      ..writeByte(2)
      ..write(obj.episodeNumber)
      ..writeByte(3)
      ..write(obj.watchedDuration)
      ..writeByte(4)
      ..write(obj.totalDuration)
      ..writeByte(5)
      ..write(obj.lastWatchedAt)
      ..writeByte(6)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchlistItemAdapter extends TypeAdapter<WatchlistItem> {
  @override
  final int typeId = 5;

  @override
  WatchlistItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WatchlistItem(
      animeId: fields[0] as int,
      animeTitle: fields[1] as String,
      animePosterUrl: fields[2] as String,
      addedAt: fields[3] as DateTime,
      status: fields[4] as WatchlistStatus,
      userScore: fields[5] as int?,
      episodesWatched: fields[6] as int,
      totalEpisodes: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, WatchlistItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.animeId)
      ..writeByte(1)
      ..write(obj.animeTitle)
      ..writeByte(2)
      ..write(obj.animePosterUrl)
      ..writeByte(3)
      ..write(obj.addedAt)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.userScore)
      ..writeByte(6)
      ..write(obj.episodesWatched)
      ..writeByte(7)
      ..write(obj.totalEpisodes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WatchlistStatusAdapter extends TypeAdapter<WatchlistStatus> {
  @override
  final int typeId = 6;

  @override
  WatchlistStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WatchlistStatus.watching;
      case 1:
        return WatchlistStatus.completed;
      case 2:
        return WatchlistStatus.planToWatch;
      case 3:
        return WatchlistStatus.dropped;
      case 4:
        return WatchlistStatus.onHold;
      default:
        return WatchlistStatus.watching;
    }
  }

  @override
  void write(BinaryWriter writer, WatchlistStatus obj) {
    switch (obj) {
      case WatchlistStatus.watching:
        writer.writeByte(0);
        break;
      case WatchlistStatus.completed:
        writer.writeByte(1);
        break;
      case WatchlistStatus.planToWatch:
        writer.writeByte(2);
        break;
      case WatchlistStatus.dropped:
        writer.writeByte(3);
        break;
      case WatchlistStatus.onHold:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchlistStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
