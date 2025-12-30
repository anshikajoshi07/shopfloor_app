import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shopfloor_app/models/alert_item.dart';
import 'package:shopfloor_app/services/alerts_service.dart';

void main() {
  late Directory tmpDir;

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('shopfloor_alerts_test');
    Hive.init(tmpDir.path);
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AlertItemAdapter());
    }
    // Ensure a clean box
    final box = await Hive.openBox<AlertItem>('alerts');
    await box.clear();
    await box.close();
  });

  tearDown(() async {
    try {
      await Hive.close();
    } catch (_) {}
    try {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('getAll returns alerts in descending createdAt order', () async {
    final box = await Hive.openBox<AlertItem>('alerts');

    final a1 = AlertItem(
      id: 'a1',
      message: 'First',
      level: 'INFO',
      createdAt: DateTime.utc(2020, 1, 1, 12, 0, 0),
    );
    final a2 = AlertItem(
      id: 'a2',
      message: 'Second',
      level: 'WARN',
      createdAt: DateTime.utc(2020, 1, 1, 13, 0, 0),
    );
    final a3 = AlertItem(
      id: 'a3',
      message: 'Third',
      level: 'CRITICAL',
      createdAt: DateTime.utc(2020, 1, 1, 14, 0, 0),
    );

    await box.put(a1.id, a1);
    await box.put(a2.id, a2);
    await box.put(a3.id, a3);

    await box.close();

    final svc = AlertsService();
    final list = await svc.getAll();
    expect(list.map((e) => e.id).toList(), ['a3', 'a2', 'a1']);
  });

  test('acknowledge sets audit fields and persists', () async {
    final box = await Hive.openBox<AlertItem>('alerts');

    final a = AlertItem(
      id: 'ack-1',
      message: 'Ack me',
      level: 'WARN',
      createdAt: DateTime.now(),
    );

    await box.put(a.id, a);

    final svc = AlertsService();
    await svc.acknowledge(a, 'tester');

    final fetched = box.get(a.id);
    expect(fetched, isNotNull);
    expect(fetched!.status, 'Acknowledged');
    expect(fetched.acknowledgedBy, 'tester');
    expect(fetched.acknowledgedAt, isNotNull);

    await box.close();
  });

  test('clear sets audit fields and persists', () async {
    final box = await Hive.openBox<AlertItem>('alerts');

    final a = AlertItem(
      id: 'clr-1',
      message: 'Clear me',
      level: 'CRITICAL',
      createdAt: DateTime.now(),
    );

    await box.put(a.id, a);

    final svc = AlertsService();
    await svc.clear(a, 'cleaner');

    final fetched = box.get(a.id);
    expect(fetched, isNotNull);
    expect(fetched!.status, 'Cleared');
    expect(fetched.clearedBy, 'cleaner');
    expect(fetched.clearedAt, isNotNull);

    await box.close();
  });

  test('start produces alerts on stream and persists to box', () async {
    final svc = AlertsService();
    final box = await Hive.openBox<AlertItem>('alerts');
    // ensure empty
    await box.clear();

    final events = <AlertItem>[];
    final sub = svc.stream.listen((a) {
      events.add(a);
    });

    svc.start(interval: const Duration(milliseconds: 50));

    // wait for the service to produce at least one event
    await Future.any([
      Future.delayed(const Duration(seconds: 1), () => false),
      Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 30));
        return events.isEmpty;
      }).then((_) => true),
    ]);

    svc.stop();
    await sub.cancel();

    expect(events.isNotEmpty, true);

    // check it's persisted
    final persisted = box.get(events.first.id);
    expect(persisted, isNotNull);

    await box.close();
  }, timeout: const Timeout(Duration(seconds: 5)));
}
