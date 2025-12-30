// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertItemAdapter extends TypeAdapter<AlertItem> {
  @override
  final int typeId = 3;

  @override
  AlertItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return AlertItem(
      id: fields[0] as String,
      message: fields[1] as String,
      level: fields[2] as String,
      machineId: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      status: fields[5] as String,
      acknowledgedBy: fields[6] as String?,
      acknowledgedAt: fields[7] as DateTime?,
      clearedBy: fields[8] as String?,
      clearedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AlertItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.machineId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.acknowledgedBy)
      ..writeByte(7)
      ..write(obj.acknowledgedAt)
      ..writeByte(8)
      ..write(obj.clearedBy)
      ..writeByte(9)
      ..write(obj.clearedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertItemAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
