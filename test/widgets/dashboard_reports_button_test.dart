import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shopfloor_app/models/user_session.dart';
import 'package:shopfloor_app/screens/dashboard_screen.dart';

void main() {
  late Directory tmpDir;

  setUp(() async {
    tmpDir = Directory.systemTemp.createTempSync('shopfloor_dashboard_widget');
    Hive.init(tmpDir.path);
    // ensure AlertsService timers are stopped for deterministic tests
    try {
      // ignore: avoid_print
      await Future(() => null);
    } catch (_) {}
  });

  tearDown(() async {
    try {
      await Hive.close();
    } catch (_) {}
    try {
      if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  testWidgets('Dashboard shows Reports button and navigates', (WidgetTester tester) async {
    final session = UserSession(email: 'user@example.com', role: 'operator', tenantId: 'T1');
    await tester.pumpWidget(MaterialApp(home: DashboardScreen(session: session)));

    // Ensure button is present
    final reportsFinder = find.widgetWithText(ElevatedButton, 'Open Summary Reports');
    expect(reportsFinder, findsOneWidget);

    await tester.tap(reportsFinder);

    // Wait up to ~2s for navigation and loading
    bool shown = false;
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Summary Reports').evaluate().isNotEmpty) {
        shown = true;
        break;
      }
    }
    expect(shown, isTrue, reason: 'Reports screen should be shown after tapping the button');
  });
}
