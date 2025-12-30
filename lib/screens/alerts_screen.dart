import 'dart:async';

import 'package:flutter/material.dart';
import '../models/alert_item.dart';
import '../services/alerts_service.dart';
import '../models/user_session.dart';

class AlertsScreen extends StatefulWidget {
  final UserSession session;
  final bool autoStart;
  const AlertsScreen({super.key, required this.session, this.autoStart = true});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late AlertsService _svc;
  List<AlertItem> _alerts = [];
  StreamSubscription<AlertItem>? _sub;

  @override
  void initState() {
    super.initState();
    _svc = AlertsService();
    _load();
    // subscribe to new alerts and start service only when autoStart is true
    if (widget.autoStart) {
      _sub = _svc.stream.listen((a) {
        setState(() => _alerts.insert(0, a));
      });
      _svc.start(interval: const Duration(seconds: 8));
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _svc.stop();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await _svc.getAll();
    setState(() => _alerts = list);
  }

  Widget _buildRow(AlertItem a) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: a.level == 'CRITICAL' ? Colors.red : (a.level == 'WARN' ? Colors.orange : Colors.blue),
          child: Text(a.level[0]),
        ),
        title: Text('${a.message} (${a.machineId})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${a.status}'),
            Text('Created: ${a.createdAt.toLocal()}'),
            if (a.acknowledgedBy != null) Text('Ack by: ${a.acknowledgedBy} at ${a.acknowledgedAt}'),
            if (a.clearedBy != null) Text('Cleared by: ${a.clearedBy} at ${a.clearedAt}'),
          ],
        ),
        isThreeLine: true,
        trailing: _buildActions(a),
      ),
    );
  }

  Widget _buildActions(AlertItem a) {
    if (a.status == 'Created') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: () => _ack(a), child: const Text('Acknowledge')),
          const SizedBox(height: 6),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => _clear(a), child: const Text('Clear')),
        ],
      );
    }
    if (a.status == 'Acknowledged') {
      return ElevatedButton(onPressed: () => _clear(a), child: const Text('Clear'));
    }
    return const Text('Closed');
  }

  Future<void> _ack(AlertItem a) async {
    await _svc.acknowledge(a, widget.session.email);
    setState(() {});
  }

  Future<void> _clear(AlertItem a) async {
    await _svc.clear(a, widget.session.email);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: _alerts.isEmpty ? const Center(child: Text('No alerts yet')) : ListView.builder(
        itemCount: _alerts.length,
        itemBuilder: (context, i) => _buildRow(_alerts[i]),
      ),
    );
  }
}
