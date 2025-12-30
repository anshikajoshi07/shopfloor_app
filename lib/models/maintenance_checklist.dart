import 'package:hive/hive.dart';

part 'maintenance_checklist.g.dart';

@HiveType(typeId: 2)
class MaintenanceChecklist extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String machineId;

  @HiveField(2)
  String title;

  @HiveField(3)
  bool done;

  @HiveField(4)
  String? note;

  @HiveField(5)
  bool synced;

  MaintenanceChecklist({
    required this.id,
    required this.machineId,
    required this.title,
    this.done = false,
    this.note,
    this.synced = false,
  });
}