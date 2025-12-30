import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/alert_item.dart';

/// Simulates an alerts feed and persists alerts to Hive.
class AlertsService {
  AlertsService._private();
  static final AlertsService _instance = AlertsService._private();
  factory AlertsService() => _instance;

  final _uuid = const Uuid();
  Timer? _timer;
  final _controller = StreamController<AlertItem>.broadcast();

  Stream<AlertItem> get stream => _controller.stream;

  void start({Duration interval = const Duration(seconds: 10)}) async {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) async {
      final alert = _generateRandomAlert();
      final box = await Hive.openBox<AlertItem>('alerts');
      await box.put(alert.id, alert);
      _controller.add(alert);
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  AlertItem _generateRandomAlert() {
    final id = _uuid.v4();
    final levels = ['INFO', 'WARN', 'CRITICAL'];
    final level = levels[DateTime.now().second % levels.length];
    final msgs = {
      'INFO': 'Routine check needed',
      'WARN': 'Temperature rising',
      'CRITICAL': 'Emergency stop triggered',
    };
    final machineId = ['M-101', 'M-102', 'M-103'][DateTime.now().millisecond % 3];
    return AlertItem(
      id: id,
      message: msgs[level] ?? 'Alert',
      level: level,
      machineId: machineId,
      createdAt: DateTime.now(),
    );
  }

  Future<List<AlertItem>> getAll() async {
    final box = await Hive.openBox<AlertItem>('alerts');
    final list = box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> acknowledge(AlertItem a, String by) async {
    a.status = 'Acknowledged';
    a.acknowledgedBy = by;
    a.acknowledgedAt = DateTime.now();
    await a.save();
  }

  Future<void> clear(AlertItem a, String by) async {
    a.status = 'Cleared';
    a.clearedBy = by;
    a.clearedAt = DateTime.now();
    await a.save();
  }
}
