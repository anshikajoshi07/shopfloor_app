import 'package:hive/hive.dart';

part 'downtime.g.dart';

@HiveType(typeId: 1)
class Downtime extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String machineId;

  @HiveField(2)
  String tenantId;

  @HiveField(3)
  DateTime start;

  @HiveField(4)
  DateTime? end;

  @HiveField(5)
  String reasonLevel1;

  @HiveField(6)
  String reasonLevel2;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  String? photoPath;

  @HiveField(9)
  bool synced;

  Downtime({
    required this.id,
    required this.machineId,
    required this.tenantId,
    required this.start,
    this.end,
    required this.reasonLevel1,
    required this.reasonLevel2,
    this.notes,
    this.photoPath,
    this.synced = false,
  });
}