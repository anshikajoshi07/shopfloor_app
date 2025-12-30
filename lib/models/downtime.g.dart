// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downtime.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DowntimeAdapter extends TypeAdapter<Downtime> {
  @override
  final int typeId = 1;

  @override
  Downtime read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return Downtime(
      id: fields[0] as String,
      machineId: fields[1] as String,
      tenantId: fields[2] as String,
      start: fields[3] as DateTime,
      end: fields[4] as DateTime?,
      reasonLevel1: fields[5] as String,
      reasonLevel2: fields[6] as String,
      notes: fields[7] as String?,
      photoPath: fields[8] as String?,
      synced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Downtime obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.machineId)
      ..writeByte(2)
      ..write(obj.tenantId)
      ..writeByte(3)
      ..write(obj.start)
      ..writeByte(4)
      ..write(obj.end)
      ..writeByte(5)
      ..write(obj.reasonLevel1)
      ..writeByte(6)
      ..write(obj.reasonLevel2)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.photoPath)
      ..writeByte(9)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DowntimeAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
