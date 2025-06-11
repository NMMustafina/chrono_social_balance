// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EntryModelAdapter extends TypeAdapter<EntryModel> {
  @override
  final int typeId = 2;

  @override
  EntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EntryModel(
      start: fields[0] as DateTime,
      end: fields[1] as DateTime,
      activity: fields[2] as ActivityModel,
      friendIds: (fields[3] as List).cast<String>(),
      description: fields[4] as String?,
      photoPath: fields[5] as String?,
      date: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EntryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.activity)
      ..writeByte(3)
      ..write(obj.friendIds)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.photoPath)
      ..writeByte(6)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
