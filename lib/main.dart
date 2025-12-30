import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'models/downtime.dart';
import 'models/maintenance_checklist.dart';
import 'models/alert_item.dart';
import 'models/user_session.dart';
import 'services/sync_service.dart';
import 'services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // register Hive adapters
  Hive.registerAdapter(DowntimeAdapter());
  Hive.registerAdapter(MaintenanceChecklistAdapter());
  Hive.registerAdapter(AlertItemAdapter());

  // start sync service
  SyncService().start();

  final session = await SessionService.loadSession();

  runApp(MyApp(initialSession: session));
}

class MyApp extends StatelessWidget {
  final UserSession? initialSession;
  const MyApp({super.key, this.initialSession});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Floor Lite',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialSession != null ? DashboardScreen(session: initialSession!) : const LoginScreen(),
    );
  }
}
