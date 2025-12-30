import 'package:hive/hive.dart';

part 'alert_item.g.dart';

@HiveType(typeId: 3)
class AlertItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String message;

  @HiveField(2)
  String level; // e.g., INFO / WARN / CRITICAL

  @HiveField(3)
  String? machineId;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String status; // Created | Acknowledged | Cleared

  @HiveField(6)
  String? acknowledgedBy;

  @HiveField(7)
  DateTime? acknowledgedAt;

  @HiveField(8)
  String? clearedBy;

  @HiveField(9)
  DateTime? clearedAt;

  AlertItem({
    required this.id,
    required this.message,
    required this.level,
    this.machineId,
    required this.createdAt,
    this.status = 'Created',
    this.acknowledgedBy,
    this.acknowledgedAt,
    this.clearedBy,
    this.clearedAt,
  });
}
