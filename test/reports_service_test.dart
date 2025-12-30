import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shopfloor_app/models/downtime.dart';
import 'package:shopfloor_app/models/maintenance_checklist.dart';
import 'package:shopfloor_app/models/alert_item.dart';
import 'package:shopfloor_app/services/reports_service.dart';

void main() {
  late Directory tmpDir;

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('shopfloor_reports');
    Hive.init(tmpDir.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DowntimeAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(MaintenanceChecklistAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(AlertItemAdapter());
    final boxD = await Hive.openBox<Downtime>('downtimes');
    final boxC = await Hive.openBox<MaintenanceChecklist>('checklists');
    final boxA = await Hive.openBox<AlertItem>('alerts');
    await boxD.clear();
    await boxC.clear();
    await boxA.clear();
    await boxD.close();
    await boxC.close();
    await boxA.close();
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('totalDowntimePerMachine computes durations', () async {
    final box = await Hive.openBox<Downtime>('downtimes');

    final d1 = Downtime(
      id: 'd1',
      machineId: 'M-A',
      tenantId: 'T1',
      start: DateTime.now().subtract(const Duration(hours: 2)),
      end: DateTime.now().subtract(const Duration(hours: 1)),
      reasonLevel1: 'Planned',
      reasonLevel2: 'Maintenance',
      notes: '',
    );

    final d2 = Downtime(
      id: 'd2',
      machineId: 'M-A',
      tenantId: 'T1',
      start: DateTime.now().subtract(const Duration(hours: 4)),
      end: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
      reasonLevel1: 'Unplanned',
      reasonLevel2: 'Fault',
      notes: '',
    );

    final d3 = Downtime(
      id: 'd3',
      machineId: 'M-B',
      tenantId: 'T1',
      start: DateTime.now().subtract(const Duration(hours: 1)),
      end: DateTime.now().subtract(const Duration(minutes: 30)),
      reasonLevel1: 'Planned',
      reasonLevel2: 'Check',
      notes: '',
    );

    await box.put(d1.id, d1);
    await box.put(d2.id, d2);
    await box.put(d3.id, d3);

    final svc = ReportsService();
    final totals = await svc.totalDowntimePerMachine();

    expect(totals['M-A']?.inMinutes, equals(90)); // 60 + 30
    expect(totals['M-B']?.inMinutes, equals(30));

    await box.close();
  });

  test('alertsCountBySeverity counts alerts', () async {
    final box = await Hive.openBox<AlertItem>('alerts');
    await box.clear();
    final a1 = AlertItem(id: 'a1', message: 'm1', level: 'WARN', machineId: 'M-A', createdAt: DateTime.now());
    final a2 = AlertItem(id: 'a2', message: 'm2', level: 'CRITICAL', machineId: 'M-A', createdAt: DateTime.now());
    final a3 = AlertItem(id: 'a3', message: 'm3', level: 'WARN', machineId: 'M-B', createdAt: DateTime.now());
    await box.put(a1.id, a1);
    await box.put(a2.id, a2);
    await box.put(a3.id, a3);

    final svc = ReportsService();
    final counts = await svc.alertsCountBySeverity();
    expect(counts['WARN'], equals(2));
    expect(counts['CRITICAL'], equals(1));

    await box.close();
  });
}
