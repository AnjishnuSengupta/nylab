// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EpisodeAdapter extends TypeAdapter<Episode> {
  @override
  final int typeId = 1;

  @override
  Episode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Episode(
      id: fields[0] as int,
      animeId: fields[1] as int,
      number: fields[2] as int,
      title: fields[3] as String,
      titleJapanese: fields[4] as String?,
      synopsis: fields[5] as String?,
      thumbnailUrl: fields[6] as String,
      streamUrl: fields[7] as String?,
      duration: fields[8] as Duration,
      airedAt: fields[9] as DateTime?,
      isFiller: fields[10] as bool,
      isRecap: fields[11] as bool,
      score: fields[12] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Episode obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.animeId)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.titleJapanese)
      ..writeByte(5)
      ..write(obj.synopsis)
      ..writeByte(6)
      ..write(obj.thumbnailUrl)
      ..writeByte(7)
      ..write(obj.streamUrl)
      ..writeByte(8)
      ..write(obj.duration)
      ..writeByte(9)
      ..write(obj.airedAt)
      ..writeByte(10)
      ..write(obj.isFiller)
      ..writeByte(11)
      ..write(obj.isRecap)
      ..writeByte(12)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
