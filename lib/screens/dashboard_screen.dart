import 'package:flutter/material.dart';
import '../models/user_session.dart';
import '../services/session_service.dart';
import '../services/sync_service.dart';
import 'machine_list_screen.dart';
import 'login_screen.dart';
import 'alerts_screen.dart';
import 'reports_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserSession session;

  const DashboardScreen({super.key, required this.session});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime? _lastSync;
  bool _syncing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop Floor Lite'), actions: [
        IconButton(
          onPressed: _syncing ? null : () async {
            final messenger = ScaffoldMessenger.of(context);
            setState(() => _syncing = true);
            final dt = await SyncService().manualSync();
            if (!mounted) return;
            setState(() {
              _lastSync = dt;
              _syncing = false;
            });
            messenger.showSnackBar(const SnackBar(content: Text('Manual sync finished')));
          },
          icon: _syncing ? const CircularProgressIndicator() : const Icon(Icons.sync),
          tooltip: 'Manual sync',
        ),
        IconButton(
          onPressed: () async {
            // logout
            await SessionService.clearSession();
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${widget.session.email}'),
            Text('Role: ${widget.session.role}'),
            Text('Tenant: ${widget.session.tenantId}'),
            if (widget.session.mockJwt != null) Text('JWT: ${widget.session.mockJwt}'),
            if (_lastSync != null) Text('Last sync: ${_lastSync!.toLocal()}'),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>  MachineListScreen(),
                  ),
                );
              },
              child: const Text('Open Machine Dashboard'),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
              },
              child: const Text('Open Summary Reports'),
            ),
            const SizedBox(height: 12),
            if (widget.session.role == 'Supervisor')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AlertsScreen(session: widget.session)));
                },
                child: const Text('Open Alerts (Supervisor)'),
              ),
          ],
        ),
      ),
    );
  }
}
