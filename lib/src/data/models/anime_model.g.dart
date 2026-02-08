// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnimeAdapter extends TypeAdapter<Anime> {
  @override
  final int typeId = 0;

  @override
  Anime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Anime(
      id: fields[0] as int,
      title: fields[1] as String,
      titleJapanese: fields[2] as String?,
      titleEnglish: fields[3] as String?,
      synopsis: fields[4] as String,
      posterUrl: fields[5] as String,
      bannerUrl: fields[6] as String?,
      trailerUrl: fields[7] as String?,
      score: fields[8] as double,
      scoredBy: fields[9] as int,
      rank: fields[10] as int,
      popularity: fields[11] as int,
      members: fields[12] as int,
      favorites: fields[13] as int,
      status: fields[14] as String,
      type: fields[15] as String,
      episodeCount: fields[16] as int?,
      duration: fields[17] as String?,
      rating: fields[18] as String?,
      season: fields[19] as String?,
      year: fields[20] as int?,
      airedFrom: fields[21] as DateTime?,
      airedTo: fields[22] as DateTime?,
      nextEpisodeAt: fields[23] as DateTime?,
      nextEpisodeNumber: fields[24] as int?,
      genres: (fields[25] as List).cast<String>(),
      themes: (fields[26] as List).cast<String>(),
      studios: (fields[27] as List).cast<String>(),
      producers: (fields[28] as List).cast<String>(),
      source: fields[29] as String?,
      isAiring: fields[30] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Anime obj) {
    writer
      ..writeByte(31)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.titleJapanese)
      ..writeByte(3)
      ..write(obj.titleEnglish)
      ..writeByte(4)
      ..write(obj.synopsis)
      ..writeByte(5)
      ..write(obj.posterUrl)
      ..writeByte(6)
      ..write(obj.bannerUrl)
      ..writeByte(7)
      ..write(obj.trailerUrl)
      ..writeByte(8)
      ..write(obj.score)
      ..writeByte(9)
      ..write(obj.scoredBy)
      ..writeByte(10)
      ..write(obj.rank)
      ..writeByte(11)
      ..write(obj.popularity)
      ..writeByte(12)
      ..write(obj.members)
      ..writeByte(13)
      ..write(obj.favorites)
      ..writeByte(14)
      ..write(obj.status)
      ..writeByte(15)
      ..write(obj.type)
      ..writeByte(16)
      ..write(obj.episodeCount)
      ..writeByte(17)
      ..write(obj.duration)
      ..writeByte(18)
      ..write(obj.rating)
      ..writeByte(19)
      ..write(obj.season)
      ..writeByte(20)
      ..write(obj.year)
      ..writeByte(21)
      ..write(obj.airedFrom)
      ..writeByte(22)
      ..write(obj.airedTo)
      ..writeByte(23)
      ..write(obj.nextEpisodeAt)
      ..writeByte(24)
      ..write(obj.nextEpisodeNumber)
      ..writeByte(25)
      ..write(obj.genres)
      ..writeByte(26)
      ..write(obj.themes)
      ..writeByte(27)
      ..write(obj.studios)
      ..writeByte(28)
      ..write(obj.producers)
      ..writeByte(29)
      ..write(obj.source)
      ..writeByte(30)
      ..write(obj.isAiring);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
