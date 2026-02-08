// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReactionResultAdapter extends TypeAdapter<ReactionResult> {
  @override
  final typeId = 0;

  @override
  ReactionResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReactionResult(
      id: fields[0] as String,
      colorChangeTime: fields[1] as DateTime,
      tapTime: fields[2] as DateTime,
      reactionTimeMs: (fields[3] as num).toInt(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ReactionResult obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.colorChangeTime)
      ..writeByte(2)
      ..write(obj.tapTime)
      ..writeByte(3)
      ..write(obj.reactionTimeMs)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReactionResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
