// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_checklist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaintenanceChecklistAdapter extends TypeAdapter<MaintenanceChecklist> {
  @override
  final int typeId = 2;

  @override
  MaintenanceChecklist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final field = reader.readByte();
      fields[field] = reader.read();
    }
    return MaintenanceChecklist(
      id: fields[0] as String,
      machineId: fields[1] as String,
      title: fields[2] as String,
      done: fields[3] as bool,
      note: fields[4] as String?,
      synced: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MaintenanceChecklist obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.machineId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.done)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaintenanceChecklistAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
