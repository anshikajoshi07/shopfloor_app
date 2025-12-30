import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shopfloor_app/services/reports_service.dart';
import 'package:shopfloor_app/models/downtime.dart';

void main() {
  late Directory tmpDir;

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('shopfloor_reports_empty');
    Hive.init(tmpDir.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DowntimeAdapter());
    final boxD = await Hive.openBox<Downtime>('downtimes');
    await boxD.clear();
    await boxD.close();
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('exportDowntimeCsv returns header when no downtimes', () async {
    final svc = ReportsService();
    final csv = await svc.exportDowntimeCsv();
    expect(csv.trim(), 'MachineId,TotalDowntimeSeconds');
  });
}
